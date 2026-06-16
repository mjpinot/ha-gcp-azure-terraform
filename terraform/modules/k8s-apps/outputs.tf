output "ingress_ip" {
  description = "External IP of the NGINX ingress LoadBalancer"
  value       = try(helm_release.ingress_nginx.status[0].load_balancer[0].ingress[0].ip, "pending")
}
