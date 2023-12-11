//terraform {
//  required_providers {
//    cloudhealth = {
//      source = "honkyjive/cloudhealth"
//    }
//  }
//}
//
//# Either uncomment it or set Env varaible CLOUDHEALTH_API_KEY
////provider "cloudhealth" {
////  api_key = "<api_key>"
////}
//
//resource "cloudhealth_aws_account" "cloudhealth" {
//  name = var.aws_account_name
//
//  authentication {
//    protocol                = "assume_role"
//    assume_role_arn         = aws_iam_role.cloudhealth.arn
//    assume_role_external_id = data.cloudhealth_aws_external_id.nextgen.id
//  }
//}
//
//data "cloudhealth_aws_external_id" "nextgen" {}
//
//variable "aws_account_name" {
//  type = string
//}
