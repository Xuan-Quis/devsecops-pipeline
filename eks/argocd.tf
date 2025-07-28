# ArgoCD Installation for EKS Cluster
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

# Install ArgoCD using kubectl apply
resource "null_resource" "argocd_installation" {
  depends_on = [module.eks]

  provisioner "local-exec" {
    command = <<-EOT
      aws eks update-kubeconfig --region ${var.aws-region} --name ${local.env}-${local.org}-${var.cluster-name}
      kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      aws eks update-kubeconfig --region ${var.aws-region} --name ${local.env}-${local.org}-${var.cluster-name}
      kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    EOT
  }
}

# Wait for ArgoCD to be ready
resource "null_resource" "argocd_ready" {
  depends_on = [null_resource.argocd_installation]

  provisioner "local-exec" {
    command = <<-EOT
      aws eks update-kubeconfig --region ${var.aws-region} --name ${local.env}-${local.org}-${var.cluster-name}
      kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
      kubectl wait --for=condition=available --timeout=300s deployment/argocd-repo-server -n argocd
      kubectl wait --for=condition=available --timeout=300s deployment/argocd-redis -n argocd
      kubectl wait --for=condition=available --timeout=300s deployment/argocd-dex-server -n argocd
      kubectl wait --for=condition=available --timeout=300s deployment/argocd-application-controller -n argocd
    EOT
  }
}

# Get ArgoCD admin password
resource "null_resource" "argocd_password" {
  depends_on = [null_resource.argocd_ready]

  provisioner "local-exec" {
    command = <<-EOT
      aws eks update-kubeconfig --region ${var.aws-region} --name ${local.env}-${local.org}-${var.cluster-name}
      echo "ArgoCD Admin Password:"
      kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
      echo ""
      echo "ArgoCD Server URL:"
      kubectl get svc argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
      echo ""
    EOT
  }
} 