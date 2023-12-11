import boto3
import csv

accounts = ['']
regions = ['ap-northeast-1']


def print_loggroup(log_groups, region, account):
    for logGroup in log_groups:
        finalrow = dict()
        finalrow['LogGroupName'] = logGroup['logGroupName']
        try:
            finalrow['RetentionInDays'] = logGroup['retentionInDays']
        except:
            finalrow['RetentionInDays'] = ""
        finalrow['StoredBytes'] = float(logGroup['storedBytes'])/(1024 * 1024 * 1024)
        finalrow['Region'] = region
        finalrow['Account'] = account

        tags = client.list_tags_log_group(
            logGroupName=logGroup['logGroupName']
        )
        writer.writerow(finalrow)


csvfile = open('cloudwatch-loggroup.csv', 'w')
fieldnames = ["LogGroupName", "RetentionInDays", "StoredBytes", "Region", "Account"]
writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
writer.writeheader()

for account in accounts:
    for region in regions:
        session = boto3.session.Session(profile_name=account)
        client = session.client('logs', region_name=region)
        response = client.describe_log_groups()
        print_loggroup(response['logGroups'], region, account)
        try:
            nextToken = response['nextToken']
        except:
            nextToken = ''
        while nextToken:
            response = client.describe_log_groups(nextToken=nextToken)
            print_loggroup(response['logGroups'], region, account)
            try:
                nextToken = response['nextToken']
            except:
                nextToken = ''
