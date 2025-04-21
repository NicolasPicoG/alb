.DEFAULT_GOAL ?= help
.PHONY: help

help:
	@echo "${Project}"
	@echo "${Description}"
	@echo ""
	@echo "Deploy using:"
	@echo "  make deploy - Deploy the stack"
	@echo "  make tear-down - Destroy the stack"

###################### Parameters ######################
# Environment Name
Env := "dev"
# Website / Project Name
Project := "pocalb"
# Project Description
Description := "aws-internal-static-web-hosting"
# AWS Region were the stack will be deployed
AWSRegion := "us-east-1"
# Website Domain Name
DomainName := "app.clouddevapp.com"
# Route53 Hosted ZoneId
HostedZoneId := "Z008209324DOK7DJC7VFT"
# ACM Certificate Arn
ACMCertificateArn := "arn:aws:acm:us-east-1:381492081993:certificate/e850f924-6583-4a94-9626-0f8980344551"
# VPC Id
VpcId := "vpc-0a5c0a5649761b5c6"
# VPC Cidr Block
VpcCidrBlock := "10.0.0.0/16"
# Private Subnet 1
PrivateSubnetId1 := "subnet-00b2322f0d4f1dcd1"
# Private Subnet 2
PrivateSubnetId2 := "subnet-06b0d62e710bd3831"
#######################################################

infra:
	aws cloudformation deploy \
		--template-file ./template.yml \
		--region ${AWSRegion} \
		--stack-name ${Project}-internal-static-web-hosting-${Env} \
		--capabilities CAPABILITY_IAM \
		--parameter-overrides \
			pEnv=${Env} \
			pProject=${Project} \
			pDescription="${Description}" \
			pDomainName=${DomainName} \
			pACMCertificateArn=${ACMCertificateArn} \
			pVpcId=${VpcId} \
			pVpcCidrBlock=${VpcCidrBlock} \
			pPrivateSubnetId1=${PrivateSubnetId1} \
			pPrivateSubnetId2=${PrivateSubnetId2} \
			pHostedZoneId=${HostedZoneId} \
		--no-fail-on-empty-changeset

deploy: infra
	@aws s3 cp ./assets/index.html s3://${DomainName}/

tear-down:
	@read -p "Are you sure that you want to destroy stack '${Project}-internal-static-web-hosting-${Env}'? [y/N]: " sure && [ $${sure:-N} = 'y' ]
	@aws s3 rm s3://${DomainName}/index.html
	aws cloudformation delete-stack --stack-name "${Project}-internal-static-web-hosting-${Env}"