# Route 53 configuration for heliconetest.com
# This assumes you have a hosted zone already created for heliconetest.com

# Data source to get the existing hosted zone
data "aws_route53_zone" "helicone" {
  name         = "heliconetest.com"
  private_zone = false
}

# Get the load balancer from Kubernetes
data "kubernetes_service" "ingress_nginx" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }

  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_eks_node_group.eks_nodes
  ]
}

# Create A record for heliconetest.com pointing to the load balancer
resource "aws_route53_record" "helicone_main" {
  zone_id         = data.aws_route53_zone.helicone.zone_id
  name            = "heliconetest.com"
  type            = "A"
  allow_overwrite = true

  alias {
    name                   = data.kubernetes_service.ingress_nginx.status.0.load_balancer.0.ingress.0.hostname
    zone_id                = local.elb_zone_id
    evaluate_target_health = true
  }
}

# Create A record for grafana.heliconetest.com pointing to the load balancer
resource "aws_route53_record" "helicone_grafana" {
  zone_id         = data.aws_route53_zone.helicone.zone_id
  name            = "grafana.heliconetest.com"
  type            = "A"
  allow_overwrite = true

  alias {
    name                   = data.kubernetes_service.ingress_nginx.status.0.load_balancer.0.ingress.0.hostname
    zone_id                = local.elb_zone_id
    evaluate_target_health = true
  }
}

# Create A record for argocd.heliconetest.com pointing to the load balancer
resource "aws_route53_record" "helicone_argocd" {
  zone_id         = data.aws_route53_zone.helicone.zone_id
  name            = "argocd.heliconetest.com"
  type            = "A"
  allow_overwrite = true

  alias {
    name                   = data.kubernetes_service.ingress_nginx.status.0.load_balancer.0.ingress.0.hostname
    zone_id                = local.elb_zone_id
    evaluate_target_health = true
  }
}

# Local value for ELB zone ID (us-west-2) - Application Load Balancer
locals {
  elb_zone_id = "Z1H1FL5HABSF5"  # This is the canonical hosted zone ID for Application Load Balancers in us-west-2
} 