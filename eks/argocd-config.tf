# ArgoCD Configuration and Setup

# Create ArgoCD Application for the devsecops project
resource "kubernetes_manifest" "argocd_application" {
  depends_on = [null_resource.argocd_ready]

  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "devsecops-app"
      namespace = "argocd"
    }
    spec = {
      project = "devsecops-project"
      source = {
        repoURL        = "<your-repo-url>"
        targetRevision = "main"
        path          = "kubernetes-manifest"
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "default"
      }
      syncPolicy = {
        automated = {
          prune      = true
          selfHeal   = true
          allowEmpty = false
        }
        syncOptions = [
          "CreateNamespace=true",
          "PrunePropagationPolicy=foreground",
          "PruneLast=true"
        ]
      }
    }
  }
}

# Create ArgoCD Project for better organization
resource "kubernetes_manifest" "argocd_project" {
  depends_on = [null_resource.argocd_ready]

  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "AppProject"
    metadata = {
      name      = "devsecops-project"
      namespace = "argocd"
    }
    spec = {
      description = "DevSecOps Project"
      sourceRepos = [
        "<your-repo-url>"
      ]
      destinations = [
        {
          namespace = "default"
          server    = "https://kubernetes.default.svc"
        }
      ]
      clusterResourceWhitelist = [
        {
          group = "*"
          kind  = "*"
        }
      ]
      namespaceResourceWhitelist = [
        {
          group = "*"
          kind  = "*"
        }
      ]
    }
  }
}

# Configure ArgoCD RBAC for admin access
resource "kubernetes_manifest" "argocd_rbac_config" {
  depends_on = [null_resource.argocd_ready]

  manifest = {
    apiVersion = "v1"
    kind       = "ConfigMap"
    metadata = {
      name      = "argocd-rbac-cm"
      namespace = "argocd"
    }
    data = {
      "policy.default" = "role:admin"
      "policy.csv"     = "p, role:admin, applications, *, *, allow"
    }
  }
}

# Create LoadBalancer Service for ArgoCD Server
resource "kubernetes_manifest" "argocd_server_lb" {
  depends_on = [null_resource.argocd_ready]

  manifest = {
    apiVersion = "v1"
    kind       = "Service"
    metadata = {
      name      = "argocd-server-lb"
      namespace = "argocd"
      annotations = {
        "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb"
        "service.beta.kubernetes.io/aws-load-balancer-scheme" = "internet-facing"
      }
    }
    spec = {
      type = "LoadBalancer"
      ports = [
        {
          port        = 80
          targetPort  = 8080
          protocol    = "TCP"
          name        = "http"
        },
        {
          port        = 443
          targetPort  = 8080
          protocol    = "TCP"
          name        = "https"
        }
      ]
      selector = {
        "app.kubernetes.io/name" = "argocd-server"
      }
    }
  }
} 