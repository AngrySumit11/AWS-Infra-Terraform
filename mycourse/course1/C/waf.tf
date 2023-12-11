######################################################################################################################################################################################################################################################################################################################################################
####   WAF 
######################################################################################################################################################################################################################################################################################################################################################

resource "aws_wafv2_web_acl" "main" {
      name        = "${var.primary_name}-nonprod-web-acl"
      description = "WAFv2 ACL for ${var.primary_name}-nonprod-web-acl"
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
                      size_constraint_statement {
                          comparison_operator = "GE"
                          size                = 8192

                          field_to_match {

                              body {}
                            }

                          text_transformation {
                              priority = 0
                              type     = "NONE"
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
          name     = "NoUserAgent_HEADER_exception"
          priority = 1

          action {
              allow {}
            }

          statement {

              byte_match_statement {
                  positional_constraint = "STARTS_WITH"
                  search_string         = "/api/investorcourse1/api/v1/"

                  field_to_match {

                      uri_path {}
                    }

                  text_transformation {
                      priority = 0 
                      type     = "NONE"
                    }
                }
            }

          visibility_config {
              cloudwatch_metrics_enabled = true 
              metric_name                = "NoUserAgent_HEADER_exception"
              sampled_requests_enabled   = true
            }
        }
          
      rule {
          name     = "AWSManagedRulesAmazonIpReputationList"
          priority = 8

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
          name     = "AWSManagedRulesCommonRuleSet"
          priority = 2

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
          name     = "AWSManagedRulesLinuxRuleSet"
          priority = 4

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
          name     = "AWSManagedRulesSQLiRuleSet"
          priority = 5 

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
    
      rule {
          name     = "AWSManagedRulesAnonymousIpList"
          priority = 7

          override_action {

               none {}
            }

          statement {

               managed_rule_group_statement {
                   name        = "AWSManagedRulesAnonymousIpList"
                   vendor_name = "AWS"
                }
            }

          visibility_config {
               cloudwatch_metrics_enabled = true
               metric_name                = "AWSManagedRulesAnonymousIpList"
               sampled_requests_enabled   = true
            }
        }
  
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.primary_name}-nonprod-web-acl"
    sampled_requests_enabled   = true
  }

}

resource "aws_wafv2_web_acl_logging_configuration" "main" {
  log_destination_configs = [aws_cloudwatch_log_group.main-log-group.arn]
  resource_arn            = aws_wafv2_web_acl.main.arn
}

resource "aws_cloudwatch_log_group" "main-log-group" {
  name              = "aws-waf-logs-${var.primary_name}-nonprod-web-acl"
  retention_in_days = 30
}

##############################################################################################################################
####   WAF association 
##############################################################################################################################

resource "aws_wafv2_web_acl" "windows" {
      name        = "${var.primary_name}-nonprod-windows-web-acl"
      description = "WAFv2 ACL for ${var.primary_name}-nonprod-windows-web-acl"
      scope       = "REGIONAL"

      default_action {
            allow {}
      }

      rule {
          name     = "AWSManagedRulesAmazonIpReputationList"
          priority = 0

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
          name     = "SizeRestrictions_BODY_exception"
          priority = 1

          action {
              allow {
                }
            }

          statement {
                      size_constraint_statement {
                          comparison_operator = "GE"
                          size                = 8192

                          field_to_match {

                              body {}
                            }

                          text_transformation {
                              priority = 0
                              type     = "NONE"
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
          priority = 2

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
          name     = "AWSManagedRulesAnonymousIpList"
          priority = 5

          override_action {

               none {}
            }

          statement {

               managed_rule_group_statement {
                   name        = "AWSManagedRulesAnonymousIpList"
                   vendor_name = "AWS"
                }
            }

          visibility_config {
               cloudwatch_metrics_enabled = true
               metric_name                = "AWSManagedRulesAnonymousIpList"
               sampled_requests_enabled   = true
            }
        }

      rule {
          name     = "AWSManagedRulesWindowsRuleSet"
          priority = 6

          override_action {

               none {}
            }

          statement {

               managed_rule_group_statement {
                   name        = "AWSManagedRulesWindowsRuleSet"
                   vendor_name = "AWS"
                }
            }

          visibility_config {
               cloudwatch_metrics_enabled = true
               metric_name                = "AWSManagedRulesWindowsRuleSet"
               sampled_requests_enabled   = true
            }
        }
  
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.primary_name}-nonprod-windows-web-acl"
    sampled_requests_enabled   = true
  }

}

#################################################################################################
####   WAF 
#################################################################################################

resource "aws_wafv2_web_acl" "cloudfront" {
      provider    = aws.course1-non-prod-us-east-1
      name        = "${var.primary_name}-nonprod-cloudfront-acl"
      description = "WAFv2 ACL for ${var.primary_name}-nonprod-cloudfront-acl"
      scope       = "CLOUDFRONT"

      default_action {
            allow {}
      }

      rule {
          name     = "AWSManagedRulesAmazonIpReputationList"
          priority = 0

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
          name     = "AWSManagedRulesKnownBadInputsRuleSet"
          priority = 2 

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
          name     = "AWSManagedRulesLinuxRuleSet"
          priority = 3

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
          name     = "AWSManagedRulesUnixRuleSet"
          priority = 5

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

        rule {
          name     = "AWSManagedRulesAnonymousIpList"
          priority = 6

          override_action {

               none {}
            }

          statement {

               managed_rule_group_statement {
                   name        = "AWSManagedRulesAnonymousIpList"
                   vendor_name = "AWS"
                }
            }

          visibility_config {
               cloudwatch_metrics_enabled = true
               metric_name                = "AWSManagedRulesAnonymousIpList"
               sampled_requests_enabled   = true
            }
        }
  
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.primary_name}-nonprod-cloudfront-acl"
    sampled_requests_enabled   = true
  }

}

resource "aws_wafv2_web_acl_logging_configuration" "cloudfront" {
  provider    = aws.course1-non-prod-us-east-1
  log_destination_configs = [aws_cloudwatch_log_group.cf-log-group.arn]
  resource_arn            = aws_wafv2_web_acl.cloudfront.arn
}

resource "aws_cloudwatch_log_group" "cf-log-group" {
  provider    = aws.course1-non-prod-us-east-1
  name              = "aws-waf-logs-${var.primary_name}-nonprod-cloudfront-acl"
  retention_in_days = 90
}