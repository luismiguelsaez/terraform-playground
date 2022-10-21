
## Build lambda code package

```bash
cd src
zip lambda_function_payload.zip lambda_function.py
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

