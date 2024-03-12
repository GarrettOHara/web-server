# web-server
Simple Flask API deployed with Terraform

# Customizing Server Logs Export to CloudWatch

This article has an in-depth explanation of the CloudWatch agent and how to configure it: [How To Push EC2 logs to CloudWatch \[Logs & Metrics\]](https://devopscube.com/how-to-setup-and-push-serverapplication-logs-to-aws-cloudwatch/)
To generate a custom CloudWatch agent configuration file run the following command and the setup wizard will guide you: 
```bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard
```

