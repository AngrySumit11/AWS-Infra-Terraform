

# Pipeline CodeBuild
resource "aws_codebuild_project" "codebuild_cp_build" {
  name          = "${var.project_prefix}-${var.environment}-cb-cp-${var.service_name}"
  description   = "pipeline build: ${var.service_name}"
  build_timeout = var.build_timeout
  service_role  = aws_iam_role.cp_codebuild_iam.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_LARGE"
    image                       = "aws/codebuild/standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = "false"


    environment_variable {
      name  = "ENVIRONMENT_BUCKET"
      type  = "PLAINTEXT"
      value = var.environment_bucket
    }
    environment_variable {
      name  = "NODE_OPTIONS"
      type  = "PLAINTEXT"
      value = "--max-old-space-size=4000"
    }
    environment_variable {
      name  = "env"
      type  = "PLAINTEXT"
      value = var.environment
    }
    environment_variable {
      name  = "web_app_env"
      type  = "PLAINTEXT"
      value = var.web_app_env
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
  template = file("${path.module}/templates/codepipeline-web-app-buildspec.template")
}
