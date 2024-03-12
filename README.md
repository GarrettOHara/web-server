# Web Server
Simple Flask API hosted on AWS deployed with Terraform

Terraform includes:
- Automated code deployment of Flask API and respective HTML templates
- CloudWatch log exports of server's log file

# Deploy Terraform

### Prerequisites

- Install Terraform, for instructions see the [HashiCorp Documentation](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- Configure AWS credentials via `aws configure` or set a local profile: 
    - For more information on setting up AWS credentials, please visit the AWS official Documentation
        - Via aws configure: [Configure the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)
        - Via credential file: [Configuration and credential file settings](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
    - Example:
        - Create your credentials file if it doesn't already exist
        ```bash
        touch ~/.aws/credentials
        ```
        - Configure AWS access keys
        ```bash
        [<PROFILE_NAME>]
        aws_access_key_id = <ACCESS_KEY>
        aws_secret_access_key = <SECRET_ACCESS_KEY>
        ```
        - Set profile as environment variable for Terraform to reference
        ```bash
        export AWS_PROFILE=<PROFILE_NAME>
        ```
### Deployment

Please make sure you are familiar with Terraform deployments and how to remidy any issues with provider versions or local Terraform versions. Reference the HashiCorp official documentation
    - [Terraform Providers](https://developer.hashicorp.com/terraform/language/providers)
    - [Terraform Apply](https://developer.hashicorp.com/terraform/cli/commands/apply)

Navigate from the project root directory to the root level module
```bash
cd app-server
```
Download required providers for this module by initializing the terraform environment
```bash
terraform init
```
Run a Terraform plan to see the desired configuration 
```bash
terraform plan -out plan.tfplan
```
After carefully reviewing the plan and ensuring your AWS IAM Role you are assuming from the configured profile has the correct access to the target environment, deploy the resources
```bash
terraform apply plan.tfplan
```
# Visit Web Page
The EC2 instance has been configured to allow HTTP traffic directly from the internet via public IPv4 DNS and public IPv4. It will be up to you to register a domain and configure the DNS in your DNS manager to ensure the site is reachable via a CNAME or common name record like google.com.

The outputs of the module will provide you with both the IPv4 and DNS common name you can use to view the live website: 
```
Outputs:

instance_id = "i-<SOME_STRING>"
public_dns = "<SOME_SUBDOMAINS>.compute.amazonaws.com"
public_ipv4_addr = "<SOME_IPv4_ADDRESS>"
```
To view the web page, simply 
```bash 
curl <PUBLIC_IPv4_OR_PUBLIC_DNS>
```
Or render the HTML via a web browser. Ensure you do not attempt to navigate with SSL/TLS via port `443`, this configuration only supports `HTTP` non-encrypted protocol via port `80`.

### TODO

Add support for SSL/TLS encrpyption.

# Troublshooting 

### Check web-server initialization logs:

To check the output of running `user-data.sh` on deployment, connect via SSM to the EC2 instance from the console and view the logs file with: 
```bash
sudo cat /var/log/cloud-init-output.log
```
[Reference: How to check whether my user data passing to EC2 instance is working](https://stackoverflow.com/questions/15904095/how-to-check-whether-my-user-data-passing-to-ec2-instance-is-working)

# Customizing Server Logs Export to CloudWatch

This article has an in-depth explanation of the CloudWatch agent and how to configure it: [How To Push EC2 logs to CloudWatch \[Logs & Metrics\]](https://devopscube.com/how-to-setup-and-push-serverapplication-logs-to-aws-cloudwatch/)
To generate a custom CloudWatch agent configuration file run the following command and the setup wizard will guide you: 
```bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard
```

### Checking the CloudWatch Agent Configuration File
```bash
sudo cat /opt/aws/amazon-cloudwatch-agent/bin/config.json
```

### View Logs via CloudWatch Insights Log Query

From the AWS Console, you can view the CloudWatch Log group `web-server/requests.log` and then navigate to the respective log group stream(s). To aggregate all log group streams, run this query: 
```
fields @timestamp, @message
| sort @timestamp desc
| limit 10000
```

