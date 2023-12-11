<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 0.14.4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ecs_service.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.td](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_service_discovery_service.sds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_service) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_assign_public_ip"></a> [assign\_public\_ip](#input\_assign\_public\_ip) | Assign a public IP address to the ENI (Fargate launch type only) | `bool` | `false` | no |
| <a name="input_container_name"></a> [container\_name](#input\_container\_name) | Name of the container | `string` | n/a | yes |
| <a name="input_container_platform"></a> [container\_platform](#input\_container\_platform) | Set of launch types required by the task. The valid values are EC2 and FARGATE | `string` | `"FARGATE"` | no |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | Container port | `number` | `0` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | CPU limit to be assigned for container | `number` | `256` | no |
| <a name="input_deployment_maximum_percent"></a> [deployment\_maximum\_percent](#input\_deployment\_maximum\_percent) | An upper limit on the number of tasks in a service that are allowed in the RUNNING or PENDING state during a deployment, as a percentage of the desired number of tasks | `number` | `200` | no |
| <a name="input_deployment_minimum_percent"></a> [deployment\_minimum\_percent](#input\_deployment\_minimum\_percent) | A lower limit on the number of tasks in a service that must remain in the RUNNING state during a deployment, as a percentage of the desired number of tasks | `number` | `100` | no |
| <a name="input_desired_container_count"></a> [desired\_container\_count](#input\_desired\_container\_count) | Desired container count | `number` | `1` | no |
| <a name="input_ecs_cluster"></a> [ecs\_cluster](#input\_ecs\_cluster) | ECS Cluster Id | `string` | n/a | yes |
| <a name="input_ecs_security_groups"></a> [ecs\_security\_groups](#input\_ecs\_security\_groups) | List of security groups for ECS | `list(string)` | n/a | yes |
| <a name="input_ecs_subnets"></a> [ecs\_subnets](#input\_ecs\_subnets) | List of subnets for ECS Service | `list(string)` | n/a | yes |
| <a name="input_entrypoint"></a> [entrypoint](#input\_entrypoint) | ENTRYPOINT for Dockerfile | `list(string)` | `[]` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Name of the environment e.g dev, test, prod | `string` | `"test"` | no |
| <a name="input_environment_vars"></a> [environment\_vars](#input\_environment\_vars) | Key-Value pair for environment variables in container | `map(string)` | `{}` | no |
| <a name="input_expose_ssh_port"></a> [expose\_ssh\_port](#input\_expose\_ssh\_port) | Boolean to decide whether to expose ssh port for container or not | `bool` | `false` | no |
| <a name="input_image"></a> [image](#input\_image) | ARN of the ECR image with tag | `string` | n/a | yes |
| <a name="input_log_group_name"></a> [log\_group\_name](#input\_log\_group\_name) | Name of the cloudwatch group name | `string` | n/a | yes |
| <a name="input_memory"></a> [memory](#input\_memory) | Memory limit to be assigned for container | `number` | `512` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the ECS Service | `string` | n/a | yes |
| <a name="input_network_mode"></a> [network\_mode](#input\_network\_mode) | Network mode for ECS Service e.g awsvpc, bridge, host etc | `string` | `"awsvpc"` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | Name or email id of the owner of the resource | `string` | `""` | no |
| <a name="input_platform_version"></a> [platform\_version](#input\_platform\_version) | Platform version for ECS | `string` | `"LATEST"` | no |
| <a name="input_repo_secret"></a> [repo\_secret](#input\_repo\_secret) | Secret ARN for private repository | `string` | `""` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | Key-Value pair of the secrets | `map(string)` | `{}` | no |
| <a name="input_service_discovery_namespace_id"></a> [service\_discovery\_namespace\_id](#input\_service\_discovery\_namespace\_id) | Namespace Id of the Service Discovery | `string` | `""` | no |
| <a name="input_target_group_arns"></a> [target\_group\_arns](#input\_target\_group\_arns) | List of ARNs of Target Groups | `list(string)` | `[]` | no |
| <a name="input_task_execution_role_arn"></a> [task\_execution\_role\_arn](#input\_task\_execution\_role\_arn) | Task Execution Role ARN | `string` | n/a | yes |
| <a name="input_task_role_arn"></a> [task\_role\_arn](#input\_task\_role\_arn) | Task Role ARN to be assumed by containers | `string` | `""` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->