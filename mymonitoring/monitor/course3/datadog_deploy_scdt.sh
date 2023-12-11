#!/bin/bash
#Variables for cluster where the datadog instance needs to be created
DD_API_KEY=$1
DD_APP_KEY=$2
DD_API_KEY_EKS=$3
DD_APP_KEY_EKS=$4
AWS_ACCOUNT_ID="accountid"
AWS_ACCOUNT="course3-prod"

#Below helm command deploys the required Datadog agents to the cluster needs to be monitored
helm repo add datadog https://helm.datadoghq.com
helm repo update
CLUSTER_NAMES="course3-prod course3-prod-apse1 course3-prod-apse1-hub course3-prod-hub"
for CLUSTER in $CLUSTER_NAMES; do
    #set the kube context
    kubectl config use-context $CLUSTER
    helm upgrade --install -f ../helm/$CLUSTER/values.yaml data-dog-agent  --set datadog.apiKey=$DD_API_KEY_EKS,datadog.appKey=$DD_APP_KEY_EKS,datadog.clusterName=$CLUSTER  datadog/datadog --set targetSystem=linux  
done

#Applying terraform changes for AWs account integration and monitor creation
terraform init
#Review the changes that will be made
terraform plan -var="account_id=$AWS_ACCOUNT_ID" -var="datadog_api_key=$DD_API_KEY" -var="datadog_app_key=$DD_APP_KEY" -var="aws_account=$AWS_ACCOUNT"
#Apply the changes if everything looks good
terraform apply -var="account_id=$AWS_ACCOUNT_ID" -var="datadog_api_key=$DD_API_KEY" -var="datadog_app_key=$DD_APP_KEY" -var="aws_account=$AWS_ACCOUNT"