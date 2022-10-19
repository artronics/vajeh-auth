resource "aws_cognito_user_pool" "pool" {
  name = "${local.name_prefix}-user-pool"

  mfa_configuration = "OPTIONAL"
  software_token_mfa_configuration {
    enabled = true
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_LINK"
    email_subject        = "Pawnflow - Verify you email"
  }

  password_policy {
    minimum_length  = 7
    require_symbols = false
  }

  username_configuration {
    case_sensitive = false
  }
}

data "aws_cognito_user_pool_clients" "main" {
  user_pool_id = aws_cognito_user_pool.pool.id
}

data "aws_secretsmanager_secret" "testuser1" {
  name = "vajeh/auth/dev/testuser/testuser1"
}

resource "aws_cognito_user" "test_users" {
  user_pool_id = aws_cognito_user_pool.pool.id
  username     = "testuser1-${local.environment}@${local.project_domain}"
  password = data.aws_secretsmanager_secret.testuser1.id
  enabled = true
}

// Used for adding audiences for the api in front of the backend
output "user_pool_client_ids" {
  value = data.aws_cognito_user_pool_clients.main.client_ids
}

output "aws_cognito_user_pool_id" {
  value = aws_cognito_user_pool.pool.id
}

resource "aws_cognito_user_pool_domain" "user_pool_domain_name" {
  domain          = local.dev_auth_domain_name
  user_pool_id    = aws_cognito_user_pool.pool.id

  # FIXME: for prod it should be custom domain
#  certificate_arn = aws_acm_certificate.auth_domain_certificate.arn
}
