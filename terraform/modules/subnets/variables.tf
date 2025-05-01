variable "vpc_reuse" {
  type = object({
    vpc_id = optional(string),
    public_rt_id = optional(string),
    private_rt_id = optional(string),
    network_acl_id = optional(string),
    private_sub_cidrs = optional(list(string)),
    public_sub_cidrs = optional(list(string)),
  })
  description = "IDs of network resources to be reused"
}

variable "project" {
  type        = string
  description = "Project name"
}

variable "env" {
  type        = string
  description = "Environment name"
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "azs_list" {
  type        = list(any)
  description = "A list of availability zones names or ids in the region"
}
