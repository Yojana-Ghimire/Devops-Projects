Deploy Scalable VPC Architecture on AWS Cloud

<img width="1740" height="1070" alt="image" src="https://github.com/user-attachments/assets/3a182ca9-415f-4f8d-870e-612a412ede68" />


TABLE OF CONTENTS
Goal
Pre-Requisites
Pre-Deployment
VPC Deployment
Validation
Goal
Deploy a Modular and Scalable Virtual Network Architecture with Amazon VPC.

Pre-Requisites
You must be having an AWS account to create infrastructure resources on AWS cloud.
Source Code
Pre-Deployment
Customize the application dependencies mentioned below on AWS EC2 instance and create the Golden AMI.

AWS CLI
Install Apache Web Server
Install Git
Cloudwatch Agent
Push custom memory metrics to Cloudwatch.
AWS SSM Agent
VPC Deployment
Build VPC network ( 192.168.0.0/16 ) for Bastion Host deployment as per the architecture shown above.
Build VPC network ( 172.32.0.0/16 ) for deploying Highly Available and Auto Scalable application servers as per the architecture shown above.
Create NAT Gateway in Public Subnet and update Private Subnet associated Route Table accordingly to route the default traffic to NAT for outbound internet connection.
Create Transit Gateway and associate both VPCs to the Transit Gateway for private communication.
Create Internet Gateway for each VPC and Public Subnet associated Route Table accordingly to route the default traffic to IGW for inbound/outbound internet connection.
Create Cloudwatch Log Group with two Log Streams to store the VPC Flow Logs of both VPCs.
Enable Flow Logs for both VPCs and push the Flow Logs to Cloudwatch Log Groups and store the logs in the respective Log Stream for each VPC.
Create Security Group for bastion host allowing port 22 from public.
Deploy Bastion Host EC2 instance in the Public Subnet with EIP associated.
Create S3 Bucket to store application specific configuration.
Create Launch Template with below configuration (replacing deprecated Launch Configuration).
Golden AMI
Instance Type – t3.micro (updated from t2.micro for better performance)
Userdata to pull the code from Git Repository to document root folder of webserver and start the httpd service.
IAM Role granting access to Session Manager and to S3 bucket created in the previous step to pull the configuration. (Do not grant S3 Full Access)
Security Group allowing port 22 from Bastion Host and Port 80 from Public.
Key Pair
Create Auto Scaling Group with Min: 2 Max: 4 with two Private Subnets associated to multiple AZs for high availability.
Create Target Group and associate it with ASG.
Create Application Load Balancer (ALB) in Public Subnets for better layer 7 routing and add Target Group as target.
Update route53 hosted zone with CNAME record routing the traffic to ALB.
Validation
As DevOps Engineer login to Private Instances via Bastion Host.
Login to AWS Session Manager and access the EC2 shell from console.
Browse web application from public internet browser using domain name and verify that page loaded.
