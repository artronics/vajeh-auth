output "client_ids" {
  value = [aws_cognito_user_pool_client.vajeh_client.id, aws_cognito_user_pool_client.test_app.id]
}

output "auth_scopes" {
  value = aws_cognito_resource_server.test_resource_server.scope_identifiers
}

output "user_pool_endpoint" {
  value = aws_cognito_user_pool.pool.endpoint
}
