output "azuread_sercurity_group_object_id" {
  description = "The id of the created security group. Only available if a security group was specified."
  value       = length(azuread_group.main) != 0 ? azuread_group.main.0.object_id : null
}

output "azuread_sercurity_group_name" {
  description = "Name of the security group. Only available if a security group was specified."
  value       = local.security_group_name
}