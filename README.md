# AUY1105-Tapia-Ochoa
## Infraestructura como Código II — Evaluación Parcial N°1

---

## Objetivo

Implementar infraestructura en AWS usando Terraform con validación automática de calidad y seguridad mediante GitHub Actions, integrando herramientas de análisis estático, seguridad y políticas de cumplimiento.

---

## Integrantes

- Valentina Ochoa
- Cristóbal Tapia

---

## Instrucciones de uso

### Requisitos previos
- Terraform >= 1.0.0
- AWS CLI configurado con credenciales válidas
- Cuenta AWS con permisos para crear VPC, EC2, IAM, KMS, CloudWatch

### Clonar el repositorio
```bash
git clone https://github.com/valentina-ochoa/AUY1105-Tapia-Ochoa.git
cd AUY1105-Tapia-Ochoa
```

### Inicializar y validar
```bash
terraform init
terraform validate
terraform plan
```

---

## Estructura del repositorio

```
AUY1105-Tapia-Ochoa/
├── main.tf                          # Código principal de infraestructura
├── .github/
│   └── workflows/
│       └── pipeline.yaml            # Pipeline GitHub Actions
├── policies/
│   ├── ec2.rego                     # Política OPA: solo t3.micro
│   └── ssh.rego                     # Política OPA: sin SSH público
├── .gitignore
├── CHANGELOG.md
└── README.md
```

---

## Infraestructura definida (`main.tf`)

### Proveedor
- **AWS** versión `~> 5.0` en región `us-east-1`

### Red
| Recurso | Nombre | Descripción |
|---------|--------|-------------|
| `aws_vpc` | AUY1105-Tapia-Ochoa-vpc | VPC con CIDR `10.1.0.0/16` |
| `aws_subnet` | AUY1105-Tapia-Ochoa-subnet | Subred pública con CIDR `10.1.1.0/24` |
| `aws_security_group` | AUY1105-Tapia-Ochoa-sg | Permite solo SSH (puerto 22) desde redes internas |
| `aws_default_security_group` | default | SG por defecto bloqueado (sin reglas) |

### Cómputo
| Recurso | Nombre | Descripción |
|---------|--------|-------------|
| `aws_instance` | AUY1105-Tapia-Ochoa-ec2 | EC2 t3.micro con Ubuntu 24.04 LTS, disco encriptado, IMDSv2 requerido |
| `aws_iam_role` | AUY1105-Tapia-Ochoa-ec2-role | Rol IAM para la instancia EC2 |
| `aws_iam_instance_profile` | AUY1105-Tapia-Ochoa-ec2-profile | Perfil de instancia EC2 |

### Monitoreo y seguridad
| Recurso | Nombre | Descripción |
|---------|--------|-------------|
| `aws_kms_key` | AUY1105-Tapia-Ochoa-kms | Llave KMS con rotación automática para cifrado de logs |
| `aws_cloudwatch_log_group` | AUY1105-Tapia-Ochoa-loggroup | Grupo de logs con retención 365 días y cifrado KMS |
| `aws_flow_log` | AUY1105-Tapia-Ochoa-flowlog | VPC Flow Logs hacia CloudWatch |
| `aws_iam_role` | AUY1105-Tapia-Ochoa-flowlogs-role | Rol IAM para VPC Flow Logs |

---

## Pipeline CI/CD (GitHub Actions)

El pipeline se activa automáticamente en cada Pull Request hacia `main` y ejecuta **3 etapas secuenciales**:

1. **Etapa 1 — TFLint**: Análisis estático del código Terraform
2. **Etapa 2 — Checkov**: Análisis de seguridad y vulnerabilidades
3. **Etapa 3 — Terraform Validate + OPA**: Validación del código y políticas de seguridad

---

## Políticas de seguridad (OPA)

| Política | Archivo | Descripción |
|----------|---------|-------------|
| Sin SSH público | `policies/ssh.rego` | Deniega Security Groups con SSH (puerto 22) abierto a `0.0.0.0/0` |
| Solo t3.micro | `policies/ec2.rego` | Deniega instancias EC2 que no sean de tipo `t3.micro` |

---

## Nomenclatura de recursos

Todos los recursos siguen el formato: `AUY1105-<nombre-aplicación>-<tipo-recurso>`

Ejemplo: `AUY1105-Tapia-Ochoa-vpc`, `AUY1105-Tapia-Ochoa-ec2`, `AUY1105-Tapia-Ochoa-sg`
