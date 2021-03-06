# Import CSV To DynamoDB with Lambda


This Lambda function (Python) imports the content of an uploaded .csv file from S3 into DynamoDB. The function is only triggered when a .csv file is uploaded to the specific S3 bucket, which will be created. Resources are created with Terraform as visualized with the following image.

<p align="center">
  <img alt="Infrastructure" src="assets/images/infrastructure.png">
</p>

---

## Python script
The Python script is pretty straight forward. It loads some modules and reads the event (triggered from S3 when a .csv file is uploaded), sets some variables (ex. recordttlepoch for DynamoDB Time to Live (TTL). After splitting the row, it writes the row values to the DynamoDB Table with a unique identifier and current date time value. After completion, the script will delete the processed file(s). This behavior can be changed by deleting / commenting out the line line ```s3_cient.delete_object...``` in the file [script/index.py](script/index.py). 

### Warning!
>***The included Python script will delete your uploaded CSV file(s), once the records are imported to DynamoDB. If you wish to keep the file(s), comment/delete the line ```s3_cient.delete_object...``` from python script. 
DynamoDB has also a record TTL set to 4 hours! Disable this behavior by changing the value of ttl attribute `enabled` to ```false``` in file [DynamoDB.tf](DynamoDB.tf)***

---

## Prequest

You need the following to run the code:

- [Terraform >= 1.0.11](https://www.terraform.io/downloads.html) If you are on a Mac and use brew, just run ```brew update && brew  install terraform```
- [AWS Account](https://aws.amazon.com) (Create an account and add a role with 'AdministratorAccess' role. We will use this to create the resources)
- Code editor (eg. [Visual Studio Code](https://code.visualstudio.com/download))

---
### AWS Authentication 
The AWS provider offers a flexible means of providing credentials for authentication. [Visit Terraform Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication) for all possibilities.

For this exercise, we will use the Static credentials method, adding variables `aws_key`, `aws_secret` & `aws_region`. You need to set these in the file [variables.tf](variables.tf)  

## Terraform files
Terraform will create all resources using the settings from the following files:

- [IAM.tf](IAM.tf)
  - Inline Policy ( with permissions to S3, Cloudwatch and DynamoDB )
  - Assume Role Policy (for Lambda )
- [S3.tf](S3.tf) 
  - S3 Bucket
- [DynamoDB.tf](DynamoDB.tf)
  - DynamoDB Table with ***[Time to Live (TTL)](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/TTL.html)*** (Dissable this by changing the value of ttl attribute `enabled` to false in file [DynamoDB.tf](DynamoDB.tf))
- [Lambda.tf](Lambda.tf)
  - Creats the .zip file (using ${aws_resource_name_tag} as file name) for the Lambda function (script/index.py)
  - Creates the Lambda function using Python 3.8 runtime and sets environment variables which can be used by the Lambda function
- [Cloudwatch.tf](Cloudwatch.tf)
  - Loggroup with 7 days retention setting

---

## Create resources
1. Download this repository or use ```git clone https://github.com/erecica/csv-to-dynamodb-with-lambda.git```  
2. Open the downloaded repository with your favorite code editor
2. Set variables in the file [variables.tf](variables.tf)
3. Run terraform script
```sh
terraform init
terraform plan
terraform apply
```

After running `terraform apply` (or `terraform apply --auto-approve` This skips interactive approval of plan before applying), the script will create all the necessary resources.

Once the resources are created ( about 30 seconds ), you should see the following output.
+ AWS_DynamoDB_Table = "DynamoDB Table name"
+ AWS_Region         = "AWS Region you enterd"
+ AWS_S3bucket       = "S3 Bucket name you just created" 

---

### Testing

You can test the application with the included files in directory [test files](assets/testfiles/) within the assets folder. You can upload multiple files and/or folders at once. Please keep in mind the max execution timeout of the Lambda function. Currently set to ```60 seconds```.

If you wish to use your own csv files, you must meet the following condition:
  - File should be .csv
  - File should have the following structure
  ```sh 
    string,string,string,string,number
  ```

---

## Cleanup
Execute the following command in your terminal and confirm to delete all created resources.
```sh
terraform destroy
```
