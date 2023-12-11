# Service Pipeline Module

Creates Pipeline for the deployment of Services to ECS. The environment variables are taken from the dependency bucket. The pipeline contains of  stages.
- source
- build
- deploy (ECS)

## Resources Created
- aws_iam_role
- aws_iam_role_policy
- aws_codebuild_project
- aws_codebuild_source_credential
- aws_codebuild_webhook
- aws_codepipeline

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| artifact\_bucket | Artifact Bucket Name | `any` | n/a | yes |
| bitbucket\_password | Bitbucket Password | `any` | n/a | yes |
| bitbucket\_username | Bitbucket Username | `any` | n/a | yes |
| branch\_name | Branch Name | `any` | n/a | yes |
| build\_timeout | CodeBuild Build timeout | `any` | n/a | yes |
| container\_name | container name | `any` | n/a | yes |
| environment\_bucket | Environment bucket | `any` | n/a | yes |
| ecs\_cluster\_name | ECS Cluster Name | `any` | n/a | yes |
| environment | Specify the environment - dev/stg/prod | `any` | n/a | yes |
| project_prefix | Specify the project_prefix | `any` | n/a | yes |
| repo\_name | Repo Name | `any` | n/a | yes |
| repo\_url | Repo Url | `any` | n/a | yes |
| repository\_uri | repository uri | `any` | n/a | yes |
| service\_name | Service Name | `any` | n/a | yes |

## Outputs

No output.

