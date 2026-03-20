resource "aws_iam_user" "lab_user" {
  count = var.enable_iam_lab ? 1 : 0
  name  = var.iam_lab_user_name

  tags = {
    Purpose = "iam-lab"
  }
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    sid     = "AllowEC2AssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_role" {
  count              = var.enable_iam_lab ? 1 : 0
  name               = "${var.project}-${var.environment}-iam-lab-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Purpose = "iam-lab"
  }
}

resource "aws_iam_instance_profile" "ec2_profile" {
  count = var.enable_iam_lab ? 1 : 0
  name  = "${var.project}-${var.environment}-iam-lab-ec2-profile"
  role  = aws_iam_role.ec2_role[0].name
}
