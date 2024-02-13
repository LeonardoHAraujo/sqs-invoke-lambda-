# SQS invoke lambda (with pipeline and terraform)

*Powered by Leonardo Araújo*

> Example using Node.js + terraform and github pipelines.

## Required global dependencies

- Node.js v16+
- Terraform
- AWS CLI
- 
## Create an ECR Repo

Go to AWS ECR serviçe and create an private repo with name `lambda-ecr-repo`;

## Configure AWS CLI

1. Run following command:

```terminal
touch ~/.aws/credentials
```

2. Put content (get keys in AWS IAM):

```terminal
[default]
aws_access_key_id = <your credential>
aws_secret_access_key = <your credential>
```

## Run terraform

1. Run following commanads:

```terminal
cd iac
terraform init
terraform plan
terraform apply -auto-approve
```

2. In your github repository you will create three secrets:


```terminal
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_ECR_URL=
```

3. In your github, create a repository and run commands:

```terminal
git init
git add .
git commit -m "initial commit."
git remote add origin <your repo url>
git push -U origin main
```

4. Now, wait for end pipeline.

```terminal
Build and Push ----> Deploy lambda
```

## Tree structure

```terminal
.
├──.github
│    └── workflows
│        └── build_and_deploy.yaml
├── Dockerfile
├── iac
│   ├── main.tf
│   ├── terraform.tfstate
│   └── terraform.tfstate.backup
├── Readme.md
└── src
    └── index.js

```

## License

MIT