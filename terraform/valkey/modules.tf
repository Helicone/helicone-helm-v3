# Multi-region Valkey Cache Modules

# Module for us-west-2 Valkey cache
module "valkey_us_west_2" {
  source = "./modules/valkey-cache"
  
  # AWS Configuration
  region            = "us-west-2"
  valkey_cache_name = "${var.valkey_cache_name}-us-west-2"
  
  # Cache Configuration
  description               = var.description
  engine                   = var.engine
  major_engine_version     = var.major_engine_version
  max_storage_gb           = var.max_storage_gb
  max_ecpu_per_second      = var.max_ecpu_per_second
  daily_snapshot_time      = var.daily_snapshot_time
  snapshot_retention_limit = var.snapshot_retention_limit
  
  # Network Configuration
  vpc_id                     = try(var.vpc_ids["us-west-2"], "")
  subnet_ids                 = try(var.subnet_ids["us-west-2"], [])
  create_subnet_group        = var.create_subnet_group
  allowed_cidr_blocks        = var.allowed_cidr_blocks
  allowed_security_group_ids = try(var.allowed_security_group_ids["us-west-2"], [])
  
  # Tags
  tags = merge(var.tags, {
    Region = "us-west-2"
  })

  # Provider configuration
  providers = {
    aws = aws.us-west-2
  }
}

# Module for us-east-1 Valkey cache
module "valkey_us_east_1" {
  source = "./modules/valkey-cache"
  
  # AWS Configuration
  region            = "us-east-1"
  valkey_cache_name = "${var.valkey_cache_name}-us-east-1"
  
  # Cache Configuration
  description               = var.description
  engine                   = var.engine
  major_engine_version     = var.major_engine_version
  max_storage_gb           = var.max_storage_gb
  max_ecpu_per_second      = var.max_ecpu_per_second
  daily_snapshot_time      = var.daily_snapshot_time
  snapshot_retention_limit = var.snapshot_retention_limit
  
  # Network Configuration
  vpc_id                     = try(var.vpc_ids["us-east-1"], "")
  subnet_ids                 = try(var.subnet_ids["us-east-1"], [])
  create_subnet_group        = var.create_subnet_group
  allowed_cidr_blocks        = var.allowed_cidr_blocks
  allowed_security_group_ids = try(var.allowed_security_group_ids["us-east-1"], [])
  
  # Tags
  tags = merge(var.tags, {
    Region = "us-east-1"
  })

  # Provider configuration
  providers = {
    aws = aws.us-east-1
  }
}

# Provider configuration for us-west-2
provider "aws" {
  alias  = "us-west-2"
  region = "us-west-2"
}

# Provider configuration for us-east-1
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}