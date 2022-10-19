output "user_pool_id" {
  value = aws_cognito_user_pool.pool.id
}

output "user_pool_endpoint" {
  value = aws_cognito_user_pool.pool.endpoint
}

