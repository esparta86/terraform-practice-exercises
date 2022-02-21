output "api_gateway_id" {
  value = aws_api_gateway_rest_api.api_gateway.id
}


output "hello_prod" {
  value = "${aws_api_gateway_stage.prod.invoke_url}/hello"
}