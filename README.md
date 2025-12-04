# Proyecto Infraestructura Cloud - AWS

Proyecto de infraestructura como código (IaC) para desplegar una aplicación web escalable en AWS utilizando Terraform, con CI/CD automatizado mediante GitHub Actions y Jenkins.


## 📁 Estructura del Proyecto

```
Proyecto-Infraestructura-C/
├── .github/
│   └── workflows/
│       ├── terraform.yml              # Workflow original de Terraform
│       └── terraform-improved.yml     # Workflow mejorado con comentarios en PR
│
├── bootstrap/                         # Infraestructura del backend de Terraform
│   ├── main.tf                       # Crea S3 bucket y DynamoDB para tfstate
│   └── README.md                     # Instrucciones de bootstrap
│
├── docs/
│   └── TFSTATE_MANAGEMENT.md         # Guía completa de manejo de estado
│
├── infraestructure-develop/          # Infraestructura de desarrollo local
│   ├── jenkins/                      # Configuración de Jenkins
│   │   ├── docker-compose.yml        # Jenkins master + agent
│   │   ├── Dockerfile.master         # Imagen de Jenkins master
│   │   ├── Dockerfile.agent          # Imagen de Jenkins agent
│   │   └── jenkins.yaml              # JCasC configuration
│   ├── lambda_agency/                # Funciones Lambda - Agency service
│   ├── lambda_code/                  # Funciones Lambda - Code service
│   ├── lambda_modules/               # Funciones Lambda - Modules service
│   ├── lambda_services/              # Funciones Lambda - Services service
│   └── lambda_users/                 # Funciones Lambda - Users service
│
├── terraform/                        # Configuración principal de Terraform
│   ├── backend.tf                    # Configuración del backend S3
│   ├── providers.tf                  # Proveedores de Terraform (AWS)
│   ├── variables.tf                  # Definición de variables
│   ├── staging.terraform.tfvars      # Valores para ambiente staging
│   ├── vpc.tf                        # VPC, subnets, routing
│   ├── alb.tf                        # ALB, target groups, ASG
│   ├── rds.tf                        # RDS MySQL instance
│   ├── efs.tf                        # EFS file system
│   ├── cloudfront.tf                 # CloudFront distribution
│   ├── route53.tf                    # DNS configuration
│   ├── local.tf                      # Variables locales
│   ├── output.tf                     # Outputs de Terraform
│   └── main.tf                       # Configuración principal
│
├── .gitignore                        # Archivos ignorados por Git
└── README.md                         # Este archivo
```


### Características Principales

- ✅ **Alta Disponibilidad**: Multi-AZ deployment (us-east-2a, us-east-2b)
- ✅ **Escalabilidad**: Auto Scaling Group con Launch Template
- ✅ **Seguridad**: Subnets privadas, Security Groups, encriptación en reposo
- ✅ **CDN Global**: CloudFront para distribución de contenido
- ✅ **DNS Gestionado**: Route 53 con dominio personalizado
- ✅ **Almacenamiento Compartido**: EFS para archivos compartidos entre instancias
- ✅ **Base de Datos Gestionada**: RDS MySQL 8.0 con backups automáticos
- ✅ **CI/CD Automatizado**: GitHub Actions y Jenkins

---

## 🧩 Componentes de Infraestructura

### 1. **Networking (VPC)**

| Componente | Configuración | Descripción |
|------------|---------------|-------------|
| **VPC** | `10.0.0.0/16` | Red virtual privada principal |
| **Public Subnets** | `10.0.1.0/24`, `10.0.2.0/24` | Subnets para ALB y NAT Gateways |
| **Private Subnets** | `10.0.3.0/24`, `10.0.4.0/24` | Subnets para EC2 y RDS |
| **Internet Gateway** | 1x IGW | Acceso a Internet para recursos públicos |
| **NAT Gateways** | 2x NAT (Multi-AZ) | Salida a Internet para recursos privados |
| **Route Tables** | Public + Private | Enrutamiento de tráfico |

