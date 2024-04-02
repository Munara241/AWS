!#/bin/bash

region="us-east-2"
vpc_cidr="10.0.0.0/16"
subnet1_cidr="10.0.1.0/24"
subnet2_cidr="10.0.2.0/24"
subnet3_cidr="10.0.3.0/24"

vpc_id=$(aws ec2 create-vpc --cidr-block $vpc_cidr --region $region --query Vpc.VpcId --output text)

subnet_id=$(aws ec2 create-subnet --vpc-id $vpc_id --cidr-block $subnet1_cidr --region $region --query Subnet.SubnetId --output text)
subnet_id=$(aws ec2 create-subnet --vpc-id $vpc_id --cidr-block $subnet2_cidr --region $region --query Subnet.SubnetId --output text)
subnet_id=$(aws ec2 create-subnet --vpc-id $vpc_id --cidr-block $subnet3_cidr --region $region --query Subnet.SubnetId --output text)

igw_id=$(aws ec2 create-internet-gateway --region $region --query InternetGateway.InternetGatewayId --output text)

aws ec2 attach-internet-gateway --vpc-id $vpc_id --internet-gateway-id $igw_id --region $region

rt=$(aws ec2 create-route-table --vpc-id $vpc_id  --region $region --query RouteTable.RouteTableId --output text)

aws ec2 create-route --route-table-id $rt --destination-cidr-block 0.0.0.0/0 --gateway-id $igw_id --region $region

aws ec2 associate-route-table --subnet-id $subnet_id --route-table-id $rt --region $region

sg=$(aws ec2 create-security-group --group-name EC2SecurityGroup --description "Demo Security Group" --vpc-id $vpc_id --region $region --query GroupId --output text)

aws ec2 authorize-security-group-ingress --group-id $sg --protocol tcp --port 22 --cidr 0.0.0.0/0 --region $region


key_pair=$(aws ec2 create-key-pair --key-name EC2KeyPair --query "KeyMaterial" --output text > EC2KeyPair.pem)

sudo chmod 400 $key_pair

aws ec2 run-instances --image-id ami-087c17d1fe0178315 --count 1 --instance-type t2.micro --key-name EC2KeyPair  --security-group-ids $sg --subnet-id $subnet_id --associate-public-ip-address --tag-specifications ResourceType=instance,Tags=[{Key=Name,Value=Demo-EC2}]
