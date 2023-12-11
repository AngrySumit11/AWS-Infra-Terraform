import boto3

accounts = ['course1-prod']
regions = ['us-west-2']

def main():
    for account in accounts:
        print("######################### Running for account : %s #########################" % account)
        for region in regions:
            print("############### Running for region : %s ###############" % region)
            session = boto3.session.Session(profile_name=account)
            workspaces_client = session.client('workspaces', region_name=region)

            workspaces = workspaces_client.describe_workspaces()
            NextToken = workspaces["NextToken"]
            workspaces_list = workspaces['Workspaces']

            while NextToken:
                try:
                    next_workspaces = workspaces_client.describe_workspaces(NextToken=NextToken)
                    NextToken = next_workspaces["NextToken"]
                    workspaces_list = workspaces_list + next_workspaces['Workspaces']
                except:
                    break
            for workspace in workspaces_list:
                print(workspace['WorkspaceId'])
                response = workspaces_client.create_tags(
                    ResourceId=workspace['WorkspaceId'],
                    Tags=[
                        {
                            'Key': 'Name',
                            'Value': workspace['WorkspaceId']
                        }
                    ]
                )


if __name__ == "__main__":
    main()