**Archivos:** [`terraform/vpc.tf`](terraform/vpc.tf)

### 2. **Compute (EC2 & Auto Scaling)**

| Componente | Configuración | Descripción |
|------------|---------------|-------------|
| **Instance Type** | `t3a.micro` | Tipo de instancia EC2 |
| **AMI** | `ami-0cd3c7f72edd5b06d` | Amazon Linux 2023 |
| **Auto Scaling** | Min: 2, Max: 4 | Escalado automático |
| **Launch Template** | User Data incluido | Configuración de instancias |
| **EFS Mount** | Automático | Almacenamiento compartido |

**Archivos:** [`terraform/alb.tf`](terraform/alb.tf)

### 3. **Load Balancing (ALB)**

| Componente | Configuración | Descripción |
|------------|---------------|-------------|
| **Type** | Application Load Balancer | Balanceador de capa 7 |
| **Scheme** | Internet-facing | Accesible desde Internet |
| **Listeners** | HTTP (80), HTTPS (443) | Puertos de escucha |
| **Target Group** | HTTP:80 | Grupo de destino para EC2 |
| **Health Checks** | `/` endpoint | Verificación de salud |
| **SSL/TLS** | ACM Certificate | Certificado SSL gestionado |

**Archivos:** [`terraform/alb.tf`](terraform/alb.tf)

### 4. **Database (RDS)**

| Componente | Configuración | Descripción |
|------------|---------------|-------------|
| **Engine** | MySQL 8.0.42 | Motor de base de datos |
| **Instance Class** | `db.t3.micro` | Tipo de instancia |
| **Storage** | 20 GB (gp2) | Almacenamiento SSD |
| **Multi-AZ** | `false` (staging) | Alta disponibilidad |
| **Encryption** | Enabled | Encriptación en reposo |
| **Backups** | 7 días | Retención de backups |
| **Password** | SSM Parameter Store | Almacenamiento seguro |

**Archivos:** [`terraform/rds.tf`](terraform/rds.tf)

### 5. **Storage (EFS & S3)**

#### EFS (Elastic File System)
- Almacenamiento compartido entre instancias EC2
- Mount targets en subnets privadas
- Lifecycle policy para optimización de costos

#### S3
- Bucket para contenido estático del sitio web
- Integración con CloudFront
- Versionamiento habilitado

**Archivos:** [`terraform/efs.tf`](terraform/efs.tf), [`terraform/cloudfront.tf`](terraform/cloudfront.tf)

### 6. **CDN & DNS**

#### CloudFront
- Distribución global de contenido
- Integración con S3 y ALB
- Certificado SSL/TLS
- Compresión automática

#### Route 53
- Zona hospedada: `cloudtest.space`
- Registros A para `www` y apex
- Alias a CloudFront

**Archivos:** [`terraform/cloudfront.tf`](terraform/cloudfront.tf), [`terraform/route53.tf`](terraform/route53.tf)

### 7. **Security Groups**

| Security Group | Inbound | Outbound | Propósito |
|----------------|---------|----------|-----------|
| **ALB SG** | 80, 443 (0.0.0.0/0) | All | Load Balancer |
| **EC2 SG** | 80, 443 (ALB SG) | All | Instancias web |
| **RDS SG** | 3306 (EC2 SG) | All | Base de datos |
| **EFS SG** | 2049 (EC2 SG) | All | File system |

---


## 📋 Requisitos Previos

### Software Necesario

