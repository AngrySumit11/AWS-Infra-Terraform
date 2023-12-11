############################################# Launch EKS Cluster ###########################################################
# This is needed for Restricting access to the IMDS and Amazon EC2 instance profile credentials from EKS pods
# https://docs.aws.amazon.com/eks/latest/userguide/best-practices-security.html
data "template_file" "launch_template_userdata_hub" {
  template = file("${path.module}/../../common/templates/userdata.sh.tpl")

  vars = {
    cluster_name        = local.hub_cluster_name
    endpoint            = module.eks-hub.cluster_endpoint
    cluster_auth_base64 = module.eks-hub.cluster_certificate_authority_data

    bootstrap_extra_args = ""
    kubelet_extra_args   = ""
  }
}

resource "aws_launch_template" "eks-node-group-lt-hub" {
  name = "eks-node-group-hub-${var.environment}"

  key_name = var.ec2_key_name

  vpc_security_group_ids = [
    aws_security_group.eks-ssh-hub.id,
    aws_security_group.ext-svc-internal.id,
    module.eks-hub.cluster_primary_security_group_id
  ]

  user_data = base64encode(
    data.template_file.launch_template_userdata_hub.rendered,
  )
  tag_specifications {
    resource_type = "instance"
    tags = merge(
      {
        Name = "eks-node-group-hub-${var.environment}"
      },
      var.common_tags
    )
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(
      {
        Name = "eks-node-group-hub-${var.environment}"
      },
      var.common_tags
    )
  }

  tag_specifications {
    resource_type = "spot-instances-request"
    tags = merge(
      {
        Name = "eks-node-group-hub-${var.environment}"
      },
      var.common_tags
    )
  }
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    "Name" = "eks-node-group-hub-${var.environment}"
  }
}

module "eks-hub" {
  source                      = "git::https://github.com/terraform-aws-modules/terraform-aws-eks.git?ref=v14.0.0"
  cluster_name                = local.hub_cluster_name
  cluster_version             = "1.23"
  vpc_id                      = data.aws_vpc.vpc.id
  subnets                     = data.aws_subnet_ids.private_services.ids
  write_kubeconfig            = false
  workers_additional_policies = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
#  cluster_enabled_log_types   = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  node_groups = {
    hub_eks_nodes = {
      desired_capacity = var.hub_eks_desired_capacity
      max_capacity     = var.hub_eks_max_capacity
      min_capacity     = var.hub_eks_min_capacity

      instance_types = var.hub_eks_instance_types
      capacity_type  = "SPOT"

      launch_template_id        = aws_launch_template.eks-node-group-lt-hub.id
      launch_template_version   = 3
      source_security_group_ids = [module.jumpbox.jumpbox-sg-id, module.course1.course1-security-group]
      k8s_labels = {
        node = var.hub_node_k8s_labels
      }
      tags = {
        "Name" = local.hub_cluster_name
        "k8s.io/cluster-autoscaler/enabled"       = "true"
        "k8s.io/cluster-autoscaler/course1-dev-hub-apps" = "owned"
      }
    }
  }
  manage_aws_auth = false
  tags = {
    "Name" = local.hub_cluster_name
  }
}

############################################ Create Openid Provider #####################################################################
data "tls_certificate" "cluster-hub" {
  url = module.eks-hub.cluster_oidc_issuer_url
}

resource "aws_iam_openid_connect_provider" "cluster-hub" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster-hub.certificates.0.sha1_fingerprint]
  url             = module.eks-hub.cluster_oidc_issuer_url
}

############################################################################################################################

resource "aws_iam_role" "eks_pod_iam_role_hub" {
  count = length(var.api_list_iam_roles)
  name  = "${local.hub_cluster_name}-${var.api_list_iam_roles[count.index]}"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Effect : "Allow",
        Principal : {
          "Federated" : aws_iam_openid_connect_provider.cluster-hub.arn
        },
        Action : "sts:AssumeRoleWithWebIdentity",
        Condition : {
          StringEquals : {
            "${replace(aws_iam_openid_connect_provider.cluster-hub.url, "https://", "")}:sub" : "system:serviceaccount:${var.api_list_iam_roles_namespaces[count.index]}:${var.api_list_iam_roles_service_account_hub[count.index]}"
          }
        }
      }
    ]
  })
  tags = {
    "ServiceAccountName"      = "${local.hub_cluster_name}-${var.api_list_iam_roles[count.index]}"
    "ServiceAccountNameSpace" = "default"
  }
  depends_on = [aws_iam_openid_connect_provider.cluster-hub]
}

