# CNAME pointing to the load balancer hostname (auto-managed by Cloudflare LB)
resource "cloudflare_record" "app" {
  zone_id = var.cloudflare_zone_id
  name    = var.hostname
  value   = cloudflare_load_balancer.main.name
  type    = "CNAME"
  ttl     = 1 # auto (proxied)
  proxied = true
}
