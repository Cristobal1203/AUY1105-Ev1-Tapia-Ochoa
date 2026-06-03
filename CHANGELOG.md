# CHANGELOG

El formato sigue [Keep a Changelog](https://keepachangelog.com/es/1.0.0/) y [Semantic Versioning](https://semver.org/).

---

## [1.0.0] - 2024-06-02

### Added
- `README.md`: documentación completa del repositorio con EP2
- `CHANGELOG.md`: registro de cambios actualizado

---

## [0.2.0] - 2024-06-02

### Added
- `policies/ec2.rego`: política OPA que restringe EC2 a tipo `t3.micro`
- `policies/ssh.rego`: política OPA que bloquea SSH público (`0.0.0.0/0`)
- `.github/workflows/pipeline.yaml`: pipeline con 3 etapas (TFLint, Checkov, Terraform Validate + OPA)
- `examples/main.tf`: ejemplo funcional de uso de ambos módulos
- `.gitignore`: exclusión de archivos de estado y credenciales
- `main.tf`: orquestación de módulos locales VPC y EC2
- `variables.tf`: variables de alto nivel para configurar ambos módulos
- `outputs.tf`: outputs consolidados de ambos módulos
- `versions.tf`: versiones requeridas con bloque provider centralizado

---

## [0.1.0] - 2024-06-02

### Added
- `modules/vpc/`: módulo de red con VPC, subnets, Security Group, KMS, CloudWatch y Flow Logs
- `modules/ec2/`: módulo de cómputo con EC2, IAM Role e Instance Profile