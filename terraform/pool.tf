resource "aws_cognito_user_pool" "pool" {
  name = "${local.prefix}-user-pool"

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
    email_subject        = "Vajeh - Verify your email"
  }

  password_policy {
    minimum_length  = 7
    require_symbols = false
  }

  username_configuration {
    case_sensitive = false
  }
}

locals {
  user_groups = ["User"]
}

// Used for adding audiences for the api in front of the backend
resource "aws_cognito_user_group" "user_group" {
  count        = length(local.user_groups)
  name         = local.user_groups[count.index]
  user_pool_id = aws_cognito_user_pool.pool.id
}

resource "aws_cognito_user_pool_domain" "user_pool_domain_name" {
  domain       = "${local.prefix}-auth-domain"
  user_pool_id = aws_cognito_user_pool.pool.id

  # FIXME: for prod it should be custom domain
  #  certificate_arn = aws_acm_certificate.auth_domain_certificate.arn
}
