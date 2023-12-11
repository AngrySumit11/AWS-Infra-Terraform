provider "aws" {
  region  = "ap-southeast-1"
  profile = "course1-non-prod"
  alias   = "course1-non-prod-ap-southeast-1"
  default_tags {
    tags = var.common_tags
  }
}

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

###### Multi Region KMS KEY ########

resource "aws_kms_key" "multi_region_primary_encrytion_key" {
  description              = var.description
  customer_master_key_spec = var.key_spec
  is_enabled               = var.enabled
  enable_key_rotation      = var.rotation_enabled
  multi_region             = true
  tags = {
    Name = format("%s-%s-multi-region-primary-kms-key", var.primary_name, var.environment_common)
  }
}

# Adding an alias to the Multi Region key #
resource "aws_kms_alias" "multi_region_primary_encrytion_key_alias" {
  name          = format("alias/%s-%s-multi-region-primary-kms-key", var.primary_name, var.environment_common)
  target_key_id = aws_kms_key.multi_region_primary_encrytion_key.key_id
}

# Creating the multi region replica key #
resource "aws_kms_replica_key" "multi_region_replica_encrytion_key" {
  provider                = aws.course1-non-prod-ap-southeast-1
  description             = "Multi-Region replica key"
  primary_key_arn         = aws_kms_key.multi_region_primary_encrytion_key.arn
  tags = {
    Name = format("%s-%s-multi-region-replica-kms-key", var.primary_name, var.environment_common)
  }
}

# Add an alias to the replica key #
resource "aws_kms_alias" "multi_region_replica_encrytion_key_alias" {
  name          = format("alias/%s-%s-multi-region-replica-kms-key", var.primary_name, var.environment_common)
  target_key_id = aws_kms_replica_key.multi_region_replica_encrytion_key.key_id
}
