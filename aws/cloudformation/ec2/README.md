
### Look for latest Amazon Linux 2 AMI
```
aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn*" --query 'sort_by(Images, &CreationDate)[].Name'
```

### Get unpredictable ( not always ) block devices
```
curl http://169.254.169.254/latest/meta-data/block-device-mapping
```
