output "route53_fdqn" {
  description = "Route53 FQDN"
  value       = module.route53.*.route53_fdqn
}