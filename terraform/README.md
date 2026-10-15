# Terraform: deploy the app to AWS EC2

This folder deploys the `mini-devops-lab` container image to a single EC2
instance on AWS. Everything is created with Terraform and removed with one
`terraform destroy`.

## What it creates

| Resource | Purpose |
|---|---|
| Security group | Allows port 5000 from **my IP only**, all outbound traffic |
| EC2 instance (`t3.micro`) | Amazon Linux 2023, public IP, IMDSv2 required |
| User data script | On first boot: installs Docker and runs `ghcr.io/ghaith-bl/mini-devops-lab:latest` |

The latest Amazon Linux 2023 AMI and the default VPC are looked up with data
sources (nothing is hardcoded).

## Files

| File | Content |
|---|---|
| `versions.tf` | Terraform and AWS provider versions |
| `providers.tf` | AWS provider, region and default tags |
| `variables.tf` | Input variables |
| `data.tf` | AMI and default VPC lookups |
| `security.tf` | Security group and its rules |
| `ec2.tf` | The EC2 instance |
| `user_data.sh` | Bootstrap script run on first boot |
| `outputs.tf` | Instance ID, public IP and app URL |

## Inputs

| Variable | Default | Description |
|---|---|---|
| `region` | `eu-north-1` | AWS region |
| `my_ip` | none (required) | Your public IPv4, allowed to reach port 5000 |

## Requirements

- Terraform
- AWS CLI with an active session (credentials are read from the AWS CLI)

## Usage

```bash
cd terraform
terraform init

# Your public IP (keep VPN on/off the same until testing)
curl -s https://checkip.amazonaws.com

# Set it in a local file (ignored by git)
echo 'my_ip = "YOUR_IP"' > terraform.tfvars

terraform plan
terraform apply
```

Wait 1 to 2 minutes for Docker to install and the container to start, then:

```bash
curl -i "$(terraform output -raw app_url)"
curl -i "$(terraform output -raw app_url)/health"
```

## Debugging without SSH

There is no SSH access on purpose. Read the boot log from the console output:

```bash
aws ec2 get-console-output \
  --instance-id "$(terraform output -raw instance_id)" \
  --latest --output text | tail -n 50
```

## Clean up

Always destroy when done, so nothing keeps running:

```bash
terraform destroy
terraform state list   # should print nothing
```

## Notes

- `terraform.tfvars` and the state files are in `.gitignore`
  (they can contain personal or sensitive data).
- Tested: app reachable from my IP, boot log shows Docker install and container start.
- Possible improvements: standard CPU credits for `t3`, encrypted root volume,
  SSM Session Manager instead of SSH, remote state.
