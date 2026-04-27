# CHANGELOG

Todos los cambios relevantes de este proyecto están documentados en este archivo.
El formato sigue [Keep a Changelog](https://keepachangelog.com/es/1.0.0/).

---

## [1.3.0] - 2024 — PR #4: Definición de políticas OPA

### Agregado
- `policies/ec2.rego`: política OPA que restringe la creación de instancias EC2 al tipo `t3.micro`
- `policies/ssh.rego`: política OPA que bloquea el acceso SSH público (`0.0.0.0/0`) al Security Group
- Integración de OPA en el pipeline de GitHub Actions con evaluación sobre un input simulado del plan Terraform

---

## [1.2.0] - 2024 — PR #3: Automatización GitHub Actions

### Agregado
- `.github/workflows/pipeline.yaml`: pipeline de GitHub Actions con 3 etapas secuenciales:
  - Etapa 1: TFLint (análisis estático)
  - Etapa 2: Checkov (análisis de seguridad)
  - Etapa 3: Terraform Validate + OPA (validación del código y políticas)
- Pipeline configurado para ejecutarse solo en Pull Requests hacia `main`
- Jobs con dependencias (`needs`) para garantizar ejecución secuencial
- OPA evalúa políticas con input simulado sin requerir credenciales AWS

---

## [1.1.0] - 2024 — PR #2: Código de infraestructura Terraform

### Agregado
- `main.tf`: código Terraform completo con:
  - VPC (`10.1.0.0/16`) — `AUY1105-Tapia-Ochoa-vpc`
  - Subred pública (`10.1.1.0/24`) — `AUY1105-Tapia-Ochoa-subnet`
  - Security Group con SSH restringido a redes internas — `AUY1105-Tapia-Ochoa-sg`
  - EC2 `t3.micro` Ubuntu 24.04 LTS con disco encriptado e IMDSv2 — `AUY1105-Tapia-Ochoa-ec2`
  - KMS Key con rotación automática — `AUY1105-Tapia-Ochoa-kms`
  - CloudWatch Log Group con cifrado — `AUY1105-Tapia-Ochoa-loggroup`
  - VPC Flow Logs — `AUY1105-Tapia-Ochoa-flowlog`
  - Roles IAM para EC2 y Flow Logs
- AMI definido con `data source` dinámico de Canonical (owner `099720109477`) para Ubuntu 24.04 LTS
- Nomenclatura de recursos en formato `AUY1105-Tapia-Ochoa-<tipo-recurso>`

---

## [1.0.0] - 2024 — PR #1: Repositorio de Código

### Agregado
- Repositorio inicializado con nombre `AUY1105-Ev1-Tapia-Ochoa`
- `README.md`: descripción del proyecto, instrucciones de uso y definición de recursos Terraform
- `.gitignore`: exclusión de `.terraform/`, `*.tfstate`, `*.tfstate.backup`, `*.pem`, `*.tfvars`, `secrets/`
- `CHANGELOG.md`: registro de cambios del proyecto
- Estructura base del repositorio definida