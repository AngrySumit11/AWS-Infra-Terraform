#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import boto3

session = boto3.session.Session(profile_name="course1-prod")
client = session.client("workspaces")
workspaces = []
for workspace in workspaces:
    response = client.describe_workspaces(
        WorkspaceIds=[
            workspace,
        ]
    )
    print(
        "arn:aws:workspaces:us-west-2:accountid:workspace/" + workspace,
        "\t",
        response["Workspaces"][0]["UserName"],
    )
