# Deploy Scalable VPC Architecture on AWS Cloud

## Table of Contents

1. [Goal](#goal)
2. [Pre-Requisites](#pre-requisites)
3. [Pre-Deployment](#pre-deployment)
4. [VPC Deployment](#vpc-deployment)
5. [Validation](#validation)
6. [Architecture Overview](#architecture-overview)

---

## Goal

To design and deploy a **modular, highly available, and scalable Virtual Private Cloud (VPC) architecture** using Amazon Web Services (AWS).

The architecture uses multiple VPCs, public and private subnets, a Transit Gateway, NAT Gateway, Bastion Host, Application Load Balancer, and Auto Scaling Group to provide secure networking, high availability, and scalability for web applications.

## Pre-Requisites

Before starting the deployment, ensure that you have the following:

1. An active [AWS Account](https://aws.amazon.com/) to create and manage infrastructure resources.
2. Basic knowledge of AWS networking, EC2, VPC, IAM, and Auto Scaling.
3. [Project Source Code](./html-web-app) for deploying the web application.
4. A registered domain name and Route 53 Hosted Zone (for domain-based access).

## Pre-Deployment

Prepare an Amazon EC2 instance with the required application dependencies and configurations. Create a **Golden AMI (Amazon Machine Image)** from the configured instance to use as the base image for application servers.

### Required Dependencies

1. **AWS CLI:** Command-line interface for managing AWS resources.
2. **Apache Web Server:** Install and configure Apache HTTP Server to host the web application.
3. **Git:** Install Git to clone or pull application source code from the Git repository.
4. **Amazon CloudWatch Agent:** Install and configure the agent for collecting system-level metrics and logs.
5. **Custom Memory Metrics:** Configure the CloudWatch Agent to publish custom memory utilization metrics to CloudWatch.
6. **AWS Systems Manager (SSM) Agent:** Install and configure the agent to enable secure instance access through AWS Systems Manager Session Manager.

### Golden AMI Creation

After installing and configuring all dependencies:

1. Verify that all required services are running.
2. Configure the application environment.
3. Ensure that the CloudWatch Agent and SSM Agent are functioning correctly.
4. Create an AMI from the configured EC2 instance.
5. Use this Golden AMI in the Launch Template for deploying application instances.

## VPC Deployment

Deploy the AWS infrastructure using the following steps.

### 1. VPC Creation

Create two separate VPC networks:

- **Bastion VPC:** `192.168.0.0/16` – Used for Bastion Host deployment and secure administrative access.
- **Application VPC:** `172.32.0.0/16` – Used for deploying highly available and auto-scalable application servers.

### 2. NAT Gateway Configuration

- Create a NAT Gateway in a public subnet of the Application VPC.
- Update the route table associated with private subnets.
- Route default outbound internet traffic (`0.0.0.0/0`) through the NAT Gateway.

This allows private EC2 instances to access the internet without exposing them directly to inbound internet traffic.

### 3. Transit Gateway Configuration

- Create an AWS Transit Gateway.
- Attach both the Bastion VPC and Application VPC to the Transit Gateway.
- Configure the required Transit Gateway route tables and VPC subnet route tables.
- Enable private communication between the two VPCs.

### 4. Internet Gateway Configuration

- Create an Internet Gateway (IGW) for each VPC.
- Attach each Internet Gateway to its respective VPC.
- Update the public subnet route tables.
- Add a default route (`0.0.0.0/0`) pointing to the Internet Gateway.

### 5. VPC Flow Logs Configuration

- Create an Amazon CloudWatch Log Group.
- Create two separate Log Streams to store Flow Logs from both VPCs.
- Enable VPC Flow Logs for both VPCs.
- Configure the Flow Logs to publish network traffic information to the respective CloudWatch Log Streams.

### 6. Bastion Host Deployment

- Create a Security Group for the Bastion Host.
- Allow inbound SSH traffic on port `22` only from trusted public IP addresses.
- Launch an EC2 instance in the public subnet of the Bastion VPC.
- Associate an Elastic IP (EIP) with the instance.

The Bastion Host acts as a secure entry point for accessing private application instances.

### 7. Amazon S3 Bucket Creation

- Create an Amazon S3 bucket to store application-specific configuration files.
- Configure appropriate bucket permissions.
- Grant the application EC2 instances access only to the required S3 resources through an IAM Role.

**Note:** Avoid granting unnecessary S3 Full Access permissions.

### 8. Launch Template Creation

Create an EC2 Launch Template to define the configuration of application instances.

Configure the following:

| Configuration | Description |
|---|---|
| AMI | Previously created Golden AMI |
| Instance Type | `t3.micro` |
| User Data | Pull application code from Git repository and start Apache HTTP Server |
| IAM Role | Permissions for Session Manager and required S3 bucket access |
| Security Group | Allow SSH (22) from Bastion Host and HTTP (80) from permitted sources |
| Key Pair | Configure an EC2 key pair if SSH access is required |

**Note:** Launch Templates are used instead of the deprecated Launch Configuration approach.

### 9. Auto Scaling Group (ASG) Creation

Create an Auto Scaling Group using the Launch Template.

Configure the following:

- Minimum Capacity: `2`
- Maximum Capacity: `4`
- Deploy instances across two private subnets in different Availability Zones.
- Configure the desired capacity according to application requirements.
- Enable health checks and scaling policies.

This provides high availability and automatic scaling based on application demand.

### 10. Target Group Creation

- Create an Elastic Load Balancing Target Group.
- Configure the target type as Instances.
- Set the protocol to HTTP and port to `80`.
- Configure appropriate health check settings.
- Associate the Target Group with the Auto Scaling Group.

### 11. Application Load Balancer (ALB) Creation

- Create an Application Load Balancer.
- Configure it as an internet-facing load balancer.
- Deploy it across public subnets in multiple Availability Zones.
- Configure its Security Group to allow HTTP/HTTPS traffic.
- Associate the previously created Target Group with the ALB.

The ALB distributes incoming application traffic across healthy EC2 instances.

### 12. Route 53 Configuration

- Open Amazon Route 53.
- Select the appropriate Hosted Zone.
- Create a DNS record pointing to the Application Load Balancer.
- Use an Alias A record or an appropriate CNAME record to route application traffic to the ALB.

Users can now access the application using the configured domain name.

---

## Validation

After completing the deployment, perform the following validation steps to ensure that the architecture is functioning correctly.

### 1. Bastion Host Connectivity

- Connect to the Bastion Host using SSH and its Elastic IP.
- Verify that the instance is accessible.

### 2. Private Instance Connectivity

- Access private EC2 instances through the Bastion Host.
- Verify that SSH connectivity works between the Bastion Host and private instances.

### 3. AWS Systems Manager Validation

- Open the AWS Management Console.
- Navigate to Systems Manager → Session Manager.
- Select a private EC2 instance.
- Start a session and verify that the EC2 shell is accessible without requiring direct inbound SSH access.

### 4. Web Application Validation

- Open a web browser from a public internet connection.
- Enter the configured domain name.
- Verify that the web application loads successfully.
- Confirm that the Application Load Balancer forwards requests to healthy EC2 instances.

### 5. High Availability and Auto Scaling Validation

- Verify that the Auto Scaling Group maintains the configured minimum capacity.
- Confirm that instances are distributed across multiple Availability Zones.
- Check the Target Group health status.
- Verify that the ALB distributes traffic to healthy instances.

### 6. Monitoring and Logging Validation

- Open Amazon CloudWatch.
- Verify that custom memory metrics are being published.
- Check EC2 monitoring metrics.
- Verify that VPC Flow Logs are being delivered to the configured CloudWatch Log Group and Log Streams.

---

## Architecture Overview

The project implements a scalable AWS infrastructure with the following major components:

- **Amazon VPC:** Isolated networking environments.
- **Public and Private Subnets:** Network segmentation and security.
- **Internet Gateway:** Public internet connectivity.
- **NAT Gateway:** Outbound internet access for private instances.
- **Transit Gateway:** Private communication between multiple VPCs.
- **Bastion Host:** Secure administrative access to private instances.
- **Amazon EC2:** Application hosting.
- **Golden AMI:** Standardized application server configuration.
- **Launch Template:** Reusable EC2 instance configuration.
- **Auto Scaling Group:** Automatic scaling and high availability.
- **Application Load Balancer:** Intelligent traffic distribution.
- **Amazon S3:** Application configuration storage.
- **Amazon Route 53:** DNS management.
- **Amazon CloudWatch:** Monitoring, metrics, and logging.
- **AWS Systems Manager:** Secure instance management.

---

**Project:** Deploy Scalable VPC Architecture on AWS Cloud

**Cloud Provider:** Amazon Web Services (AWS)

**Key Services:** VPC, EC2, IAM, S3, Transit Gateway, NAT Gateway, ALB, ASG, Route 53, CloudWatch, and Systems Manager.
