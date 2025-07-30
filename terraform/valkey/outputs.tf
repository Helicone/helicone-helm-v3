# Output Valkey cache information for both regions

# US-West-2 Outputs
output "us_west_2_valkey_cache_name" {
  description = "Name of the Valkey serverless cache in us-west-2"
  value       = module.valkey_us_west_2.valkey_cache_name
}

output "us_west_2_valkey_cache_arn" {
  description = "ARN of the Valkey serverless cache in us-west-2"
  value       = module.valkey_us_west_2.valkey_cache_arn
}

output "us_west_2_valkey_cache_endpoint" {
  description = "Endpoint URL of the Valkey serverless cache in us-west-2"
  value       = module.valkey_us_west_2.valkey_cache_endpoint
  sensitive   = true
}

output "us_west_2_valkey_cache_port" {
  description = "Port of the Valkey serverless cache in us-west-2"
  value       = module.valkey_us_west_2.valkey_cache_port
}

output "us_west_2_valkey_connection_string" {
  description = "Connection string for the Valkey cache in us-west-2 (format: host:port)"
  value       = module.valkey_us_west_2.connection_string
  sensitive   = true
}

output "us_west_2_valkey_security_group_id" {
  description = "ID of the security group for the Valkey cache in us-west-2"
  value       = module.valkey_us_west_2.valkey_security_group_id
}

# US-East-1 Outputs
output "us_east_1_valkey_cache_name" {
  description = "Name of the Valkey serverless cache in us-east-1"
  value       = module.valkey_us_east_1.valkey_cache_name
}

output "us_east_1_valkey_cache_arn" {
  description = "ARN of the Valkey serverless cache in us-east-1"
  value       = module.valkey_us_east_1.valkey_cache_arn
}

output "us_east_1_valkey_cache_endpoint" {
  description = "Endpoint URL of the Valkey serverless cache in us-east-1"
  value       = module.valkey_us_east_1.valkey_cache_endpoint
  sensitive   = true
}

output "us_east_1_valkey_cache_port" {
  description = "Port of the Valkey serverless cache in us-east-1"
  value       = module.valkey_us_east_1.valkey_cache_port
}

output "us_east_1_valkey_connection_string" {
  description = "Connection string for the Valkey cache in us-east-1 (format: host:port)"
  value       = module.valkey_us_east_1.connection_string
  sensitive   = true
}

output "us_east_1_valkey_security_group_id" {
  description = "ID of the security group for the Valkey cache in us-east-1"
  value       = module.valkey_us_east_1.valkey_security_group_id
}

# Combined outputs for all regions
output "all_valkey_cache_arns" {
  description = "Map of Valkey cache ARNs by region"
  value = {
    us-west-2 = module.valkey_us_west_2.valkey_cache_arn
    us-east-1 = module.valkey_us_east_1.valkey_cache_arn
  }
}

output "all_valkey_cache_endpoints" {
  description = "Map of Valkey cache endpoints by region"
  value = {
    us-west-2 = module.valkey_us_west_2.valkey_cache_endpoint
    us-east-1 = module.valkey_us_east_1.valkey_cache_endpoint
  }
  sensitive = true
}

output "all_valkey_connection_strings" {
  description = "Map of Valkey connection strings by region"
  value = {
    us-west-2 = module.valkey_us_west_2.connection_string
    us-east-1 = module.valkey_us_east_1.connection_string
  }
  sensitive = true
}

output "all_valkey_security_group_ids" {
  description = "Map of Valkey security group IDs by region"
  value = {
    us-west-2 = module.valkey_us_west_2.valkey_security_group_id
    us-east-1 = module.valkey_us_east_1.valkey_security_group_id
  }
}