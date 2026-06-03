variable "project_name" {
  type        = string
  description = "Nombre del proyecto. Usado como prefijo en todos los recursos."
  default     = "AUY1105-Tapia-Ochoa"
}

variable "aws_region" {
  type        = string
  description = "Región de AWS donde se desplegará la infraestructura."
  default     = "us-east-1"
}

variable "vpc_cidr" {
  type        = string
  description = "Bloque CIDR para la VPC."
  default     = "10.1.0.0/16"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Lista de CIDRs para las subnets públicas."
  default     = ["10.1.1.0/24"]
}

variable "availability_zones" {
  type        = list(string)
  description = "Lista de AZs para las subnets."
  default     = []
}

variable "instance_type" {
  type        = string
  description = "Tipo de instancia EC2."
  default     = "t3.micro"
}

variable "log_retention_days" {
  type        = number
  description = "Días de retención de logs en CloudWatch."
  default     = 365
}

variable "tags" {
  type        = map(string)
  description = "Tags comunes aplicados a todos los recursos."
  default = {
    Environment = "dev"
    Project     = "AUY1105-Tapia-Ochoa"
    ManagedBy   = "Terraform"
  }
}