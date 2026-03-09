resource "aws_cognito_user_pool" "pool" {
  name = "unleash-user-pool"
}

resource "aws_cognito_user_pool_client" "client" {
  name         = "unleash-user-pool-client"
  user_pool_id = aws_cognito_user_pool.pool.id
  generate_secret = false
}

resource "aws_cognito_user" "test_user" {
  user_pool_id = aws_cognito_user_pool.pool.id
  username     = var.email
  force_alias_creation = false
  message_action = "SUPPRESS"
}

output "user_pool_id" {
  value = aws_cognito_user_pool.pool.id
}

output "user_pool_client_id" {
  value = aws_cognito_user_pool_client.client.id
}