##############################################################################
# environments/dev/terraform.tfvars
#
# Non-secret default values for the dev environment.
# DO NOT commit real passwords – use TF_VAR_db_password or a secrets manager.
##############################################################################

aws_region = "us-east-1"
project    = "iaclab"

# Replace with the actual AMI ID for your region (Amazon Linux 2023):
#   aws ssm get-parameter --name /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 --query Parameter.Value --output text
ami_id = "ami-0c02fb55956c7d316"

# db_password is intentionally NOT set here.
# Supply it via: export TF_VAR_db_password="<secret>"
# or via your CI/CD secrets manager.

# IAM lab (optional)
# enable_iam_lab  = true
# iam_lab_user_name = "iaclab-dev-iam-user"