- **Terraform** >= 1.8.2 ([Descargar](https://www.terraform.io/downloads))
- **AWS CLI** >= 2.0 ([Descargar](https://aws.amazon.com/cli/))
- **Git** ([Descargar](https://git-scm.com/))
- **Docker** (opcional, para Jenkins local) ([Descargar](https://www.docker.com/))

### Credenciales AWS

Necesitas una cuenta de AWS con permisos para crear:
- VPC, Subnets, Route Tables, Internet Gateway, NAT Gateway
- EC2 Instances, Auto Scaling Groups, Launch Templates
- Application Load Balancer, Target Groups
- RDS Instances, DB Subnet Groups
- EFS File Systems
- S3 Buckets
- CloudFront Distributions
- Route 53 Hosted Zones
- IAM Roles y Policies
- Security Groups

### Dominio

- Un dominio registrado (ejemplo: `cloudtest.space`)
- Zona hospedada en Route 53 (se crea automáticamente si el dominio está en Route 53)

---

## ⚙️ Configuración Inicial

### 1. Clonar el Repositorio

```bash
git clone https://github.com/jsalinas4/Proyecto-Infraestructura-C.git
cd Proyecto-Infraestructura-C
```

### 2. Configurar Credenciales AWS

```bash
# Opción 1: AWS CLI
aws configure

# Opción 2: Variables de entorno
export AWS_ACCESS_KEY_ID="tu-access-key"
export AWS_SECRET_ACCESS_KEY="tu-secret-key"
export AWS_SESSION_TOKEN="tu-session-token"  # Si usas credenciales temporales
export AWS_REGION="us-east-2"
```

### 3. Crear Backend de Terraform (Primera vez)

El backend S3 debe existir antes de usar Terraform. Ejecuta el bootstrap:

```bash
cd bootstrap
terraform init
terraform plan
terraform apply

# Guarda los outputs
terraform output
```

Esto creará:
- Bucket S3: `terraform-state`
- Tabla DynamoDB: `terraform-locks`

> 📖 **Documentación completa**: Ver [`docs/TFSTATE_MANAGEMENT.md`](docs/TFSTATE_MANAGEMENT.md)

### 4. Configurar Variables

Edita el archivo [`terraform/staging.terraform.tfvars`](terraform/staging.terraform.tfvars):

```hcl
# Personaliza estos valores
domain_name        = "tu-dominio.com"
notification_email = "tu-email@ejemplo.com"
ami_id            = "ami-xxxxxxxxx"  # AMI de tu región

# Revisa y ajusta según necesites
instance_type = "t3a.micro"
region        = "us-east-2"
```

### 5. Configurar GitHub Secrets (Para CI/CD)

En tu repositorio de GitHub:

```
Settings → Secrets and variables → Actions → New repository secret
```

Agrega los siguientes secrets:

| Secret Name | Descripción |
|-------------|-------------|
| `AWS_ACCESS_KEY_ID` | Access Key ID de AWS |
| `AWS_SECRET_ACCESS_KEY` | Secret Access Key de AWS |
| `AWS_SESSION_TOKEN` | Session Token (si usas credenciales temporales) |

---

## 🚀 Despliegue

### Despliegue Local

```bash
cd terraform

# 1. Inicializar Terraform
terraform init

# 2. Validar configuración
terraform validate

# 3. Formatear código
terraform fmt -recursive

# 4. Ver plan de ejecución
terraform plan -var-file=staging.terraform.tfvars

# 5. Aplicar cambios
terraform apply -var-file=staging.terraform.tfvars

# 6. Ver outputs
terraform output
```

### Despliegue con GitHub Actions

El despliegue automático se activa:

1. **Push a `develop`**: Ejecuta `plan` automáticamente
2. **Pull Request**: Ejecuta `plan` y comenta el resultado en el PR
3. **Manual (workflow_dispatch)**: Puedes elegir `plan`, `apply` o `destroy`

```bash
# Hacer cambios y push
git add .
git commit -m "Update infrastructure"
git push origin develop

# Ver el workflow en GitHub
# Actions → Terraform Pipeline
```

### Verificar Despliegue

```bash
# Obtener DNS del ALB
terraform output alb_dns_name

# Obtener URL del sitio
terraform output website_url

# Probar el endpoint
curl -I https://www.cloudtest.space
```

---
