module "cloudfront_wafv2" {
  source        = "trussworks/wafv2/aws"
  version       = "2.4.0"
  managed_rules = []
  name          = "${var.primary_name}-${var.service}-${var.environment}-lb-web-acl"
  scope         = "REGIONAL"
  associate_alb = var.associate_lb_to_wafv2
  alb_arn       = aws_lb.lb.arn
  ip_sets_rule = [
    {
      name       = "AWSWAFSecurityAutomationsWhitelistRule"
      action     = "allow"
      priority   = 1
      ip_set_arn = aws_wafv2_ip_set.ipset.arn
    },
    {
      name       = "AWSWAFSecurityAutomationsBlacklistRule"
      action     = "block"
      priority   = 2
      ip_set_arn = aws_wafv2_ip_set.ipset2.arn
    }
  ]


  ip_rate_based_rule = {
    name : "AWSWAFSecurityAutomationsHttpFloodRateBasedRule",
    priority : 4
    action : "block"
    limit : 1000
  }

}



resource "aws_wafv2_ip_set" "ipset" {
  name               = "AWSWAFSecurityWhitelistSetIPV4-${var.environment}"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"

}


resource "aws_wafv2_ip_set" "ipset1" {
  name               = "AWSWAFSecurityWhitelistSetIPV6-${var.environment}"
  scope              = "REGIONAL"
  ip_address_version = "IPV6"

}


resource "aws_wafv2_ip_set" "ipset2" {
  name               = "AWSWAFSecurityBlacklistSetIPV4-${var.environment}"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"

}


resource "aws_wafv2_ip_set" "ipset3" {
  name               = "AWSWAFSecurityBlacklistSetIPV6-${var.environment}"
  scope              = "REGIONAL"
  ip_address_version = "IPV6"

}



