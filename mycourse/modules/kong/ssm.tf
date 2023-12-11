resource "aws_kms_key" "course1" {
  description = format("%s-%s", var.service, var.environment)

  tags = {
    "Name"        = format("%s-%s", var.service, var.environment),
    "Environment" = var.environment,
    "Description" = var.description,
    "Service"     = var.service,
  }
}

resource "aws_kms_alias" "course1" {
  name          = format("alias/%s-%s", var.service, var.environment)
  target_key_id = aws_kms_key.course1.key_id
}

resource "aws_ssm_parameter" "ee-bintray-auth" {
  name      = format("/%s/%s/ee/bintray-auth", var.service, var.environment)
  type      = "SecureString"
  value     = var.ee_bintray_auth
  overwrite = true
  key_id    = aws_kms_alias.course1.target_key_arn

  lifecycle {
    ignore_changes = [value]
  }
  tags = {
    "Name" = format("/%s/%s/ee/bintray-auth", var.service, var.environment)
  }
}

resource "aws_ssm_parameter" "ee-license" {
  name      = format("/%s/%s/ee/license", var.service, var.environment)
  type      = "SecureString"
  value     = var.ee_license
  overwrite = true
  key_id    = aws_kms_alias.course1.target_key_arn

  lifecycle {
    ignore_changes = [value]
  }
  tags = {
    "Name" = format("/%s/%s/ee/license", var.service, var.environment)
  }
}

resource "aws_ssm_parameter" "ee-admin-token" {
  name      = format("/%s/%s/ee/admin/token", var.service, var.environment)
  type      = "SecureString"
  value     = random_string.admin_token.result
  overwrite = true
  key_id    = aws_kms_alias.course1.target_key_arn

  lifecycle {
    ignore_changes = [value]
  }
  tags = {
    "Name" = format("/%s/%s/ee/admin/token", var.service, var.environment)
  }
}

resource "aws_ssm_parameter" "db-host" {
  name      = format("/%s/%s/db/host", var.service, var.environment)
  type      = "String"
  overwrite = true
  value = coalesce(
    join("", aws_db_instance.course1.*.address),
    join("", aws_rds_cluster.course1.*.endpoint),
    "none"
  )
  tags = {
    "Name" = format("/%s/%s/db/host", var.service, var.environment)
  }
}

resource "aws_ssm_parameter" "db-name" {
  name      = format("/%s/%s/db/name", var.service, var.environment)
  type      = "String"
  value     = replace(format("%s_%s", var.service, var.environment), "-", "_")
  overwrite = true
  tags = {
    "Name" = format("/%s/%s/db/name", var.service, var.environment)
  }
}

resource "aws_ssm_parameter" "db-password" {
  name  = format("/%s/%s/db/password", var.service, var.environment)
  type  = "SecureString"
  value = random_string.db_password.result

  key_id = aws_kms_alias.course1.target_key_arn

  lifecycle {
    ignore_changes = [value]
  }

  overwrite = true
  tags = {
    "Name" = format("/%s/%s/db/password", var.service, var.environment)
  }
}

resource "aws_ssm_parameter" "db-master-password" {
  name  = format("/%s/%s/db/password/master", var.service, var.environment)
  type  = "SecureString"
  value = random_string.master_password.result

  key_id = aws_kms_alias.course1.target_key_arn

  lifecycle {
    ignore_changes = [value]
  }

  overwrite = true
  tags = {
    "Name" = format("/%s/%s/db/password/master", var.service, var.environment)
  }
}

resource "aws_ssm_parameter" "sumologic-accessid" {
  name  = format("/%s/%s/sumologic/accessid", var.service, var.environment)
  type  = "SecureString"
  value = random_string.sumo-accessid.result

  key_id = aws_kms_alias.course1.target_key_arn

  lifecycle {
    ignore_changes = [value]
  }

  overwrite = true
  tags = {
    "Name" = format("/%s/%s/sumologic/accessid", var.service, var.environment)
  }
}

resource "aws_ssm_parameter" "sumologic-accesskey" {
  name  = format("/%s/%s/sumologic/accesskey", var.service, var.environment)
  type  = "SecureString"
  value = random_string.sumo-accesskey.result

  key_id = aws_kms_alias.course1.target_key_arn

  lifecycle {
    ignore_changes = [value]
  }

  overwrite = true
  tags = {
    "Name" = format("/%s/%s/sumologic/accesskeey", var.service, var.environment)
  }
}
