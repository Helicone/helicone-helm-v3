# Aurora PostgreSQL Terraform Module

This Terraform module creates an AWS Aurora PostgreSQL cluster with best practices for security,
monitoring, and high availability.

## Features

- **Aurora PostgreSQL Cluster**: Fully managed PostgreSQL-compatible database
- **High Availability**: Multi-AZ deployment with configurable instance count
- **Security**:
  - VPC-based deployment with security groups
  - Encryption at rest using KMS
  - Master password stored in AWS Secrets Manager
- **Monitoring**:
  - Enhanced monitoring with CloudWatch
  - Performance Insights
  - PostgreSQL logs exported to CloudWatch
- **Backup & Recovery**:
  - Automated backups with configurable retention
  - Point-in-time recovery
  - Final snapshot on deletion (configurable)
- **Parameter Groups**: Optimized for performance and logging
- **Network Isolation**: Deployed in private subnets with security group controls

## Usage

### Basic Usage

```hcl
module "aurora_postgresql" {
  source = "./terraform/db"

  cluster_identifier = "my-aurora-cluster"
  database_name      = "myapp"
  master_username    = "dbadmin"

  vpc_id     = "vpc-12345678"
  subnet_ids = ["subnet-12345678", "subnet-87654321"]

  allowed_security_group_ids = ["sg-12345678"]

  tags = {
    Environment = "production"
    Project     = "my-project"
  }
}
```

### Advanced Usage

```hcl
module "aurora_postgresql" {
  source = "./terraform/db"

  cluster_identifier = "production-aurora-cluster"
  database_name      = "helicone"
  master_username    = "helicone_admin"

  # Instance configuration
  instance_class = "db.r6g.xlarge"
  instance_count = 3

  # Engine configuration
  engine_version = "15.4"

  # Backup configuration
  backup_retention_period      = 14
  preferred_backup_window      = "03:00-04:00"
  preferred_maintenance_window = "sun:04:00-sun:05:00"

  # Security configuration
  vpc_id     = "vpc-12345678"
  subnet_ids = ["subnet-12345678", "subnet-87654321", "subnet-11223344"]

  allowed_security_group_ids = ["sg-12345678", "sg-87654321"]
  allowed_cidr_blocks       = ["10.0.0.0/8"]

  # Monitoring configuration
  enable_monitoring                         = true
  monitoring_interval                      = 60
  performance_insights_enabled             = true
  performance_insights_retention_period    = 31

  # Safety configuration
  deletion_protection   = true
  skip_final_snapshot   = false
  apply_immediately     = false

  tags = {
    Environment = "production"
    Project     = "helicone"
    Team        = "platform"
  }
}
```

## Requirements

| Name      | Version  |
| --------- | -------- |
| terraform | >= 1.3.0 |
| aws       | ~> 5.0   |
| random    | ~> 3.1   |

## Providers

| Name   | Version |
| ------ | ------- |
| aws    | ~> 5.0  |
| random | ~> 3.1  |

## Inputs

| Name                                  | Description                                                                           | Type           | Default                     | Required |
| ------------------------------------- | ------------------------------------------------------------------------------------- | -------------- | --------------------------- | :------: |
| cluster_identifier                    | The cluster identifier for Aurora PostgreSQL                                          | `string`       | `"helicone-aurora-cluster"` |    no    |
| database_name                         | The name of the database to create                                                    | `string`       | `"helicone"`                |    no    |
| master_username                       | Username for the master DB user                                                       | `string`       | `"helicone_admin"`          |    no    |
| master_password                       | Password for the master DB user. If not provided, a random password will be generated | `string`       | `null`                      |    no    |
| engine_version                        | The engine version for Aurora PostgreSQL                                              | `string`       | `"15.4"`                    |    no    |
| instance_class                        | The instance class for Aurora instances                                               | `string`       | `"db.r6g.large"`            |    no    |
| instance_count                        | Number of instances in the Aurora cluster                                             | `number`       | `2`                         |    no    |
| backup_retention_period               | The backup retention period in days                                                   | `number`       | `7`                         |    no    |
| preferred_backup_window               | The daily time range during which automated backups are created                       | `string`       | `"03:00-04:00"`             |    no    |
| preferred_maintenance_window          | The weekly time range during which system maintenance can occur                       | `string`       | `"sun:04:00-sun:05:00"`     |    no    |
| vpc_id                                | ID of the VPC where Aurora will be deployed                                           | `string`       | n/a                         |   yes    |
| subnet_ids                            | List of subnet IDs for the Aurora cluster                                             | `list(string)` | n/a                         |   yes    |
| allowed_security_group_ids            | List of security group IDs allowed to access Aurora                                   | `list(string)` | `[]`                        |    no    |
| allowed_cidr_blocks                   | List of CIDR blocks allowed to access Aurora                                          | `list(string)` | `[]`                        |    no    |
| skip_final_snapshot                   | Determines whether a final DB snapshot is created before the DB cluster is deleted    | `bool`         | `false`                     |    no    |
| deletion_protection                   | If the DB cluster should have deletion protection enabled                             | `bool`         | `true`                      |    no    |
| apply_immediately                     | Specifies whether any cluster modifications are applied immediately                   | `bool`         | `false`                     |    no    |
| environment                           | Environment tag for resources                                                         | `string`       | `"production"`              |    no    |
| tags                                  | Additional tags for resources                                                         | `map(string)`  | `{}`                        |    no    |
| enable_monitoring                     | Enable enhanced monitoring for Aurora instances                                       | `bool`         | `true`                      |    no    |
| monitoring_interval                   | The interval for collecting enhanced monitoring metrics                               | `number`       | `60`                        |    no    |
| performance_insights_enabled          | Enable Performance Insights for Aurora instances                                      | `bool`         | `true`                      |    no    |
| performance_insights_retention_period | Amount of time in days to retain Performance Insights data                            | `number`       | `7`                         |    no    |
| auto_minor_version_upgrade            | Enable automatic minor version upgrades                                               | `bool`         | `true`                      |    no    |

