resource "aws_iam_user_policy_attachment" "user_s3_read" {
  count      = var.enable_iam_lab ? 1 : 0
  user       = aws_iam_user.lab_user[0].name
  policy_arn = aws_iam_policy.s3_read[0].arn
}

resource "aws_iam_role_policy_attachment" "ec2_s3_read" {
  count      = var.enable_iam_lab ? 1 : 0
  role       = aws_iam_role.ec2_role[0].name
  policy_arn = aws_iam_policy.s3_read[0].arn
}
