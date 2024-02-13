terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
}

data "aws_ecr_repository" "lambda_ecr_repo" {
  name = "lambda-ecr-repo"
}

resource "aws_sqs_queue" "sqs_queue" {
  name                      = "sqs_queue"
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.queue_deadletter.arn
    maxReceiveCount     = 4
  })

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.queue_deadletter.arn]
  })

  tags = {
    Environment = "dev"
  }
}

resource "aws_sqs_queue" "queue_deadletter" {
  name = "queue_deadletter"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "policy_for_lambda" {
  name = "policy_for_lambda"
  role = aws_iam_role.iam_for_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:*",
          "ecr:*",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ChangeMessageVisibility"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_lambda_function" "lambda_function" {
  function_name = "lambda_function"
  role          = aws_iam_role.iam_for_lambda.arn
  timeout       = 5 # seconds
  image_uri     = "${data.aws_ecr_repository.lambda_ecr_repo.repository_url}:latest"
  package_type  = "Image"
}

resource "aws_lambda_event_source_mapping" "lambda_function_event" {
  event_source_arn = aws_sqs_queue.sqs_queue.arn
  function_name    = aws_lambda_function.lambda_function.arn
}