data "aws_iam_policy_document" "eks-sqs-sns-policy-document-hub" {
  count = var.create_sns_sqs ? 1 : 0
  # Used by Notifications-Worker api
  statement {
    sid       = "EKSSQSPolicy"
    effect    = "Allow"
    actions   = ["sqs:*"]
    resources = module.course1.course1_sqs_arns
  }

  # Used by Notifications api
  statement {
    sid       = "EKSSNSPolicy"
    effect    = "Allow"
    actions   = ["sns:*"]
    resources = module.course1.course1_sns_arns
  }
}

resource "aws_iam_role_policy" "eks-sqs-sns-policy-hub" {
  count  = var.create_sns_sqs ? 1 : 0
  name   = "EKS-HUB-SNS-SQS-Policy"
  role   = aws_iam_role.eks_pod_iam_role_hub[0].name
  policy = data.aws_iam_policy_document.eks-sqs-sns-policy-document-hub[count.index].json
}

resource "aws_iam_role_policy" "alb-ingress-iam-policy-hub" {
  count  = var.create_alb_ingress_controller_hub ? 1 : 0
  name   = "HUB-ALBIngressControllerIAMPolicy"
  role   = aws_iam_role.eks_pod_iam_role_hub[1].name
  policy = file("${path.module}/../../common/ALBIngressControllerIAMPolicy.json")
}

data "aws_iam_policy_document" "eks-s3-policy-document-hub" {
  # Used by Content and PDF Generation api
  dynamic "statement" {
    for_each = range(length(var.s3_bucket_names_hub))
    content {
      sid     = "EKSS3Policy${statement.value}"
      actions = ["s3:*"]
      effect  = "Allow"
      resources = [
        "arn:aws:s3:::${var.primary_short_name}-${var.s3_bucket_names_hub[statement.value]}${var.env_identifier}",
        "arn:aws:s3:::${var.primary_short_name}-${var.s3_bucket_names_hub[statement.value]}${var.env_identifier}/*"
      ]
    }
  }
}

resource "aws_iam_role_policy" "eks-s3-policy-hub" {
  count      = length(var.s3_bucket_names_hub) > 0 ? 1 : 0
  name       = "EKS-S3-Policy"
  role       = aws_iam_role.eks_pod_iam_role_hub[0].name
  policy     = data.aws_iam_policy_document.eks-s3-policy-document-hub.json
  depends_on = [aws_iam_role.eks_pod_iam_role_hub]
}

#########################################################################################################
resource "aws_security_group" "eks-ssh-hub" {
  description = "EKS-HUB SG for ssh internally"
  name        = "${local.hub_cluster_name}-sg-internal"
  vpc_id      = var.vpc_id

  ingress {
    description     = "SSH from Jumpbox"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [module.jumpbox.jumpbox-sg-id]
  }

  ingress {
    description = "All traffic between EKS nodes"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "${local.hub_cluster_name}-sg-internal"
  }
}

resource "aws_security_group_rule" "alb-ingress-controller-sg-rule-egress-hub" {
  security_group_id = module.course1.course1-security-group-external

  type      = "egress"
  from_port = 0
  to_port   = 65535
  protocol  = "tcp"

  source_security_group_id = module.eks-hub.cluster_primary_security_group_id
}

resource "aws_security_group_rule" "alb-ingress-controller-sg-rule-ingress-hub" {
  security_group_id = module.eks-hub.cluster_primary_security_group_id

  type      = "ingress"
  from_port = 0
  to_port   = 65535
  protocol  = "tcp"

  source_security_group_id = module.course1.course1-security-group-external
}