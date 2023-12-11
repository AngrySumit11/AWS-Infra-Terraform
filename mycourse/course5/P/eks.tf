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
  cluster_version             = "1.22"
  vpc_id                      = data.aws_vpc.vpc.id
  subnets                     = data.aws_subnet_ids.private_services.ids
  write_kubeconfig            = false
  enable_irsa                 = true
  workers_additional_policies = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
  node_groups = {
    course1_eks_nodes = {
      desired_capacity = var.eks_desired_capacity
      max_capacity     = var.eks_max_capacity
      min_capacity     = var.eks_min_capacity

      instance_types = var.eks_instance_types
      capacity_type  = "SPOT"

      launch_template_id        = aws_launch_template.eks-node-group-lt.id
      launch_template_version   = aws_launch_template.eks-node-group-lt.latest_version
      
      k8s_labels = {
        node = var.node_k8s_labels
      }
      tags = {
        "Name" = local.cluster_name
        "k8s.io/cluster-autoscaler/enabled"       = "true"
        "k8s.io/cluster-autoscaler/course1-poc-apps" = "owned"
      }
    }
  }
  manage_aws_auth = false
  tags = {
    "Name" = local.cluster_name
  }
}

############################################ Create Openid Provider #####################################################################
# data "tls_certificate" "cluster" {
#   url = module.eks.cluster_oidc_issuer_url
# }

# resource "aws_iam_openid_connect_provider" "cluster" {
#   client_id_list  = ["sts.amazonaws.com"]
#   thumbprint_list = [data.tls_certificate.cluster.certificates.0.sha1_fingerprint]
#   url             = module.eks.cluster_oidc_issuer_url
# }

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
          "Federated" : module.eks.oidc_provider_arn
        },
        Action : "sts:AssumeRoleWithWebIdentity",
        Condition : {
          StringEquals : {
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub" : "system:serviceaccount:${var.api_list_iam_roles_namespaces[count.index]}:${var.api_list_iam_roles_service_account[count.index]}"
          }
        }
      }
    ]
  })
  tags = {
    "ServiceAccountName"      = "${local.cluster_name}-${var.api_list_iam_roles[count.index]}"
    "ServiceAccountNameSpace" = "default"
  }
  #depends_on = [aws_iam_openid_connect_provider.cluster]
}

resource "aws_security_group" "eks-ssh" {
  description = "EKS SG for ssh internally"
  name        = "${local.cluster_name}-sg-internal"
  vpc_id      = var.vpc_id

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
