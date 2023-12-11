/*
module "cloudfront_wafv2" {
  source  = "trussworks/wafv2/aws"
  version = "2.4.0"

  name          = "${var.primary_name}-${var.environment}-cloudfront-web-acl"
  scope         = "REGIONAL"
  associate_alb = var.associate_lb_to_wafv2
  alb_arn       = module.course1.course1-external-lb-arn[0]
}

resource "aws_wafv2_web_acl_association" "course1_internal" {
  count = var.associate_lb_to_wafv2 ? 1 : 0

  resource_arn = module.course1.course1-internal-lb-arn[0]
  web_acl_arn  = module.cloudfront_wafv2.web_acl_id
}
*/

#############################
# IP Set
#############################
resource "aws_wafv2_ip_set" "ipset_ipv4" {
  provider    = aws.course1-non-prod-us-east-1
  name        = "non_prod_ip_set_course1"
  scope       = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses   = var.ipset_ipv4
}

resource "aws_wafv2_ip_set" "ipset_ipv6" {
  provider    = aws.course1-non-prod-us-east-1
  name        = "ipv6_non_prod"
  scope       = "CLOUDFRONT"
  ip_address_version = "IPV6"
  addresses = ["2600:1f13:047c:4f00:0000:0000:0000:0000/56"]
}


################################################################################################################################################################
####   WAF for 
################################################################################################################################################################

resource "aws_wafv2_web_acl" "main" {
      name        = "${var.primary_name}-nonprod-cloudfront-web-acl"
      description = "WAFv2 ACL for ${var.primary_name}-nonprod-cloudfront-web-acl"
      scope       = "REGIONAL"

      default_action {
            allow {}
      }

      rule {
          name     = "SizeRestrictions_BODY_exception"
          priority = 0

          action {
              allow {
                }
            }

          statement {
              and_statement {
                  statement {

                      byte_match_statement {
                          positional_constraint = "CONTAINS"
                          search_string         = ""

                          field_to_match {

                              uri_path {}
                            }

                          text_transformation {
                              priority = 0
                              type     = "NONE"
                            }
                        }
                    }
                  statement {

                      size_constraint_statement {
                          comparison_operator = "GE"
                          size                = 8192

                          field_to_match {
                            
                          }

                          text_transformation {
                              priority = 0
                              type     = "NONE"
                            }
                        }
                    }
                }
            }

          visibility_config {
              cloudwatch_metrics_enabled = true
              metric_name                = "SizeRestrictions_BODY_exception"
              sampled_requests_enabled   = true
            }
        }

      rule {
          name     = "AWSManagedRulesCommonRuleSet"
          priority = 1

          override_action {

              none {}
            }

          statement {

              managed_rule_group_statement {
                  name        = "AWSManagedRulesCommonRuleSet"
                  vendor_name = "AWS"
                }
            }

          visibility_config {
              cloudwatch_metrics_enabled = true
              metric_name                = "AWSManagedRulesCommonRuleSet"
              sampled_requests_enabled   = true
            }
      }  

      rule {
          name     = "AWSManagedRulesAmazonIpReputationList"
          priority = 2

          override_action {

              none {}
            }

          statement {

              managed_rule_group_statement {
                  name        = "AWSManagedRulesAmazonIpReputationList"
                  vendor_name = "AWS"
            }
          } 
          visibility_config {
              cloudwatch_metrics_enabled = true
              metric_name                = "AWSManagedRulesAmazonIpReputationList"
              sampled_requests_enabled   = true
          }
        
      }

      rule {
          name     = "AWSManagedRulesKnownBadInputsRuleSet"
          priority = 3 

          override_action {

              none {}
            }

          statement {

              managed_rule_group_statement {
                  name        = "AWSManagedRulesKnownBadInputsRuleSet"
                  vendor_name = "AWS"
                }
            }

          visibility_config {
              cloudwatch_metrics_enabled = true
              metric_name                = "AWSManagedRulesKnownBadInputsRuleSet"
              sampled_requests_enabled   = true
            }
      }

      rule {
          name     = "AWSManagedRulesSQLiRuleSet"
          priority = 4 

          override_action {

              none {}
            }

          statement {

              managed_rule_group_statement {
              name        = "AWSManagedRulesSQLiRuleSet"
              vendor_name = "AWS"
                }
            }

          visibility_config {
              cloudwatch_metrics_enabled = true
              metric_name                = "AWSManagedRulesSQLiRuleSet"
              sampled_requests_enabled   = true
            }
      }
      
      rule {
          name     = "AWSManagedRulesLinuxRuleSet"
          priority = 5

          override_action {

              none {}
            }

          statement {

              managed_rule_group_statement {
                  name        = "AWSManagedRulesLinuxRuleSet"
                  vendor_name = "AWS"
                }
            }

          visibility_config {
              cloudwatch_metrics_enabled = true
              metric_name                = "AWSManagedRulesLinuxRuleSet"
              sampled_requests_enabled   = true
            }
      }
      
      rule {
          name     = "AWSManagedRulesUnixRuleSet"
          priority = 6

          override_action {

              none {}
            }

          statement {

              managed_rule_group_statement {
                  name        = "AWSManagedRulesUnixRuleSet"
                  vendor_name = "AWS"
                }
            }

          visibility_config {
              cloudwatch_metrics_enabled = true
              metric_name                = "AWSManagedRulesUnixRuleSet"
              sampled_requests_enabled   = true
            }
        }
  
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.primary_name}-nonprod-cloudfront-web-acl"
    sampled_requests_enabled   = true
  }

}

resource "aws_wafv2_web_acl_association" "lb" {

  resource_arn = ""
  web_acl_arn  = aws_wafv2_web_acl.main.arn
}

resource "aws_wafv2_web_acl_association" "lb" {

  resource_arn = ""
  web_acl_arn  = aws_wafv2_web_acl.main.arn
}

