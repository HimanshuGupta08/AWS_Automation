import os
import requests
import json

url_base = 'https://api.xdr.trendmicro.com'
url_path = '/beta/cloudPosture/scanTemplate'
token = os.getenv('TOKEN')

# Read content from the JSON file
file_path = 'plan.json'  # Update this path as necessary
with open(file_path, 'r') as file:
    content = file.read()

query_params = {}
headers = {
    'Authorization': 'Bearer ' + token,
    'Content-Type': 'application/json;charset=utf-8'
}
body = {
    'type': 'terraform-template',
    'content': content,
    'arguments': [
        {
            'name': 'YOUR_NAME (string)',
            'value': 'YOUR_VALUE (string)'
        }
    ],
    'pseudoArguments': {
        'awsAccountId': 'YOUR_AWSACCOUNTID (string)',
        'awsNotificationARNs': 'YOUR_AWSNOTIFICATIONARNS (array)',
        'awsRegion': 'YOUR_AWSREGION (string)',
        'awsStackName': 'YOUR_AWSSTACKNAME (string)'
    }
}

r = requests.post(url_base + url_path, params=query_params, headers=headers, json=body)

print(r.status_code)
for k, v in r.headers.items():
    print(f'{k}: {v}')
print('')
if 'application/json' in r.headers.get('Content-Type', '') and len(r.content):
    response_data = r.json()
else:
    response_data = r.text
    print(response_data)

# Filtering the JSON data and counting risk levels
if isinstance(response_data, dict) and 'scanResults' in response_data:
    filtered_results = []
    risk_counts = {
        "LOW": 0,
        "MEDIUM": 0,
        "HIGH": 0
    }
    seen_combinations = set()
    
    for result in response_data['scanResults']:
        if result['status'] == 'FAILURE':
            combination_key = (result['resource'], result['ruleTitle'])
            if combination_key not in seen_combinations:
                seen_combinations.add(combination_key)
                filtered_result = {
                    "ruleId": result['ruleId'],
                    "provider": result['provider'],
                    "ruleTitle": result['ruleTitle'],
                    "riskLevel": result['riskLevel'],
                    "status": result['status'],
                    "service": result['service'],
                    "description": result['description'],
                    "resource": result['resource'],
                    "resourceType": result['resourceType'],
                    "region": result['region'],
                    "tags": result['tags'] if 'tags' in result else [],
                    "notScored": result['notScored'],
                    "resolutionPageUrl": result['resolutionPageUrl']
                }
                if 'resourceId' in result:
                    filtered_result["resourceId"] = result['resourceId']
                else:
                    filtered_result["resourceId"] = None
                
                filtered_results.append(filtered_result)
                
                # Count the risk levels
                risk_level = result['riskLevel'].upper()
                if risk_level in risk_counts:
                    risk_counts[risk_level] += 1

    # Print the filtered results
    for result in filtered_results:
        print(json.dumps(result, indent=4))
    
    # Print the risk level counts
    print("\nRisk Level Counts:")
    for risk_level, count in risk_counts.items():
        print(f"{risk_level}: {count}")
else:
    print("No valid JSON response or 'scanResults' not in response.")
