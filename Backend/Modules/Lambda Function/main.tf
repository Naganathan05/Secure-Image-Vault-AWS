resource "aws_iam_role" "lambda_role" {
  name = "lambda role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

data "aws_iam_policy_document" "dynamodb_access" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:UpdateItem"
    ]
    resources = [
      aws_dynamodb_table.visitor_count.arn
    ]
  }
}

resource "aws_iam_role_policy_attachment" "dynamodb_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  role       = aws_iam_role.lambda_role.name
}

resource "aws_lambda_function" "count" {
  filename      = "Count.zip"
  function_name = "count"
  handler       = "count.lambda_handler"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "nodejs14.x"
}

resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowMyDemoAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.count.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.rest_api.execution_arn}/*"
}