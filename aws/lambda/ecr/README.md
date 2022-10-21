# ECR repository auto-provision

The target of these resources is the creation of ECR repositories on-demand, after the Lambda function is triggered from a push failure to a non-existent ECR repository ( Eventbridge event )

## Build lambda code package

```bash
cd src
zip lambda_function_payload.zip lambda_function.py
```

## Create resources

```bash
terraform validate
terraform init
terraform apply
```

## Test

```
PASS=$(aws ecr get-login-password)
docker login -u AWS -p "$PASS" https://484308071187.dkr.ecr.eu-central-1.amazonaws.com/test

docker pull alpine:3.12
docker tag alpine:3.12 484308071187.dkr.ecr.eu-central-1.amazonaws.com/test/alpine:3.12
docker push 484308071187.dkr.ecr.eu-central-1.amazonaws.com/test/alpine:3.12

aws ecr describe-repositories | jq -r '.repositories[]|select(.repositoryName == "test/alpine")'
```

