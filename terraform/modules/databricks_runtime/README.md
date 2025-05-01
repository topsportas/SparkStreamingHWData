# Azure Databricks Workspace Terraform module
Terraform module for registering AWS resources in Databricks Account and for creation of Databricks Workspace

## Usage

```hcl
data "aws_ssm_parameter" "account_id" {
  name     = "databricks_account_id"
}

module "databricks" {
  source = "./modules/databricks"
  
  region  = var.region

  account_id                 = data.aws_ssm_parameter.account_id.value
  network_name               = "dev-us-east-1-network-configuration"
  bucket_name                = "dev-dbfs-root-bucket"
  storage_configuration_name = "dev-dbfs-root-bucket-configuration"
  credentials_name           = "dev-us-east-1-credentials"
  workspace_name             = "dev-us-east-1-workspace"

  security_group_ids = [module.vpc.default_security_group_id]
  subnet_ids         = module.vpc.private_subnets
  vpc_id             = module.vpc.vpc_id
  role_arn           = "arn:aws:iam::123456789012:role/dev-us-east-1-databricks-crossaccount"

  providers = {
    databricks = databricks.mws
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Modules

No modules.

## Resources

| Name                                                                                                                             | Type |
|----------------------------------------------------------------------------------------------------------------------------------|------|
| [databricks_mws_networks.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_networks) | resource |
| [databricks_mws_storage_configurations.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_storage_configurations) | resource |
| [databricks_mws_credentials.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_credentials) | resource |
| [databricks_mws_workspaces.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_workspaces) | resource |

## Inputs

| Name                                                                                                                 | Description                                                                | Type           | Default | Required |
|----------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------|----------------|---------|:--------:|
| <a name="input_region"></a> [region](#input\_region)                                                                 | AWS region                                                                 | `string`       | n/a     |   yes    |
| <a name="input_account_id"></a> [account\_id](#input\_account\_id)                                                   | Databricks Account ID                                                      | `string`       | n/a     |   yes    |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name)                                             | Databricks Account network configuration name                              | `string`       | n/a     |   yes    |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name)                                                | AWS S3 dbfs root bucket name                                               | `string`       | n/a     |   yes    |
| <a name="input_storage_configuration_name"></a> [storage\_configuration\_name](#input\_storage\_configuration\_name) | Databricks Account storage configuration name                              | `string`       | n/a     |   yes    |
| <a name="input_credentials_name"></a> [credentials\_name](#input\_credentials\_name)                                 | Databricks Account credentials configuration name                          | `string`       | n/a     |   yes    |
| <a name="input_workspace_name"></a> [workspace\_name](#input\_workspace\_name)                                       | Databricks workspace name                                                  | `string`       | n/a     |   yes    |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn)                                                         | AWS Databricks crossaccount IAM Role ARN                                   | `string`       | n/a     |   yes    |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id)                                                               | AWS VPC ID to be used for Workspace deployment                             | `string`       | n/a     |   yes    |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids)                         | Set of AWS security group IDs for Databricks Account network configuration | `set(string)`  | n/a     |   yes    |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids)                                                   | Set of AWS subnet IDs for Databricks Account network configuration         | `set(string)`  | n/a     |   yes    |


## Outputs

| Name                                                                                  | Description          |
|---------------------------------------------------------------------------------------|----------------------|
| <a name="output_databricks_host"></a> [databricks_host](#output\_databricks\_host)    | AWS Databricks Host  |
| <a name="output_databricks_token"></a> [databricks_token](#output\_databricks\_token) | AWS Databricks Token |
<!-- END_TF_DOCS -->

## License

Apache 2 Licensed. For more information please see [LICENSE](https://github.com/data-platform-hq/terraform-azurerm-databricks-ws/blob/main/LICENSE)
