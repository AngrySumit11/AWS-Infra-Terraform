# codebuild repo clone IAM
resource "aws_iam_role" "clone_codebuild_iam" {
  name               = "${var.project_prefix}-${var.environment}-rol-cb-clone-${var.service_name}"
  assume_role_policy = data.template_file.codebuild_assume.rendered
}

resource "aws_iam_role_policy" "clone_codebuild_iam" {
  name   = "${var.project_prefix}-${var.environment}-pol-cb-clone-${var.service_name}"
  role   = aws_iam_role.clone_codebuild_iam.id
  policy = data.template_file.clone_codebuild_policy.rendered
}

# codepipeline IAM roles
resource "aws_iam_role" "codepipeline_iam" {
  name               = "${var.project_prefix}-${var.environment}-rol-cp-${var.service_name}"
  assume_role_policy = data.template_file.codepipeline_assume.rendered
}

resource "aws_iam_role_policy" "codepipeline_iam" {
  name   = "${var.project_prefix}-${var.environment}-pol-cp-${var.service_name}"
  role   = aws_iam_role.codepipeline_iam.id
  policy = data.template_file.codepipeline_policy.rendered
}

resource "aws_iam_role" "cp_codebuild_iam" {
  name               = "${var.project_prefix}-${var.environment}-rol-cb-cp-${var.service_name}"
  assume_role_policy = data.template_file.codebuild_assume.rendered
}

resource "aws_iam_role_policy" "codebuild_cp_iam_role_policy" {
  name   = "${var.project_prefix}-${var.environment}-pol-cb-cp-${var.service_name}"
  role   = aws_iam_role.cp_codebuild_iam.name
  policy = data.template_file.codebuild_cp_iam_role_policy.rendered
}

data "template_file" "codepipeline_policy" {
  template = file("${path.module}/templates/codepipeline-iam-policy.template")
  vars = {
    artifact-bucket-arn   = "arn:aws:s3:::${var.artifact_bucket}"
    deployment-bucket-arn = "arn:aws:s3:::${var.deployment_bucket}"
    invalidate_lambda_id  = var.invalidate_lambda_arn
  }
}

data "template_file" "clone_codebuild_policy" {
  template = file(
    "${path.module}/templates/clone-codebuild-iam-policy.template",
  )
  vars = {
    artifact-bucket-arn = "arn:aws:s3:::${var.artifact_bucket}"
  }
}

data "template_file" "codebuild_cp_iam_role_policy" {
  template = file(
    "${path.module}/templates/codebuild-cp-iam-role-policy.template",
  )
  vars = {
    artifact-bucket-arn    = "arn:aws:s3:::${var.artifact_bucket}"
    environment-bucket-arn = "arn:aws:s3:::${var.environment_bucket}"
  }
}

#---- Assume Role

data "template_file" "codepipeline_assume" {
  template = file("${path.module}/templates/assume-role.template")
  vars = {
    service = "codepipeline"
  }
}

data "template_file" "codebuild_assume" {
  template = file("${path.module}/templates/assume-role.template")
  vars = {
    service = "codebuild"
  }
}

