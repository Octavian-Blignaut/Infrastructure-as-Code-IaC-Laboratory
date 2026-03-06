##############################################################################
# environments/prod/terraform.tfvars
#
# Non-secret default values for the prod environment.
# DO NOT commit real passwords – use TF_VAR_db_password or a secrets manager.
##############################################################################

aws_region = "us-east-1"
project    = "iaclab"

# Replace with the latest hardened / approved AMI for production.
ami_id = "ami-0c02fb55956c7d316"

# db_password must be supplied at plan/apply time via:
#   export TF_VAR_db_password="$(aws secretsmanager get-secret-value ...)"
