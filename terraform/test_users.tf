data "aws_secretsmanager_secret" "testuser1" {
  // TODO /password in other region takes 7 days to be deleted. It's named password2. Change it back to password when the previous one is deleted
  name = "${local.project}/${local.service}/${local.is_live ? "live" : "ptl"}/testuser/password3"
}

data "aws_secretsmanager_secret_version" "testuser1_password" {
  secret_id = data.aws_secretsmanager_secret.testuser1.id
}

locals {
  testuser1_email          = "testuser1-${local.environment}@${local.project_domain}"
  testuser1_password = data.aws_secretsmanager_secret_version.testuser1_password.secret_string
}

resource "aws_cognito_user" "test_users" {
  user_pool_id = aws_cognito_user_pool.pool.id
  username     = local.testuser1_email
  password     = local.testuser1_password
  enabled      = true
  #  attributes must match with the schema.
  #  If not terraform detects as change and tries to recreate user each deployment. see: https://stackoverflow.com/a/56466168/3943054
  attributes   = {
    email          = local.testuser1_email
    email_verified = true
  }
}

resource "aws_cognito_user_in_group" "add_test_user_to_group" {
  group_name   = [for g in aws_cognito_user_group.user_group.*.name : g if g == "User"][0] #  User group
  user_pool_id = aws_cognito_user_pool.pool.id
  username     = local.testuser1_email
}
