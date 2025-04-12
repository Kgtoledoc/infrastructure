# Infrastructure

Este módulo gestiona la infraestructura necesaria para desplegar las aplicaciones App A y App B en AWS utilizando Terraform.

## Componentes

- **Amazon VPC:** Configuración de red para el clúster de EKS.
- **Amazon EKS:** Clúster de Kubernetes para ejecutar las aplicaciones.
- **Amazon ECR:** Repositorios para almacenar las imágenes Docker.
- **AWS CodeBuild:** Proyectos para construir y desplegar las aplicaciones.

## Requisitos

- Terraform 1.0+
- AWS CLI configurado con credenciales válidas

## Configuración

1. Clona el repositorio:
git clone <URL_DEL_REPOSITORIO_INFRASTRUCTURE>
cd infrastructure
2. Inicializa Terraform:
terraform init
3. Despliegue
Ejecuta el siguiente comando para aplicar la configuración de Terraform y desplegar la infraestructura:
terraform plan -out=tfplan
terraform apply -auto-aprove tfplan
4. Revisa los cambios propuestos y confirma el despliegue.

## Almacenamiento del Estado
El estado de Terraform se almacena remotamente en un bucket de S3 para facilitar la colaboración y el bloqueo de estado se gestiona con DynamoDB.

## Contribuciones
Las contribuciones son bienvenidas. Por favor, abre un issue o envía un pull request.