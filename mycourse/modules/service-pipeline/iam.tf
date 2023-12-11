# codebuild repo clone IAM
resource "aws_iam_role" "clone_codebuild_iam" {
  name               = "${var.project_prefix}-${var.environment}-role-cb-clone-${var.service_name}"
  assume_role_policy = data.template_file.codebuild-assume.rendered
}

resource "aws_iam_role_policy" "clone_codebuild_iam" {
  name   = "${var.project_prefix}-${var.environment}-policy-cb-clone-${var.service_name}"
  role   = aws_iam_role.clone_codebuild_iam.id
  policy = data.template_file.clone-codebuild-policy.rendered
}

# codepipeline IAM roles
resource "aws_iam_role" "codepipeline_iam" {
  name               = "${var.project_prefix}-${var.environment}-role-cp-${var.service_name}"
  assume_role_policy = data.template_file.codepipeline-assume.rendered
}

resource "aws_iam_role_policy" "codepipeline_iam" {
  name   = "${var.project_prefix}-${var.environment}-policy-cp-${var.service_name}"
  role   = aws_iam_role.codepipeline_iam.id
  policy = data.template_file.codepipeline-policy.rendered
}

# codebuild CP Build
resource "aws_iam_role" "cp_codebuild_iam" {
  name               = "${var.project_prefix}-${var.environment}-role-cb-cp-${var.service_name}"
  assume_role_policy = data.template_file.codebuild-assume.rendered
}

resource "aws_iam_role_policy" "codebuild-cp-iam-role-policy" {
  name   = "${var.project_prefix}-${var.environment}-policy-cb-cp-${var.service_name}"
  role   = aws_iam_role.cp_codebuild_iam.name
  policy = data.template_file.codebuild-cp-iam-role-policy.rendered
}

# Template Files
data "template_file" "codepipeline-policy" {
  template = file("${path.module}/templates/codepipeline-iam-policy.template")
  vars = {
    artifact-bucket-arn = "arn:aws:s3:::${var.artifact_bucket}"
  }
}

data "template_file" "clone-codebuild-policy" {
  template = file(
    "${path.module}/templates/clone-codebuild-iam-policy.template",
  )
  vars = {
    artifact-bucket-arn = "arn:aws:s3:::${var.artifact_bucket}"
  }
}

data "template_file" "codebuild-cp-iam-role-policy" {
  template = file(
    "${path.module}/templates/codebuild-cp-iam-role-policy.template",
  )
  vars = {
    artifact-bucket-arn    = "arn:aws:s3:::${var.artifact_bucket}"
    environment-bucket-arn = "arn:aws:s3:::${var.environment_bucket}"
  }
}

#---- Assume Role

data "template_file" "codepipeline-assume" {
  template = file("${path.module}/templates/assume-role.template")
  vars = {
    service = "codepipeline"
  }
}

data "template_file" "codebuild-assume" {
  template = file("${path.module}/templates/assume-role.template")
  vars = {
    service = "codebuild"
  }
}

