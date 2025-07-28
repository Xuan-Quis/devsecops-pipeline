# NGINX Ingress Controller và LoadBalancer cho EKS

# Data source để lấy thông tin EKS cluster
data "aws_eks_cluster" "main" {
  name = module.eks.cluster-name
}

data "aws_eks_cluster_auth" "main" {
  name = module.eks.cluster-name
}

# Provider cho Kubernetes
provider "kubernetes" {
  host                   = data.aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.main.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.main.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.main.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.main.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.main.token
  }
}

# Namespace cho ingress-nginx
resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = "ingress-nginx"
    labels = {
      name = "ingress-nginx"
    }
  }
}

# Helm release cho NGINX Ingress Controller
resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = kubernetes_namespace.ingress_nginx.metadata[0].name
  version    = "4.7.1"

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "nlb"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme"
    value = "internet-facing"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-nlb-target-type"
    value = "ip"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-subnets"
    value = join(",", module.eks.public_subnet_ids)
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-additional-resource-tags"
    value = "Environment=${var.env},Project=Ecommerce"
  }

  set {
    name  = "controller.resources.requests.cpu"
    value = "100m"
  }

  set {
    name  = "controller.resources.requests.memory"
    value = "128Mi"
  }

  set {
    name  = "controller.resources.limits.cpu"
    value = "200m"
  }

  set {
    name  = "controller.resources.limits.memory"
    value = "256Mi"
  }

  set {
    name  = "controller.config.enable-real-ip"
    value = "true"
  }

  set {
    name  = "controller.config.use-proxy-protocol"
    value = "false"
  }

  depends_on = [
    module.eks,
    kubernetes_namespace.ingress_nginx
  ]
}

# Output LoadBalancer URL
output "ingress_nginx_loadbalancer_url" {
  description = "URL của LoadBalancer cho NGINX Ingress Controller"
  value       = "http://${helm_release.ingress_nginx.values[0].controller.service.loadBalancerIP}"
}

# Output LoadBalancer DNS
output "ingress_nginx_loadbalancer_dns" {
  description = "DNS của LoadBalancer cho NGINX Ingress Controller"
  value       = helm_release.ingress_nginx.values[0].controller.service.loadBalancerIngress[0].hostname
} 