import logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    request = event['Records'][0]['cf']['request']    
    headers = request['headers']
    method = request['method']
    country_code = headers['cloudfront-viewer-country'][0]['value']
    if method in ['PUT', 'POST', 'PATCH']:
        request['origin']['custom']['domainName'] = 'course1-dev-usw2.apps.course1.net'
    elif method in ['GET', 'HEAD', 'OPTIONS']:
        if country_code in ['IN', 'SG', 'CN', 'HK', 'TW']:
            request['origin']['custom']['domainName'] = 'course1-dev-apse1.apps.course1.net'
        else:
            request['origin']['custom']['domainName'] = 'course1-dev-usw2.apps.course1.net'
    return request
