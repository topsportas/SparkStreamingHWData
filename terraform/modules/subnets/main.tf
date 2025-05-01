module "subnets" {
  source = "cloudposse/dynamic-subnets/aws"
  version = "2.4.2"
  namespace           = "vpc-${var.project}"
  stage               = var.env
  name                = var.region
  vpc_id              = var.vpc_reuse.vpc_id
  public_route_table_ids = [var.vpc_reuse.public_rt_id]
  availability_zones  = var.azs_list

  nat_gateway_enabled = false
  public_open_network_acl_enabled = false
  private_open_network_acl_enabled = false
  private_route_table_enabled = false

  ipv4_cidrs = [{
    private = var.vpc_reuse.private_sub_cidrs
    public = var.vpc_reuse.public_sub_cidrs
  }]
}

resource "aws_network_acl_association" "private" {
  for_each = { for idx, value in module.subnets.private_subnet_ids : idx => value }

  network_acl_id = var.vpc_reuse.network_acl_id
  subnet_id      = each.value
}

resource "aws_network_acl_association" "public" {
  for_each = { for idx, value in module.subnets.public_subnet_ids : idx => value }

  network_acl_id = var.vpc_reuse.network_acl_id
  subnet_id      = each.value
}

resource "aws_route_table_association" "private" {
  for_each = { for idx, value in module.subnets.private_subnet_ids : idx => value }

  subnet_id      = each.value
  route_table_id = var.vpc_reuse.private_rt_id
}
