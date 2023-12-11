# S3 Web Pipeline Module

Creates a Pipeline for the deployment of Web Services to S3. The environment variables are taken from the dependency bucket. The pipeline contains of  stages.
- source
- build
- deploy(s3)
- invalidate cdn cache

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
| dependency\_bucket | dependency bucket | `any` | n/a | yes |
| deployment\_bucket | deployment bucket | `any` | n/a | yes |
| distribution\_id | CDN distribution id | `any` | n/a | yes |
| environment | Specify the environment - dev/stg/prod | `any` | n/a | yes |
| invalidate\_lambda\_arn | invalidate lambda arn | `any` | n/a | yes |
| invalidate\_lambda\_id | invalidate lambda id | `any` | n/a | yes |
| project_prefix | Specify the project_prefix | `any` | n/a | yes |
| repo\_name | Repo Name | `any` | n/a | yes |
| repo\_url | Repo Url | `any` | n/a | yes |
| service\_name | service name | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| codepipeline\_arn | n/a |

