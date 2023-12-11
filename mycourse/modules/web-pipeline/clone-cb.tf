#CodeBuild 
resource "aws_codebuild_project" "codebuild" {
  name          = "${var.project_prefix}-${var.environment}-cb-clone-${var.service_name}"
  description   = "repo clone: ${var.service_name} "
  build_timeout = "5"
  service_role  = aws_iam_role.clone_codebuild_iam.arn

  source {
    type            = "GITHUB"
    location        = var.repo_url
    git_clone_depth = 0
    buildspec       = data.template_file.clone_codebuild_buildspec.rendered
    git_submodules_config {
              fetch_submodules = false
    }
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    
    environment_variable {
      name  = "branch_name"
      type  = "PLAINTEXT"
      value = var.branch_name
    }
    environment_variable {
      name  = "repo_name"
      type  = "PLAINTEXT"
      value = var.repo_name
    }
    environment_variable {
      name  = "env"
      type  = "PLAINTEXT"
      value = var.environment
    }
  }

  artifacts {
    type      = "S3"
    location  = var.artifact_bucket
    packaging = "ZIP"
    name      = "${var.repo_name}-${var.branch_name}.zip"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "${var.project_prefix}-cwg-cb-clone"
      stream_name = "${var.project_prefix}-cb-clone-${var.service_name}"
    }
  }

  tags = {
    project_prefix = var.project_prefix
    Name           = "${var.project_prefix}-${var.environment}-cb-clone-${var.service_name}"
  }
}

#Webhook trigger from Bitbucket
resource "aws_codebuild_webhook" "codebuild_webhook" {
  build_type = "BUILD"
  project_name = aws_codebuild_project.codebuild.name
  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH, PULL_REQUEST_MERGED"
    }
    filter {
      type    = "HEAD_REF"
      pattern = var.environment == "prod" ? "^refs/tags/v1.*" : "^refs/heads/${var.branch_name}$"
    }
  }
}

data "template_file" "clone_codebuild_buildspec" {
  template = file("${path.module}/templates/clone-codebuild-web-app-buildspec.template")
}
