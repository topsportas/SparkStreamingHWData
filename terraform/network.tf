module "vpc" {
  count = 1
  source = "terraform-aws-modules/vpc/aws"

  name = local.vpc_name
  cidr = var.network_cidr

  azs = var.azs_list

  private_subnets      = [cidrsubnet(var.network_cidr, 4, 0), cidrsubnet(var.network_cidr, 4, 1)]
  private_subnet_names = var.private_subnet_names

  public_subnets      = [cidrsubnet(var.network_cidr, 8, 32), cidrsubnet(var.network_cidr, 8, 33)]
  public_subnet_names = var.public_subnet_names

  intra_subnets      = [cidrsubnet(var.network_cidr, 8, 34), cidrsubnet(var.network_cidr, 8, 35)]
  intra_subnet_names = var.intra_subnet_names

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_vpn_gateway = false

  default_network_acl_egress = [
    {
      "action" : "allow",
      "cidr_block" : var.network_cidr
      "from_port" : 0,
      "protocol" : -1,
      "rule_no" : 100,
      "to_port" : 0
    },
    {
      "action" : "allow",
      "cidr_block" : "0.0.0.0/0",
      "from_port" : 443,
      "protocol" : "tcp",
      "rule_no" : 101,
      "to_port" : 443
    },
    {
      "action" : "allow",
      "cidr_block" : "0.0.0.0/0",
      "from_port" : 3306,
      "protocol" : "tcp",
      "rule_no" : 102,
      "to_port" : 3306
    },
    {
      "action" : "allow",
      "cidr_block" : "0.0.0.0/0",
      "from_port" : 6666,
      "protocol" : "tcp",
      "rule_no" : 103,
      "to_port" : 6666
    }
  ]

  default_security_group_egress = [
    {
      protocol  = -1
      self      = true
      from_port = 0
      to_port   = 0
    },
    {
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      from_port   = 443
      to_port     = 443
    },
    {
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      from_port   = 3306
      to_port     = 3306
    },
    {
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      from_port   = 6666
      to_port     = 6666
    },
    {
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      from_port   = 2443
      to_port     = 2443
    },
    {
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      from_port   = 8443
      to_port     = 8443
  }]
  default_security_group_ingress = [{
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }]
  tags = var.tags
}

module "vpc_endpoints" {
  count = 1
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "3.11.0"

  vpc_id             = module.vpc[0].vpc_id
  security_group_ids = [module.vpc[0].default_security_group_id]

  endpoints = {
    s3 = {
      service      = "s3"
      service_type = "Gateway"
      route_table_ids = flatten([
        module.vpc[0].private_route_table_ids, module.vpc[0].public_route_table_ids
      ])
      tags = {
        Name = "${var.project}-${var.env}-${var.region}-s3-vpc-endpoint"
      }
    },
    sts = {
      service             = "sts"
      private_dns_enabled = true
      subnet_ids          = module.vpc[0].private_subnets
      tags = {
        Name = "${var.project}-${var.env}-${var.region}-sts-vpc-endpoint"
      }
    }
  }

  tags = var.tags
}

resource "aws_security_group" "privatelink" {
  count = 1

  vpc_id = module.vpc[0].vpc_id

  ingress {
    description     = "Inbound rules"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [module.vpc[0].default_security_group_id]
  }

  ingress {
    description     = "Inbound rules"
    from_port       = 2443
    to_port         = 2443
    protocol        = "tcp"
    security_groups = [module.vpc[0].default_security_group_id]
  }

  ingress {
    description     = "Inbound rules"
    from_port       = 6666
    to_port         = 6666
    protocol        = "tcp"
    security_groups = [module.vpc[0].default_security_group_id]
  }

  egress {
    description     = "Outbound rules"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [module.vpc[0].default_security_group_id]
  }

  egress {
    description     = "Outbound rules"
    from_port       = 2443
    to_port         = 2443
    protocol        = "tcp"
    security_groups = [module.vpc[0].default_security_group_id]
  }

  egress {
    description     = "Outbound rules"
    from_port       = 6666
    to_port         = 6666
    protocol        = "tcp"
    security_groups = [module.vpc[0].default_security_group_id]
  }

  tags = {
    Name = "${var.project}-${var.env}-${var.region}-private-link-sg"
  }
}

// Databricks REST endpoint - skipped in custom operation mode
resource "aws_vpc_endpoint" "backend_rest" {
  count = 1

  vpc_id              = module.vpc[0].vpc_id
  service_name        = var.workspace[var.region]
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.privatelink[0].id]
  subnet_ids          = length(module.vpc[0].intra_subnets) > 0 ? slice(module.vpc[0].intra_subnets, 0, min(2, length(module.vpc[0].intra_subnets))) : []
  private_dns_enabled = true
  depends_on          = [module.vpc[0].vpc_id]
  tags = {
    Name = "${var.project}-${var.env}-${var.region}-databricks-rest-endpoint"
  }
}

// Databricks SCC endpoint - skipped in custom operation mode
resource "aws_vpc_endpoint" "backend_relay" {
  count = 1

  vpc_id              = module.vpc[0].vpc_id
  service_name        = var.scc_relay[var.region]
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.privatelink[0].id]
  subnet_ids          = length(module.vpc[0].intra_subnets) > 0 ? slice(module.vpc[0].intra_subnets, 0, min(2, length(module.vpc[0].intra_subnets))) : []
  private_dns_enabled = true
  depends_on          = [module.vpc[0].vpc_id]
  tags = {
    Name = "${var.project}-${var.env}-${var.region}-databricks-relay-endpoint"
  }
}
