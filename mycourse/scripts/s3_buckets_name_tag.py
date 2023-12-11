import boto3

accounts = ['course1-prod']
regions = ['us-west-2']


def tag_bucket(s3_client, bucket_name):
    try:
        tag_set = s3_client.get_bucket_tagging(Bucket=bucket_name)['TagSet']
    except:
        tag_set = []
    name_tag_exist = False
    for tag in tag_set:
        if tag['Key'] == 'Name':
            name_tag_exist = True
    if not name_tag_exist:
        tag = s3_client.put_bucket_tagging(
            Bucket=bucket_name,
            Tagging={'TagSet': tag_set + [{'Key': 'Name', 'Value': bucket_name}]}
        )
        print("Added/Updated tags for S3 Bucket %s " % bucket_name)


def main():
    for account in accounts:
        print("######################### Running for account : %s #########################" % account)
        for region in regions:
            print("############### Running for region : %s ###############" % region)
            session = boto3.session.Session(profile_name=account)
            s3_client = session.client('s3', region_name=region)
            # s3_resource = session.resource('s3', region_name=region)
            s3_buckets = s3_client.list_buckets()['Buckets']
            for bucket in s3_buckets:
                tag_bucket(s3_client, bucket['Name'])


if __name__ == "__main__":
    main()
