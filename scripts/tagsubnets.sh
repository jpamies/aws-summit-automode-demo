#!/bin/bash

# Run ./tagsubnets.sh VPC_ID
# VPC ID should be provided as an argument
VPC_ID=$1

if [ -z "$VPC_ID" ]; then
    echo "Please provide a VPC ID"
    echo "Usage: $0 vpc-id"
    exit 1
fi

# Tag public subnets and map public IP addresses (looking for "public" in the Name tag)
aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Name,Values=*public*" \
    --query 'Subnets[*].SubnetId' \
    --output text | tr '\t' '\n' | \
while read -r subnet; do
    echo "Tagging public subnet: $subnet"
    aws ec2 create-tags \
        --resources "$subnet" \
        --tags Key=kubernetes.io/role/elb,Value=1
    
    echo "Enabling auto-assign public IP on subnet: $subnet"
    aws ec2 modify-subnet-attribute \
        --subnet-id "$subnet" \
        --map-public-ip-on-launch
done

# Tag private subnets (looking for subnets without "public" in the Name tag)
aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Name,Values=*private*" \
    --query 'Subnets[*].SubnetId' \
    --output text | tr '\t' '\n' | \
while read -r subnet; do
    echo "Tagging private subnet: $subnet"
    aws ec2 create-tags \
        --resources "$subnet" \
        --tags Key=kubernetes.io/role/internal-elb,Value=1
done