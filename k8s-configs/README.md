## Paso 1: Configurar IAM y OIDC
Asociar el Proveedor OIDC:

Asegúrate de que el proveedor OIDC esté habilitado para tu clúster de EKS. Esto es necesario para que el controlador pueda asumir roles de IAM.

```bash
eksctl utils associate-iam-oidc-provider --region <REGION> --cluster <CLUSTER_NAME> --approve
```

eksctl utils associate-iam-oidc-provider --region us-east-1 --cluster cluster-image-processor --approve

## Descargar la Política de IAM:

Descarga la política de IAM necesaria para el AWS Load Balancer Controller.

```bash
curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json
```
## Crear la Política de IAM:

Crea una política de IAM usando el documento descargado.

```bash
aws iam create-policy \
  --policy-name AWSLoadBalancerControllerIAMPolicy \
  --policy-document file://iam_policy.json
```

## Paso 2: Crear el Service Account con eksctl

Crear el Service Account:

Usa eksctl para crear un Service Account en el namespace kube-system y adjunta la política de IAM creada.

```bash
eksctl create iamserviceaccount \
  --cluster=cluster-image-processor \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --attach-policy-arn=arn:aws:iam::ACCOUNT-ID:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve
```

## Paso 3: Instalar el AWS Load Balancer Controller con Helm
Agregar el Repositorio de Helm:

Asegúrate de que el repositorio de Helm para EKS esté agregado.

```bash
helm repo add eks https://aws.github.io/eks-charts
helm repo update
```
Instalar el Controlador:

Usa Helm para instalar el AWS Load Balancer Controller, especificando el Service Account que creaste.

```bash
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  --namespace kube-system \
  --set clusterName=CLUSTER-NAME\
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=us-east-1 \
  --set vpcId=vpc-VPC-ID
  ```
## Paso 4: Verificar la Instalación
Verificar el Despliegue:

Asegúrate de que el controlador esté desplegado y funcionando correctamente.

```bash
kubectl get deployment -n kube-system aws-load-balancer-controller
```


## Importante
Tambien se puede ejecutar el ./install.sh que se tiene pero solo si modificas el values.yaml del Helm.