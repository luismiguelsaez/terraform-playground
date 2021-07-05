### Get VPC and subnet
```
❯ aws ec2 describe-vpcs --profile cmpdevel --region us-east-1 | jq -r '.Vpcs[]|.VpcId'

❯ aws ec2 describe-subnets --filters "Name=vpc-id,Values=vpc-0c430da91788d0c7c" --profile cmpdevel --region us-east-1 | jq -r '.Subnets[]|select(.MapPublicIpOnLaunch)|.SubnetId'
