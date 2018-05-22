resource "aws_api_gateway_rest_api" "chatbot" {
  name        = "ChatbotAPIGateway"
  description = "Terraform Chatbot Application Example"
}

output "base_url" {
  value = "${aws_api_gateway_deployment.chatbot.invoke_url}"
}
