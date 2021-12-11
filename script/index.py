import os
import json
import boto3
import uuid
from datetime import datetime, timedelta

s3_cient = boto3.client('s3')
dynamodb = boto3.client('dynamodb')
dynamodbtable = os.environ['DynamoDBTable']

def lambda_handler(event, context):
    bucket_name = event["Records"][0]["s3"]["bucket"]["name"]
    s3_file_name = event["Records"][0]["s3"]["object"]["key"]
    resp = s3_cient.get_object(Bucket=bucket_name, Key=s3_file_name)
    currentdt = datetime.now()
    recordttl = datetime.now() + timedelta(hours=4) 
    recordttlepoch = round(recordttl.timestamp())
    
    data = resp['Body'].read().decode('utf-8')
    csvrecords = data.split("\n")
    records = len(list(csvrecords))
    
    # Write some logs to Cloudwatch
    print("File to process:"+str(s3_file_name))
    print("Records to process:"+str(records))    
    
    for record in csvrecords:
        record = record.split(",")
        uID = uuid.uuid4().hex # Generate a unique identifier for every record.
        try:
            dynamodb.put_item(
                TableName=dynamodbtable, 
                    Item={
                        'countUUID':{'S': uID},
                        'recordTTL':{'N': str(recordttlepoch)},
                        'currentDT':{'S': str(currentdt)},
                        'FirstName': {'S': str(record[0])},
                        'LastName': {'S': str(record[1])},
                        'Email': {'S': str(record[2])},
                        'Randomstring': {'S': str(record[3])},
                        'Age': {'S': record[4]}
                     })                  
        except Exception as err:
            print ("Error!!! "+str(err))
        else:
            s3_cient.delete_object(Bucket=bucket_name, Key=s3_file_name) # Remove/Comment this line if you don't want to delete the uploaded .csv file
            