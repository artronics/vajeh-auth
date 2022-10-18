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
  root_domain_name      = "vajeh.artronics.me.uk"
  domain_name           = "${local.environment}.${local.service}.${local.root_domain_name}"
  root_auth_domain_name = "${local.service}.${local.root_domain_name}"
  auth_domain_name      = local.domain_name
}
