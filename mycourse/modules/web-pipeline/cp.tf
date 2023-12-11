#Pipeline
resource "aws_codepipeline" "codepipeline" {
  name     = "${var.project_prefix}-${var.environment}-cp-${var.service_name}"
  role_arn = aws_iam_role.codepipeline_iam.arn

  artifact_store {
    location = var.artifact_bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        S3Bucket             = var.artifact_bucket
        S3ObjectKey          = "${var.repo_name}-${var.environment}.zip"
        PollForSourceChanges = "true"
      }

    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.codebuild_cp_build.name
      }
    }
  }

  dynamic "stage" {
    for_each = var.production_approval ? [1] : []
    content {
      name = "Approve"
      action {
        configuration = {
          NotificationArn = var.environment == "prod" ? "${var.approve_sns_arn}" : ""
          CustomData      = "Please check and Approve"
        }
        name     = "Production-Approval"
        category = "Approval"
        owner    = "AWS"
        provider = "Manual"
        version  = "1"
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "S3"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        BucketName = var.deployment_bucket
        Extract    = "true"
        #CannedACL  = "public-read"
        CacheControl = "max-age=2592000,public"
      }
    }
  }
  # invalidate CDN via lambda
  stage {
    name = "Invalidate-CDN"

    action {
      name     = "Invalidate-CDN"
      category = "Invoke"
      owner    = "AWS"
      provider = "Lambda"
      # input_artifacts = ["build_output"]
      version = "1"

      configuration = {
        FunctionName   = var.invalidate_lambda_id
        UserParameters = var.distribution_id
      }
    }
  }
  tags = {
    project_prefix = var.project_prefix
    Name           = "${var.project_prefix}-${var.environment}-cp-${var.service_name}"
  }
}
