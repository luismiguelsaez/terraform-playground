
## Find a suitable AMI
```
aws ec2 describe-images --filters "Name=architecture,Values=x86_64" "Name=state,Values=available" "Name=name,Values=amzn2-ami-hvm-2.0.????????.?-x86_64-gp2" --query "sort_by(Images, &CreationDate)"
``` 