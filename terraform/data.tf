data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "this" {
  for_each = var.ssm_parameters
  name     = each.key

  provider = aws.ssm
}
