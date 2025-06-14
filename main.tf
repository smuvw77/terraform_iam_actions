# 1. Assume Role Policy for EC2
data "aws_iam_policy_document" "assume_role_ec2" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# 2. IAM Role
resource "aws_iam_role" "my_role" {
  name               = "sri-actions1--custom-managed-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_ec2.json
}

# 3. Custom Policy Document (CloudWatch logs example)
data "aws_iam_policy_document" "custom_logs_policy_doc" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    #resources = ["arn:aws:logs:*:*:*"]
  }
}

# 4. Create Custom Managed Policy
resource "aws_iam_policy" "custom_logs_policy" {
  name   = "sri-actions1-CustomCloudWatchLogsPolicy"
  policy = data.aws_iam_policy_document.custom_logs_policy_doc.json
}

# 5. Attach Custom Managed Policy to Role
resource "aws_iam_role_policy_attachment" "custom_policy_attach" {
  role       = aws_iam_role.my_role.name
  policy_arn = aws_iam_policy.custom_logs_policy.arn
}

# 6. Attach AWS-Managed Policy to Role
resource "aws_iam_role_policy_attachment" "managed_policy_attach" {
  role       = aws_iam_role.my_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}