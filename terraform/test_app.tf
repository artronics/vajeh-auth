resource "aws_cognito_user_pool_client" "test_app" {
  name = "${local.prefix}-test"

  user_pool_id                         = aws_cognito_user_pool.pool.id
  generate_secret                      = true
  allowed_oauth_flows_user_pool_client = true
  callback_urls                        = ["https://oauth.pstmn.io/v1/callback", "http://localhost:9000"]
  allowed_oauth_flows                  = ["client_credentials"]
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  explicit_auth_flows                  = [
    "ALLOW_ADMIN_USER_PASSWORD_AUTH", "ALLOW_CUSTOM_AUTH", "ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_SRP_AUTH"
  ]

  allowed_oauth_scopes = aws_cognito_resource_server.test_resource_server.scope_identifiers
}

resource "aws_cognito_resource_server" "test_resource_server" {
  identifier   = "${local.prefix}-test-server"
  name         = "${local.prefix}-test-server"
  user_pool_id = aws_cognito_user_pool.pool.id
  scope {
    scope_description = "read resource"
    scope_name        = "read"
  }
  scope {
    scope_description = "write resource"
    scope_name        = "write"
  }
}



