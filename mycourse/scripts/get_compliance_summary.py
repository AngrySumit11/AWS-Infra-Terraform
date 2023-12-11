import boto3
session = boto3.session.Session(profile_name="course1-billing", region_name="us-east-1")
client = session.client("resourcegroupstaggingapi")

response = client.get_compliance_summary(
    TargetIdFilters=[
        'accountid', '265288707677'
    ],
    RegionFilters=[
        'us-west-2', 'ap-southeast-1'
    ],
    GroupBy=[
        'TARGET_ID',
    ]
)
print(response)
