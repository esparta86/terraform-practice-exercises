data "archive_file" "zip" {
  type = "zip"
  source_file = "../lambda/hello.js"
  output_path = "../lambda/hello.zip"
}

resource "aws_lambda_function" "hello" {
  filename = data.archive_file.zip.output_path
  source_code_hash = filebase64sha256(data.archive_file.zip.output_path)


  function_name = var.project_function_name

  role = aws_iam_role.lambda_role.arn

  handler = "hello.handler"

  runtime = "nodejs12.x"

  timeout = 10
}

resource "aws_lambda_alias" "alias_prod" {
    name = "prod"
    description = "production"
    function_name = aws_lambda_function.hello.arn

    function_version = "$LATEST"
  
}