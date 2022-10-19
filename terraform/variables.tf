locals {
  project = "vajeh"
  tier    = "backend"
}

locals {
  environment = terraform.workspace
  service     = "auth"
  name_prefix = "${local.project}-${local.service}-${local.environment}"
}
locals {
  project_domain = "vajeh.artronics.me.uk"
}

locals {
  #  Cognito needs a root domain which is created in infra. see: https://stackoverflow.com/a/56429359/3943054
  #  AWS Cognito always need a parent domain. It's not possible to do this using unique workspace domain name
  root_auth_domain_name = "${local.environment}.${local.service}.${local.project_domain}"
  auth_domain_name = "${local.environment}.${local.environment}.${local.service}.${local.project_domain}"
}

