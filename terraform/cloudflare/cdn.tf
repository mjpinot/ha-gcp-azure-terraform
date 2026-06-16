resource "cloudflare_ruleset" "cache" {
  zone_id = var.cloudflare_zone_id
  name    = "ha-cache-rules"
  kind    = "zone"
  phase   = "http_request_cache_settings"

  # Bypass cache for API calls
  rules {
    description = "Bypass cache for /api/*"
    expression  = "(http.request.uri.path matches \"^/api/\")"
    action      = "set_cache_settings"
    action_parameters {
      cache = false
    }
  }

  # Cache static assets aggressively
  rules {
    description = "Cache static assets 1 day"
    expression  = "(http.request.uri.path matches \"\\.(js|css|png|jpg|svg|ico|woff2)$\")"
    action      = "set_cache_settings"
    action_parameters {
      cache = true
      edge_ttl {
        mode    = "override_origin"
        default = 86400
      }
      browser_ttl {
        mode    = "override_origin"
        default = 86400
      }
    }
  }
}
