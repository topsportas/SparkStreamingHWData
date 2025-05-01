variable "project" {
  type        = string
  description = "Project name"
  default     = "bdcc"
}

variable "env" {
  type        = string
  description = "Environment name"
  default     = "dev"
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "tags" {
  type        = map(any)
  description = "Resource tags"
  default = {
    Terraform   = "true"
    Environment = "dev"
  }
}

variable "ssm_parameters" {
  type        = set(any)
  description = "Set of parameters stored in AWS SSM"
  default     = ["databricks_account_id", "databricks_admin_sp_id", "databricks_admin_sp_secret"]
}

variable "ssm_region" {
  type        = string
  description = "Region with AWS SSM parameters"
  default     = "us-east-1"
}

variable "workspace" {
  type = map(string)
  default = {
    "ap-northeast-1" = "com.amazonaws.vpce.ap-northeast-1.vpce-svc-02691fd610d24fd64"
    "ap-northeast-2" = "com.amazonaws.vpce.ap-northeast-2.vpce-svc-0babb9bde64f34d7e"
    "ap-south-1"     = "com.amazonaws.vpce.ap-south-1.vpce-svc-0dbfe5d9ee18d6411"
    "ap-southeast-1" = "com.amazonaws.vpce.ap-southeast-1.vpce-svc-02535b257fc253ff4"
    "ap-southeast-2" = "com.amazonaws.vpce.ap-southeast-2.vpce-svc-0b87155ddd6954974"
    "ca-central-1"   = "com.amazonaws.vpce.ca-central-1.vpce-svc-0205f197ec0e28d65"
    "eu-central-1"   = "com.amazonaws.vpce.eu-central-1.vpce-svc-081f78503812597f7"
    "eu-west-1"      = "com.amazonaws.vpce.eu-west-1.vpce-svc-0da6ebf1461278016"
    "eu-west-2"      = "com.amazonaws.vpce.eu-west-2.vpce-svc-01148c7cdc1d1326c"
    "eu-west-3"      = "com.amazonaws.vpce.eu-west-3.vpce-svc-008b9368d1d011f37"
    "sa-east-1"      = "com.amazonaws.vpce.sa-east-1.vpce-svc-0bafcea8cdfe11b66"
    "us-east-1"      = "com.amazonaws.vpce.us-east-1.vpce-svc-09143d1e626de2f04"
    "us-east-2"      = "com.amazonaws.vpce.us-east-2.vpce-svc-041dc2b4d7796b8d3"
    "us-west-2"      = "com.amazonaws.vpce.us-west-2.vpce-svc-0129f463fcfbc46c5"
    #"us-west-1" = ""
  }
}

variable "scc_relay" {
  type = map(string)
  default = {
    "ap-northeast-1" = "com.amazonaws.vpce.ap-northeast-1.vpce-svc-02aa633bda3edbec0"
    "ap-northeast-2" = "com.amazonaws.vpce.ap-northeast-2.vpce-svc-0dc0e98a5800db5c4"
    "ap-south-1"     = "com.amazonaws.vpce.ap-south-1.vpce-svc-03fd4d9b61414f3de"
    "ap-southeast-1" = "com.amazonaws.vpce.ap-southeast-1.vpce-svc-0557367c6fc1a0c5c"
    "ap-southeast-2" = "com.amazonaws.vpce.ap-southeast-2.vpce-svc-0b4a72e8f825495f6"
    "ca-central-1"   = "com.amazonaws.vpce.ca-central-1.vpce-svc-0c4e25bdbcbfbb684"
    "eu-central-1"   = "com.amazonaws.vpce.eu-central-1.vpce-svc-08e5dfca9572c85c4"
    "eu-west-1"      = "com.amazonaws.vpce.eu-west-1.vpce-svc-09b4eb2bc775f4e8c"
    "eu-west-2"      = "com.amazonaws.vpce.eu-west-2.vpce-svc-05279412bf5353a45"
    "eu-west-3"      = "com.amazonaws.vpce.eu-west-3.vpce-svc-005b039dd0b5f857d"
    "sa-east-1"      = "com.amazonaws.vpce.sa-east-1.vpce-svc-0e61564963be1b43f"
    "us-east-1"      = "com.amazonaws.vpce.us-east-1.vpce-svc-00018a8c3ff62ffdf"
    "us-east-2"      = "com.amazonaws.vpce.us-east-2.vpce-svc-090a8fab0d73e39a6"
    "us-west-2"      = "com.amazonaws.vpce.us-west-2.vpce-svc-0158114c0c730c3bb"
    #"us-west-1" = ""
  }
}

variable "network_cidr" {
  type        = string
  description = "The address space that is used for the virtual network. Should be with mask /20 for correct subnet calculation."
  default     = "10.101.0.0/20"
}

variable "azs_list" {
  type        = list(any)
  description = "A list of availability zones names or ids in the region"
  default     = ["us-east-1a", "us-east-1b"]
}

variable "private_subnet_names" {
  type        = list(any)
  description = "Explicit values to use in the Name tag on private subnets. If empty, Name tags are generated"
  default     = []
}

variable "public_subnet_names" {
  type        = list(any)
  description = "Explicit values to use in the Name tag on public subnets. If empty, Name tags are generated"
  default     = []
}

variable "intra_subnet_names" {
  type        = list(any)
  description = "Explicit values to use in the Name tag on public subnets. If empty, Name tags are generated"
  default     = []
}

variable "custom_vpc_name" {
  type        = string
  description = "Custom name for Virtual Network"
  default     = null
}

# Databricks Runtime
variable "databricks_runtime_enabled" {
  type        = bool
  description = "Databricks Runtime switch"
  default     = true
}

variable "databricks_workspace_groups" {
  type = list(object({
    group_name    = string
    group_members = list(string)
  }))
  default = []
}

variable "databricks_sql_endpoint" {
  type = set(object({
    name                 = string
    cluster_size         = optional(string)
    max_num_clusters     = optional(number)
    enable_photon        = optional(bool)
    spot_instance_policy = optional(string)
    warehouse_type       = optional(string)
    key                  = optional(string)
    value                = optional(string)
  }))
  description = "Set of objects with parameters to configure SQL Endpoint and assign permissions to it for certain custom groups"
  default     = []
}


variable "databricks_cluster_configs" {
  type = set(object({
    cluster_name            = string
    spark_version           = optional(string)
    node_type_id            = optional(string)
    autotermination_minutes = optional(number)
    min_workers             = optional(number)
    max_workers             = optional(number)
    availability            = optional(string)
    first_on_demand         = optional(number)
    spot_bid_price_percent  = optional(number)
  }))
  description = "Set of objects with parameters to configure Databricks clusters and assign permissions to it for certain custom groups"
#  default = [{
#    cluster_name           = "shared autoscaling"
#    availability           = "SPOT"
#    spot_bid_price_percent = 100
#    }, {
#    cluster_name           = "single test_1"
#    availability           = "SPOT"
#    spot_bid_price_percent = 100
#  }]
  default = []
}

variable "databricks_workspace_custom_config" {
  type        = map(string)
  description = "Map of AD databricks workspace custom config"
  default     = {}
}

variable "allowed_ip_address" {
  type        = map(string)
  description = "Map of IP addresses"
    default = {
    "epam-vpn-ru-0" = "185.44.13.36"
    "epam-vpn-eu-0" = "195.56.119.209"
    "epam-vpn-eu-1" = "195.56.119.212"
    "epam-vpn-eu-2" = "204.153.55.4"
    "epam-vpn-in-0" = "203.170.48.2"
    "epam-vpn-ua-0" = "85.223.209.18"
    "epam-vpn-us-0" = "174.128.60.160"
    "epam-vpn-us-1" = "174.128.60.162"
    "epam-vpn-by-0" = "213.184.231.20"
    "epam-vpn-by-1" = "86.57.255.94"
  }
}

variable "databricks_secret_scope_name" {
  type        = string
  description = "Databricks Secret Scope name"
  default     = null
}

variable "databricks_workspace_admins" {
  type = object({
    user              = optional(list(string))
    service_principal = optional(list(string))
  })
  description = "Provide users or service principals to grant them Admin permissions in Workspace."
  default     = {}
}
