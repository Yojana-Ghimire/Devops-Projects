
module "vpc" {
  source = "../modules/aws-vpc"

  vpc-name = var.VPC-NAME
  vpc-cidr = var.VPC-CIDR

  igw-name = var.IGW-NAME

  public-cidr1   = var.PUBLIC-CIDR1
  public-subnet1 = var.PUBLIC-SUBNET1
  public-cidr2   = var.PUBLIC-CIDR2
  public-subnet2 = var.PUBLIC-SUBNET2

  private-cidr1   = var.PRIVATE-CIDR1
  private-subnet1 = var.PRIVATE-SUBNET1
  private-cidr2   = var.PRIVATE-CIDR2
  private-subnet2 = var.PRIVATE-SUBNET2

  public-rt-name1  = var.PUBLIC-RT-NAME1
  public-rt-name2  = var.PUBLIC-RT-NAME2
  private-rt-name1 = var.PRIVATE-RT-NAME1
  private-rt-name2 = var.PRIVATE-RT-NAME2
}

module "security-group" {
  source = "../modules/security-group"

  vpc-name    = var.VPC-NAME
  alb-sg-name = var.ALB-SG-NAME
  web-sg-name = var.WEB-SG-NAME
  db-sg-name  = var.DB-SG-NAME

  depends_on = [module.vpc]
}

module "iam" {
  source = "../modules/aws-iam"

  iam-role              = var.IAM-ROLE
  iam-policy            = var.IAM-POLICY
  instance-profile-name = var.INSTANCE-PROFILE-NAME

  depends_on = [module.security-group]
}

module "ec2" {
  source = "../modules/aws-ec2"

  ami_name = var.AMI-NAME

  instance-profile-name = var.INSTANCE-PROFILE-NAME
  web-sg-name           = var.WEB-SG-NAME

  public-subnet-name = var.PUBLIC-SUBNET1

  depends_on = [
    module.iam,
    module.security-group
  ]
}

module "rds" {
  source = "../modules/aws-rds"

  sg-name              = var.SG-NAME
  private-subnet-name1 = var.PRIVATE-SUBNET1
  private-subnet-name2 = var.PRIVATE-SUBNET2
  db-sg-name           = var.DB-SG-NAME

  rds-username = var.RDS-USERNAME
  rds-pwd      = var.RDS-PWD
  db-name      = var.DB-NAME
  rds-name     = var.RDS-NAME

  depends_on = [module.security-group]
}

module "alb" {
  source = "../modules/alb-tg"

  public-subnet-name1 = var.PUBLIC-SUBNET1
  public-subnet-name2 = var.PUBLIC-SUBNET2

  web-alb-sg-name = var.ALB-SG-NAME
  alb-name        = var.ALB-NAME
  tg-name         = var.TG-NAME
  vpc-name        = var.VPC-NAME

  depends_on = [
    module.ec2,
    module.security-group
  ]
}

module "route53" {
  source = "../modules/aws-cloudfront-acm-route53"

  domain-name = var.DOMAIN-NAME
  cdn-name    = var.CDN-NAME
  alb-name    = var.ALB-NAME

  depends_on = [module.alb]
}
