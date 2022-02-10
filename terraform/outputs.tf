output "vpc_id" {
  value = module.network.vpc_id
}
output "subnet_ids" {
  value = module.network.subnet_ids
}
output "alb_sec_group_id" {
  value = module.network.alb_sec_group_id
}
output "db_url" {
  value = module.rds.instance_address
}
output "alb_names" {
  value = module.network.alb_names
}
output "acm_cert_arn" {
  value = module.network.acm_cert_arn
}
output "r53_zone_id" {
 value = module.network.r53_zone_id
}
