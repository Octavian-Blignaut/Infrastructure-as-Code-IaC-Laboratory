data "aws_iam_policy_document" "s3_read" {
  statement {
    sid     = "AllowListBucket"
    effect  = "Allow"
    actions = ["s3:ListBucket"]

    resources = [
      var.assets_bucket_arn
    ]
  }

  statement {
    sid     = "AllowGetObjects"
    effect  = "Allow"
    actions = ["s3:GetObject"]

    resources = [
      "${var.assets_bucket_arn}/*"
    ]
  }
}

resource "aws_iam_policy" "s3_read" {
  count       = var.enable_iam_lab ? 1 : 0
  name        = "${var.project}-${var.environment}-iam-lab-s3-read"
  description = "IAM lab policy: read-only access to assets bucket"
  policy      = data.aws_iam_policy_document.s3_read.json
}
