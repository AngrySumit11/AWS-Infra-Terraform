################ Persistence Service Pipeline ################################################
module "persistence_service_pipeline" {
  source              = "../../../../course1/modules/service-pipeline"
  environment         = var.environment
  project_prefix      = var.project_prefix
  repo_name           = var.list_of_services[2]
  repo_url            = var.persistence_svc_repo_url
  branch_name         = var.persistence_svc_branch_name
  artifact_bucket     = var.artifact_bucket
  build_timeout       = var.build_timeout
  ecs_cluster_name    = var.ecs_cluster_name
  environment_bucket  = var.environment_bucket
  service_name        = var.persistence_svc_service_name
  container_name      = var.list_of_services[2]
  repository_uri      = var.persistence_ecs_repository_uri
  ecs_service_name    = var.list_of_services[2]
  cb_vpc_id           = var.vpc_id
  cb_subnets          = data.aws_subnet_ids.private_services.ids
  cb_security_groups  = [aws_security_group.noingress.id]
  notify_sns_arn      = aws_sns_topic.codepipeline_status.arn
  approve_sns_arn     = ""
  production_approval = var.production_approval
}

################ Integration Service Pipeline ################################################
module "integration_service_pipeline" {
  source              = "../../../../course1/modules/service-pipeline"
  environment         = var.environment
  project_prefix      = var.project_prefix
  repo_name           = var.list_of_services[1]
  repo_url            = var.integration_svc_repo_url
  branch_name         = var.integration_svc_branch_name
  artifact_bucket     = var.artifact_bucket
  build_timeout       = var.build_timeout
  ecs_cluster_name    = var.ecs_cluster_name
  environment_bucket  = var.environment_bucket
  service_name        = var.integration_svc_service_name
  container_name      = var.list_of_services[1]
  repository_uri      = var.integration_ecs_repository_uri
  ecs_service_name    = var.list_of_services[1]
  cb_vpc_id           = var.vpc_id
  cb_subnets          = data.aws_subnet_ids.private_services.ids
  cb_security_groups  = [aws_security_group.noingress.id]
  notify_sns_arn      = aws_sns_topic.codepipeline_status.arn
  approve_sns_arn     = ""
  production_approval = var.production_approval
}

########################### Notification Service Pipeline#######################################
module "notification_service_pipeline" {
  source              = "../../../../course1/modules/service-pipeline"
  environment         = var.environment
  project_prefix      = var.project_prefix
  repo_name           = var.list_of_services[3]
  repo_url            = var.notification_svc_repo_url
  branch_name         = var.notification_svc_branch_name
  artifact_bucket     = var.artifact_bucket
  build_timeout       = var.build_timeout
  ecs_cluster_name    = var.ecs_cluster_name
  environment_bucket  = var.environment_bucket
  service_name        = var.notification_svc_service_name
  container_name      = var.list_of_services[3]
  repository_uri      = var.notification_ecs_repository_uri
  ecs_service_name    = var.list_of_services[3]
  cb_vpc_id           = var.vpc_id
  cb_subnets          = data.aws_subnet_ids.private_services.ids
  cb_security_groups  = [aws_security_group.noingress.id]
  notify_sns_arn      = aws_sns_topic.codepipeline_status.arn
  approve_sns_arn     = ""
  production_approval = var.production_approval
}

####################### course1App Pipeline ######################################################
module "course1app_service_pipeline" {
  source              = "../../../../course1/modules/service-pipeline"
  environment         = var.environment
  project_prefix      = var.project_prefix
  repo_name           = var.list_of_services[0]
  repo_url            = var.course1app_svc_repo_url
  branch_name         = var.course1app_svc_branch_name
  artifact_bucket     = var.artifact_bucket
  build_timeout       = var.build_timeout
  ecs_cluster_name    = var.ecs_cluster_name
  environment_bucket  = var.environment_bucket
  service_name        = var.course1app_svc_service_name
  container_name      = var.list_of_services[0]
  repository_uri      = var.course1app_ecs_repository_uri
  ecs_service_name    = var.list_of_services[0]
  cb_vpc_id           = var.vpc_id
  cb_subnets          = data.aws_subnet_ids.private_services.ids
  cb_security_groups  = [aws_security_group.noingress.id]
  notify_sns_arn      = aws_sns_topic.codepipeline_status.arn
  approve_sns_arn     = ""
  production_approval = var.production_approval
  codebuild_image     = "aws/codebuild/standard:5.0"
}

####################### course1Upload Pipeline ######################################################
module "course1upload_service_pipeline" {
  source              = "../../../../course1/modules/service-pipeline"
  environment         = var.environment
  project_prefix      = var.project_prefix
  repo_name           = var.list_of_services[4]
  repo_url            = var.course1upload_svc_repo_url
  branch_name         = var.course1upload_svc_branch_name
  artifact_bucket     = var.artifact_bucket
  build_timeout       = var.build_timeout
  ecs_cluster_name    = var.ecs_cluster_name
  environment_bucket  = var.environment_bucket
  service_name        = var.course1upload_svc_service_name
  container_name      = var.list_of_services[4]
  repository_uri      = var.course1upload_ecs_repository_uri
  ecs_service_name    = var.list_of_services[4]
  cb_vpc_id           = var.vpc_id
  cb_subnets          = data.aws_subnet_ids.private_services.ids
  cb_security_groups  = [aws_security_group.noingress.id]
  notify_sns_arn      = aws_sns_topic.codepipeline_status.arn
  production_approval = var.production_approval
  approve_sns_arn     = ""
}

#################### Admin Web Pipeline ############################

module "admin-web-pipeline" {
  source                = "../../../../course1/modules/web-pipeline"
  project_prefix        = var.project_prefix
  environment           = var.environment
  web_app_env           = var.web_app_env
  repo_name             = var.admin_web_repo_name
  repo_url              = var.admin_web_repo_url
  branch_name           = var.admin_web_branch_name
  artifact_bucket       = var.artifact_bucket
  build_timeout         = var.build_timeout
  service_name          = var.admin_web_service_name
  environment_bucket    = var.environment_bucket
  deployment_bucket     = var.admin_web_deployment_bucket
  distribution_id       = aws_cloudfront_distribution.s3_course1admin_distribution.id
  invalidate_lambda_id  = var.invalidate_lambda_id
  invalidate_lambda_arn = var.invalidate_lambda_arn
  notify_sns_arn        = aws_sns_topic.codepipeline_status.arn
  approve_sns_arn       = ""
  production_approval   = var.production_approval
}


#################### Serverless Pipeline ############################

module "serverless-pipeline" {
  source              = "../../../../course1/modules/serverless-pipeline"
  project_prefix      = var.project_prefix
  environment         = var.environment
  repo_name           = var.serverless_repo_name
  repo_url            = var.serverless_repo_url
  branch_name         = var.serverless_branch_name
  artifact_bucket     = var.artifact_bucket
  build_timeout       = var.build_timeout
  service_name        = var.serverless_service_name
  environment_bucket  = var.environment_bucket
  cb_vpc_id           = var.vpc_id
  cb_subnets          = data.aws_subnet_ids.private_services.ids
  cb_security_groups  = [aws_security_group.noingress.id]
  notify_sns_arn      = aws_sns_topic.codepipeline_status.arn
  approve_sns_arn     = ""
  production_approval = var.production_approval
}
