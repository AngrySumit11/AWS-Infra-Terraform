accounts = {
    'course1-poc': {
        'us-west-2': [],
        'ap-southeast-1': []
    },
    'course1-non-prod': {
        'us-west-2': ['ec2', 'rds', 's3', 'cloudwatch', 'ecr', 'eks', 'elb', 'elbv2', 'guardduty', 'kms', 'sqs']
    },
    'course1-prod': {
        'us-west-2': []
    },
    'course1-non-prod': {
        'us-west-2': []
    },
    'course1-prod': {
        'us-west-2': []
    }
}

directory = "aws-inventory"
for account, regions in accounts.items():
    # region_command = ""
    for region, services in regions.items():
        # region_command += " --region " + region
        service_command = ""
        for service in services:
            service_command += " --service " + service
        if service_command:
            print("aws-list-all query -c " + account + " -d ./" + directory + "/" + account + "/ --region " + region + service_command)

# aws-list-all query -c course1-non-prod -d ./aws-inventory/course1-non-prod --region us-west-2 --service ec2