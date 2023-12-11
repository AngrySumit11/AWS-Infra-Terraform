//resource "aws_mq_broker" "aws_mq" {
//  broker_name = "${var.primary_name}-${var.environment}-course1-mq"
//
//  engine_type        = "ActiveMQ"
//  engine_version     = "5.15.15"
//  host_instance_type = "mq.m5.large"
//  subnet_ids         = ["subnet-01f097fe3493720fc"]
//  security_groups    = [aws_security_group.activemq.id]
//  deployment_mode    = "SINGLE_INSTANCE"
//
//  user {
//    username = "course1"
//    password = random_string.activemq_password.result
//  }
//
//  configuration {
//    id       = aws_mq_configuration.aws_mq_config.id
//    revision = aws_mq_configuration.aws_mq_config.latest_revision
//  }
//
//  logs {
//    audit = true
//    general = true
//  }
//
//  tags = merge(
//    var.common_tags,
//    {
//      "Name" = "${var.primary_name}-${var.environment}-course1-mq"
//    }
//  )
//}
//
//resource "aws_mq_configuration" "aws_mq_config" {
//  description    = "ActiveMQ Configuration"
//  name           = "${var.primary_name}-${var.environment}-course1-mq-config"
//  engine_type    = "ActiveMQ"
//  engine_version = "5.15.0"
//  tags = merge(
//    var.common_tags,
//    {
//      "Name" = "${var.primary_name}-${var.environment}-course1-mq-config"
//    }
//  )
//
//  data = <<DATA
//<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
//<broker xmlns="http://activemq.apache.org/schema/core">
//  <plugins>
//    <forcePersistencyModeBrokerPlugin persistenceFlag="true"/>
//    <statisticsBrokerPlugin/>
//    <timeStampingBrokerPlugin ttlCeiling="86400000" zeroExpirationOverride="86400000"/>
//  </plugins>
//</broker>
//DATA
//
//}
//
//resource "random_string" "activemq_password" {
//  length  = 32
//  special = false
//}
//
//output "activemq_password" {
//  sensitive   = false
//  value       = random_string.activemq_password.result
//  description = "The master password for aws ActiveMQ"
//}
//
//resource "aws_security_group" "activemq" {
//  description = "AWS ActiveMQ SG"
//  name        = format("%s-%s-activemq-sg", var.primary_name, var.environment)
//  vpc_id      = var.vpc_id
//
//  tags = {
//    "Name"        = format("%s-%s-activemq-sg", var.primary_name, var.environment),
//    "Environment" = var.environment
//  }
//}
//
//resource "aws_security_group_rule" "activemq-allow-eks" {
//  type                     = "ingress"
//  from_port                = 61614
//  to_port                  = 61614
//  protocol                 = "tcp"
//  source_security_group_id = aws_security_group.ext-svc-internal.id
//  security_group_id        = aws_security_group.activemq.id
//}
//
//resource "aws_security_group_rule" "activemq-allow-eks-1" {
//  type                     = "ingress"
//  from_port                = 61614
//  to_port                  = 61614
//  protocol                 = "tcp"
//  source_security_group_id = module.eks.cluster_primary_security_group_id
//  security_group_id        = aws_security_group.activemq.id
//}
//
//resource "aws_security_group_rule" "activemq-allow-jumpbox" {
//  type                     = "ingress"
//  from_port                = 61614
//  to_port                  = 61614
//  protocol                 = "tcp"
//  source_security_group_id = module.jumpbox.jumpbox-sg-id
//  security_group_id        = aws_security_group.activemq.id
//}
