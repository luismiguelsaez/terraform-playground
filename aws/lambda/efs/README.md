
### Create package
```
cd code
zip -r ../lambda_function.zip .
cd ..
```

### Deploy
```
❯ AWS_PROFILE=**** AWS_REGION=us-east-1 terraform apply -auto-approve
```