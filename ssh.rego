package terraform.security

# Política: No se permite acceso SSH público (0.0.0.0/0) hacia la instancia EC2
deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "aws_security_group"

  ingress := resource.change.after.ingress[_]
  ingress.from_port <= 22
  ingress.to_port >= 22

  cidr := ingress.cidr_blocks[_]
  cidr == "0.0.0.0/0"

  msg := sprintf(
    "❌ Security Group '%s' permite SSH público (0.0.0.0/0). No está permitido.",
    [resource.address]
  )
}
