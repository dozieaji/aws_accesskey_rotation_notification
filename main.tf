terraform {
  required_version = ">= 0.12"
   
}

provider "aws" {
  region = var.aws_region
}


resource "aws_iam_role" "AwslambdaFunction" {
  name = "AwslambdaFunction"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
  
resource "aws_iam_role_policy" "awsLabdaFinctionTrigger" {
  name      = "awsLabdaFinctionTrigger"
  role = aws_iam_role.AwslambdaFunction.name
 
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ses:SendEmail",
                "iam:ListAccessKeys"
            ],
            "Resource": [
                "arn:aws:iam::179079437960:user/*",
                "arn:aws:ses:us-west-2:179079437960:identity/*"
            ]
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "iam:ListUsers",
            "Resource": "*"
        }
    ]
}
POLICY
}

locals{
  lambda_zip_location = "outputs/tf_lambda.zip"
}

data "archive_file" "zipit" {
  type        = "zip"
  source_file = "tf_lambda/tf_lambda.py"
  output_path = "${local.lambda_zip_location}"
}



resource "aws_lambda_function" "test_lambda" {
  filename          = "${local.lambda_zip_location}"
  function_name     = "tf_lambda"
  role              = aws_iam_role.AwslambdaFunction.arn
  handler           = "tf_lambda.lambda_handler"
  source_code_hash  = "${filebase64sha256(local.lambda_zip_location)}"
  runtime           = "python3.7"

}













# resource "aws_lambda_function" "terraform_lambda" {
#   filename      = "tf_lambda.zip"
#   function_name = "tf_lambda.py"
#   role          = aws_iam_role.AwslambdaFunction.name
# handler = "tf_lambda.lambda_handler"
#   source_code_hash = filebase64sha256("tf_lambda.zip")
#   runtime = "python3.6"
# }