output "test_client_id" {
  value = aws_cognito_user_pool_client.test_app.id
}

output "test_client_scopes" {
  value = aws_cognito_user_pool_client.test_app.allowed_oauth_scopes
}

output "user_pool_id" {
  value = aws_cognito_user_pool.pool.id
}

output "user_pool_endpoint" {
  value = aws_cognito_user_pool.pool.endpoint
}
