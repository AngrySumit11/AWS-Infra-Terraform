############################################# Launch EKS Cluster ###########################################################
# This is needed for Restricting access to the IMDS and Amazon EC2 instance profile credentials from EKS pods
# https://docs.aws.amazon.com/eks/latest/userguide/best-practices-security.html
data "template_file" "launch_template_userdata" {
  template = file("${path.module}/../../common/templates/userdata.sh.tpl")

  vars = {
    cluster_name        = local.cluster_name
    endpoint            = module.eks.cluster_endpoint
    cluster_auth_base64 = module.eks.cluster_certificate_authority_data

    bootstrap_extra_args = ""
    kubelet_extra_args   = ""
  }
}

resource "aws_launch_template" "eks-node-group-lt" {
  name = "eks-node-group-${var.environment}"

  key_name = var.ec2_key_name

  vpc_security_group_ids = [
    aws_security_group.eks-ssh.id,
    aws_security_group.ext-svc-internal.id,
    module.eks.cluster_primary_security_group_id
  ]
  user_data = base64encode(
    data.template_file.launch_template_userdata.rendered,
  )
  tag_specifications {
    resource_type = "instance"
    tags = merge(
      {
        Name = "eks-node-group-${var.environment}"
      },
      var.common_tags
    )
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(
      {
        Name = "eks-node-group-${var.environment}"
      },
      var.common_tags
    )
  }

  tag_specifications {
    resource_type = "spot-instances-request"
    tags = merge(
      {
        Name = "eks-node-group-${var.environment}"
      },
      var.common_tags
    )
  }
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    "Name" = "eks-node-group-${var.environment}"
  }
}

module "eks" {
  source                      = "git::https://github.com/terraform-aws-modules/terraform-aws-eks.git?ref=v14.0.0"
  cluster_name                = local.cluster_name
  cluster_version             = "1.23"
  vpc_id                      = data.aws_vpc.vpc.id
  subnets                     = data.aws_subnet_ids.private_services.ids
  write_kubeconfig            = false
  workers_additional_policies = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
 # cluster_enabled_log_types   = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  node_groups = {
    course1_eks_nodes = {
      desired_capacity = var.eks_desired_capacity
      max_capacity     = var.eks_max_capacity
      min_capacity     = var.eks_min_capacity

      instance_types = var.eks_instance_types
      capacity_type  = "SPOT"

      launch_template_id        = aws_launch_template.eks-node-group-lt.id
      launch_template_version   = 9
      source_security_group_ids = [module.jumpbox.jumpbox-sg-id, module.course1.course1-security-group]
      k8s_labels = {
        node = var.node_k8s_labels
      }
      tags = {
        "Name" = local.cluster_name
        "k8s.io/cluster-autoscaler/enabled"       = "true"
        "k8s.io/cluster-autoscaler/course1-dev-apps" = "owned"
      }
    }
  }
  manage_aws_auth = false
  tags = {
    "Name" = local.cluster_name
  }
}

############################################ Create Openid Provider #####################################################################
data "tls_certificate" "cluster" {
  url = module.eks.cluster_oidc_issuer_url
}

resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster.certificates.0.sha1_fingerprint]
  url             = module.eks.cluster_oidc_issuer_url
}

############################################################################################################################

resource "aws_iam_role" "eks_pod_iam_role" {
  count = length(var.api_list_iam_roles)
  name  = "${local.cluster_name}-${var.api_list_iam_roles[count.index]}"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Effect : "Allow",
        Principal : {
          "Federated" : aws_iam_openid_connect_provider.cluster.arn
        },
        Action : "sts:AssumeRoleWithWebIdentity",
        Condition : {
          StringEquals : {
            "${replace(aws_iam_openid_connect_provider.cluster.url, "https://", "")}:sub" : "system:serviceaccount:${var.api_list_iam_roles_namespaces[count.index]}:${var.api_list_iam_roles_service_account[count.index]}"
          }
        }
      }
    ]
  })
  tags = {
    "ServiceAccountName"      = "${local.cluster_name}-${var.api_list_iam_roles[count.index]}"
    "ServiceAccountNameSpace" = "default"
  }
  depends_on = [aws_iam_openid_connect_provider.cluster]
}

data "aws_iam_policy_document" "eks-sqs-sns-policy-document" {
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

resource "aws_iam_role_policy" "eks-sqs-sns-policy" {
  count  = var.create_sns_sqs ? 1 : 0
  name   = "EKS-SNS-SQS-Policy"
  role   = aws_iam_role.eks_pod_iam_role[0].name
  policy = data.aws_iam_policy_document.eks-sqs-sns-policy-document[count.index].json
}

resource "aws_iam_role_policy" "alb-ingress-iam-policy" {
  count  = var.create_alb_ingress_controller ? 1 : 0
  name   = "ALBIngressControllerIAMPolicy"
  role   = aws_iam_role.eks_pod_iam_role[1].name
  policy = file("${path.module}/../../common/ALBIngressControllerIAMPolicy.json")
}

data "aws_iam_policy_document" "eks-s3-policy-document" {
  # Used by Content and PDF Generation api
  dynamic "statement" {
    for_each = range(length(var.s3_bucket_names))
    content {
      sid     = "EKSS3Policy${statement.value}"
      actions = ["s3:*"]
      effect  = "Allow"
      resources = [
        "arn:aws:s3:::${var.primary_short_name}-${var.s3_bucket_names[statement.value]}${var.env_identifier}",
        "arn:aws:s3:::${var.primary_short_name}-${var.s3_bucket_names[statement.value]}${var.env_identifier}/*"
      ]
    }
  }
}

resource "aws_iam_role_policy" "eks-s3-policy" {
  count      = length(var.s3_bucket_names) > 0 ? 1 : 0
  name       = "EKS-S3-Policy"
  role       = aws_iam_role.eks_pod_iam_role[0].name
  policy     = data.aws_iam_policy_document.eks-s3-policy-document.json
  depends_on = [aws_iam_role.eks_pod_iam_role]
}

#########################################################################################################
resource "aws_ecr_repository" "ecr-repos" {
  count = length(var.api_list)
  name  = "${var.primary_short_name}-${var.api_list[count.index]}${var.env_identifier}"
  tags = {
    "Name"        = "${var.primary_short_name}-${var.api_list[count.index]}${var.env_identifier}"
    "Environment" = var.environment
  }
}

resource "aws_ecr_lifecycle_policy" "ecr-repos-policy" {
  count      = length(var.api_list)
  repository = aws_ecr_repository.ecr-repos[count.index].name

  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep only last latest 10 images",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": 10
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}

#########################################################################################################
resource "aws_security_group" "eks-ssh" {
  description = "EKS SG for ssh internally"
  name        = "${local.cluster_name}-sg-internal"
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
    "Name" = "${local.cluster_name}-sg-internal"
  }
}

