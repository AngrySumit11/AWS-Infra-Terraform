

# Pipeline CodeBuild
resource "aws_codebuild_project" "codebuild-cp-build" {
  name          = "${var.project_prefix}-${var.environment}-cb-cp-${var.service_name}"
  description   = "pipeline build: ${var.service_name}"
  build_timeout = var.build_timeout
  service_role  = aws_iam_role.cp_codebuild_iam.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  vpc_config {
    vpc_id             = var.cb_vpc_id
    subnets            = var.cb_subnets
    security_group_ids = var.cb_security_groups
  }

  environment {
    compute_type                = "BUILD_GENERAL1_MEDIUM"
    image                       = var.codebuild_image
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = "true"

    environment_variable {
      name  = "REPOSITORY_URI"
      type  = "PLAINTEXT"
      value = var.repository_uri
    }
    environment_variable {
      name  = "CONTAINER_NAME"
      type  = "PLAINTEXT"
      value = var.container_name
    }
    environment_variable {
      name  = "ENVIRONMENT_BUCKET"
      type  = "PLAINTEXT"
      value = var.environment_bucket
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "${var.project_prefix}-cwg-cb-cp"
      stream_name = "${var.project_prefix}-cb-cp-${var.service_name}"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = data.template_file.codepipeline-buildspec.rendered
  }

  tags = {
    project_prefix = var.project_prefix
    Name           = "${var.project_prefix}-${var.environment}-cb-cp-${var.service_name}"
  }
}

data "template_file" "codepipeline-buildspec" {
  template = file("${path.module}/templates/codepipeline-${var.service_name}-${var.environment}-buildspec.template")
}
