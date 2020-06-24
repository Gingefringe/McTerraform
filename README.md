# McTerraform - A terraform'ed Minecraft server (with auto-destroy on inactivity)

Deploy Minecraft server using terraform to AWS.

Uses lambda functions to auto-destroy a Minecraft server instance after inactivity. S3 is used for Minecraft world backups and for storing terraform state.

Future functionality:
* add Discord bot for both starting and stopping the Minecraft instance

## Prerequisites
* An AWS account with user credentials for programmatic access
  * See <https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html#id_users_create_console>
* Download and install terraform from <https://www.terraform.io/downloads.html>
* For running the scripted setup of the Terraform resources: I
  * Install the AWS CLI (v1) at <https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html>
* For local development (optional):
  * Install python 3.7, and pip

## Configuration

### AWS Deployment
* Create IAM credentials for programmatic access and add locally [as named AWS credential](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html) to `~/.aws/credentials`

```txt
~/.aws/credentials

[<YOU_INITIALS>]
aws_access_key_id = <AWS_ACCESS_KEY_ID>
aws_secret_access_key = <AWS_SECRET_ACCESS_KEY>
```

* Create a [EC2 key](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html) via the AWS console and name it `minecraft`
* Update the following files with your credentials and your region and an unique name for your S3 bucket for Terraform state:
   * `config/account.tfvars`
   * `iac/mc-static/config.tf`
   * `iac/mc-server/config.tf`
   * `src/mc-destroy.tf` (Look for `TF Variables` and `MC backup bucket`)
   * Suggestion: Find and replace `hlgr360` with `<YOU_INITIALS>`
* Run `./init_tf_req.sh`in the root of the locally cloned repo

### Optional: Local environment for development
* Install virtualenv: `sudo pip install virtualenv`
* Change into source directory `cd src`
* Activate venv: `. venv/bin/activate`
* Install dependencies: `pip install -r requirements.txt`

### Optional: Deployment Options
* Copy [latest Minecraft server download URL](https://www.minecraft.net/en-us/download/server/) into `src/mc-server.sh`.

### Deployment Initialisation
* Init terraform:
  * Run `terraform init` in `iac/mc-static`
  * Run `terraform init` in `iac/mc-server`

## Deployment
### Static Resources (only once)
The static resources are allocated only once and normally not needed to be changed again.

* Change to static infrastructure setup: `cd iac/mc-static`
* Execute: `terraform apply -var-file=../../config/account.tfvars` - if prompted type `yes`
* Creates: S3 bucket for Minecraft World backup, Public IP, SNS topic plus attached Lambda for auto-destroy

### Server Resources (when starting the server)
* Change to server infrastructure setup: `cd iac/mc-server`
* Execute: `terraform apply -var-file=../../config/account.tfvars` - if prompted type `yes`
* Creates: Minecraft Server with attached Public IP

## How it all works
Beyond the allocation of AWs resources, the terraform script triggers modification of the ec2 instance. It installs the Minecraft server, downloads the S3 backed-up minecraft world to the local instance, and add's a crontab script for detecting idle state. Once idle state has been detected, it triggers a backup of the current minecraft world to S3, and triggering the destruction of the ec2 instance by sending an empty message on the SNS destroy topic.

Attached to the SNS Topic is a lambda function, which downloads and installs terraform locally within the lambda context and executes a 'terraform destroy' on the server resources.

## Misc
### Debugging
* Logging into ec2 instance using the EC2 key: `ssh -i ~/.ssh/minecraft.pem ec2-user@<eip>`
* Listing available screen sessions: `screen -ls`
* Re-attaching to minecraft screen session: `screen -r minecraft`

### Updating Minecraft
* Add new Minecraft version download URL in `src/mc-setup.sh`
* Remove `eula.txt` file in root of minecraft backup S3 bucket
* Re-apply terraform with `terraform apply -var-file=../config/account.tfvars`

### Additional links
* https://www.codingforentrepreneurs.com/blog/install-django-on-mac-or-linux - installing python on MacOS
* https://jeremievallee.com/2017/03/26/aws-lambda-terraform.html - deploying AWS Lambda with terraform
