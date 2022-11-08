terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4"
    }
  }

  backend "s3" {
    bucket = "vajeh-auth-terraform-state"
    key    = "dev/app"
    region = "eu-west-2"
  }
}

locals {
  non_user_envs = ["dev", "prod"]
  ws            = local.environment

  is_live         = local.environment == "prod"
  is_pr           = can(regex("pr\\d+", local.ws))
  pr_no           = trimprefix("pr", local.ws)
  is_user_env     = local.ws != "dev" && local.ws != "prod" && !local.is_pr

  environment_tag = local.is_user_env ? "user_${local.ws}" : local.is_pr ? "pr_${local.pr_no}" : local.ws
}

provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      Project     = local.project
      Service     = local.service
      Environment = local.environment_tag
      Tier        = local.tier
    }
  }
}

provider "aws" {
  alias  = "acm_provider"
  region = "us-east-1"
  default_tags {
    tags = {
      Project     = local.project
      Service     = local.service
      Environment = local.environment_tag
      Tier        = local.tier
    }
  }
}
