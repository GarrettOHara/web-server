# Web Server
Simple Flask API hosted on AWS deployed with Terraform

Terraform includes:
- Automated code deployment of Flask API and respective HTML templates
- CloudWatch log exports of server's log file

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

