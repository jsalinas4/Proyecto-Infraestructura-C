# ============================================================================
# BACKEND INFRASTRUCTURE - S3 + DynamoDB
# ============================================================================
# Este archivo crea los recursos necesarios para el backend remoto de Terraform
# IMPORTANTE: Ejecutar esto PRIMERO antes de configurar el backend en main.tf
# 
# Pasos:
# 1. terraform init (sin backend configurado aún)
# 2. terraform apply -target=aws_s3_bucket.terraform_state -target=aws_dynamodb_table.terraform_locks
# 3. Descomentar el backend en main.tf
# 4. terraform init -migrate-state
# ============================================================================

# S3 Bucket para almacenar el state
resource "aws_s3_bucket" "terraform_state" {
  bucket = "proyecto-infraestructura-tfstate-${var.env}"

  tags = {
    Name        = "Terraform State Bucket"
    Environment = var.env
    Purpose     = "terraform-state"
  }
}

# Habilitar versionado del bucket (mantiene historial de cambios del state)
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Encriptación del bucket (seguridad del state)
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Bloquear acceso público al bucket
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Tabla DynamoDB para state locking (previene conflictos)
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "proyecto-infraestructura-tfstate-locks-${var.env}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform State Lock Table"
    Environment = var.env
    Purpose     = "terraform-state-locking"
  }
}

# Outputs para verificar la creación
output "s3_bucket_name" {
  description = "Nombre del bucket S3 para el state"
  value       = aws_s3_bucket.terraform_state.id
}

output "dynamodb_table_name" {
  description = "Nombre de la tabla DynamoDB para locking"
  value       = aws_dynamodb_table.terraform_locks.id
}

output "backend_config" {
  description = "Configuración del backend para copiar a main.tf"
  value       = <<-EOT
    backend "s3" {
      bucket         = "${aws_s3_bucket.terraform_state.id}"
      key            = "terraform.tfstate"
      region         = "${var.region}"
      dynamodb_table = "${aws_dynamodb_table.terraform_locks.id}"
      encrypt        = true
    }
  EOT
}
