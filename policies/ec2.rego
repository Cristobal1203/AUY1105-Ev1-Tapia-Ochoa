package terraform.security

import rego.v1

deny contains msg if {
  resource := input.resource_changes[_]
  resource.type == "aws_instance"
  instance_type := resource.change.after.instance_type
  instance_type != "t3.micro"
  msg := sprintf(
    "EC2 '%s' usa tipo '%s'. Solo se permite 't3.micro'.",
    [resource.address, instance_type]
  )
}
