# Creating the KMS CMK
resource "aws_kms_key" "db_encrytion_key" {
  description              = var.description
  customer_master_key_spec = var.key_spec
  is_enabled               = var.enabled
  enable_key_rotation      = var.rotation_enabled
  tags = {
    Name = format("%s-%s-db-kms-key", var.primary_name, var.environment_common)
  }
}

# Adding an alias to the key
resource "aws_kms_alias" "db_encrytion_key_alias" {
  name          = format("alias/%s-%s-db-kms-key", var.primary_name, var.environment_common)
  target_key_id = aws_kms_key.db_encrytion_key.key_id
}
