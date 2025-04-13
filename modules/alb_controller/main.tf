resource "aws_iam_role" "alb_controller_role" {
  name = "alb-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "alb_controller_policy" {
  role       = aws_iam_role.alb_controller_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLoadBalancerControllerIAMPolicy"
}

resource "kubernetes_namespace" "kube_system" {
  metadata {
    name = "kube-system"
  }
}

resource "kubernetes_service_account" "alb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = kubernetes_namespace.kube_system.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_controller_role.arn
    }
  }
}

resource "kubernetes_deployment" "alb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = kubernetes_namespace.kube_system.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "aws-load-balancer-controller"
      }
    }

    template {
      metadata {
        labels = {
          app = "aws-load-balancer-controller"
        }
      }

      spec {
        service_account_name = kubernetes_service_account.alb_controller.metadata[0].name

        container {
          image = "602401143452.dkr.ecr.${var.region}.amazonaws.com/amazon/aws-load-balancer-controller:v2.3.0"
          name  = "aws-load-balancer-controller"

          args = [
            "--cluster-name=${var.cluster_name}",
            "--ingress-class=alb",
            "--aws-region=${var.region}"
          ]
        }
      }
    }
  }
}