## Outputs

| Name                          | Description                                                           |
| ----------------------------- | --------------------------------------------------------------------- |
| cluster_id                    | The RDS Cluster Identifier                                            |
| cluster_identifier            | The RDS Cluster Identifier                                            |
| cluster_endpoint              | The cluster endpoint                                                  |
| cluster_reader_endpoint       | The cluster reader endpoint                                           |
| cluster_port                  | The port on which the DB accepts connections                          |
| cluster_master_username       | The master username for the RDS cluster                               |
| cluster_database_name         | The name of the database                                              |
| cluster_hosted_zone_id        | The hosted zone ID of the Aurora cluster                              |
| cluster_resource_id           | The RDS Cluster Resource ID                                           |
| cluster_arn                   | The ARN of the RDS cluster                                            |
| instance_ids                  | List of RDS instance IDs                                              |
| instance_arns                 | List of RDS instance ARNs                                             |
| instance_endpoints            | List of RDS instance endpoints                                        |
| security_group_id             | The ID of the security group for Aurora                               |
| security_group_arn            | The ARN of the security group for Aurora                              |
| db_subnet_group_name          | The name of the DB subnet group                                       |
| db_subnet_group_arn           | The ARN of the DB subnet group                                        |
| cluster_parameter_group_name  | The name of the cluster parameter group                               |
| instance_parameter_group_name | The name of the instance parameter group                              |
| kms_key_id                    | The KMS key ID used for encryption                                    |
| kms_key_arn                   | The KMS key ARN used for encryption                                   |
| kms_alias_name                | The KMS key alias name                                                |
| secrets_manager_secret_arn    | The ARN of the Secrets Manager secret containing the master password  |
| secrets_manager_secret_name   | The name of the Secrets Manager secret containing the master password |
| enhanced_monitoring_role_arn  | The ARN of the enhanced monitoring role                               |
| connection_string             | PostgreSQL connection string (without password)                       |

## Security Considerations

1. **Network Security**: The Aurora cluster is deployed in private subnets and access is controlled
   via security groups
2. **Encryption**: All data is encrypted at rest using AWS KMS
3. **Password Management**: The master password is stored securely in AWS Secrets Manager
4. **Access Control**: Use IAM roles and policies to control access to the Aurora cluster
5. **Monitoring**: Enable CloudWatch logs and Performance Insights for security monitoring

## Connecting to the Database

To connect to your Aurora PostgreSQL cluster, you'll need:

1. **Endpoint**: Use the `cluster_endpoint` output for write operations
2. **Reader Endpoint**: Use the `cluster_reader_endpoint` output for read-only operations
3. **Credentials**: Retrieve from AWS Secrets Manager using the `secrets_manager_secret_name` output
4. **Network Access**: Ensure your application has network access through the security group

### Example Connection (using AWS CLI)

```bash
# Get the connection details from Secrets Manager
aws secretsmanager get-secret-value --secret-id $(terraform output -raw secrets_manager_secret_name) --query SecretString --output text | jq -r .

# Connect using psql
psql -h $(terraform output -raw cluster_endpoint) \
     -p $(terraform output -raw cluster_port) \
     -U $(terraform output -raw cluster_master_username) \
     -d $(terraform output -raw cluster_database_name)
```

## Maintenance and Updates

- **Engine Updates**: Configure `auto_minor_version_upgrade` for automatic minor version updates
- **Maintenance Windows**: Set `preferred_maintenance_window` to minimize impact
- **Backups**: Configure `backup_retention_period` and `preferred_backup_window` appropriately
- **Monitoring**: Regularly review CloudWatch metrics and Performance Insights

## Cost Optimization

- Choose appropriate instance classes based on your workload
- Use Aurora Serverless v2 for variable workloads (requires manual configuration)
- Optimize backup retention periods
- Monitor and optimize Performance Insights retention

## Troubleshooting

Common issues and solutions:

1. **Connection Issues**: Check security group rules and network ACLs
2. **Performance Issues**: Review Performance Insights and enable enhanced monitoring
3. **Storage Issues**: Aurora automatically scales storage, but monitor usage patterns
4. **Backup Issues**: Ensure adequate backup retention and review backup windows

## License

This module is released under the MIT License. See LICENSE file for details.
