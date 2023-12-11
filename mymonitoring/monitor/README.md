# datadog-integration
This repository contains the Terraform scripts and the helm chart values used for integrating Datadog with various AWS accounts and maintaining the alert configuration

Steps to run:
- Navigate to the folder related to the environment where we need to deploy the changes
- Run the deployment shell script in the following format: ./DEPLOYMENT_SHELL_SCRIPT.sh DATADOG_API_KEY DATADOG_APP_KEY DATADOG_EKS_API_KEY DATADOG_EKS_APP_KEY

What running the scripts does:
- The helm charts will configure the datadog cluster agents and the node agents to Datadog instances based on the APP key and API key provided.
- The terraform scripts will integrate the AWS account with the respective Datadog instance based on the APP key and the API key supplied.
- The terraform scripts will also create the app monitors and the infra monitors.