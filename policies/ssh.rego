package terraform.security

import rego.v1

deny contains msg if {
  resource := input.resource_changes[_]
  resource.type == "aws_security_group"
  ingress := resource.change.after.ingress[_]
  ingress.from_port <= 22
  ingress.to_port >= 22
  cidr := ingress.cidr_blocks[_]
  cidr == "0.0.0.0/0"
  msg := sprintf(
    "Security Group '%s' permite SSH publico (0.0.0.0/0). No esta permitido.",
    [resource.address]
  )
}
