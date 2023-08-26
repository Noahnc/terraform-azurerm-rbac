locals {
  # Creates a flattened list from the three input lists (scopes, role_definitions, principal_ids)
  # The result is a list of objects with the following attributes:
  # - identifier: The identifier of the role assignment, consisting of the scope, role name and principal ID. Is used as key for the for_each loop in the azurerm_role_assignment resource.
  # - scope: The scope of the role assignment.
  # - role_name: The name of the role to assign.
  # - principal_id: The principal ID to assign the role to. If an azuread_security_group is specified, this will be set to "azuread_security_group", which will be replaced with the ID of the created security group in the azurerm_role_assignment resource.
  falttened_scopes_principal_assignment = flatten([for scope_key, scope in var.scopes : [
    flatten([for role_name in var.role_definitions : [
      var.azuread_security_group.enable ? [
        for principal_key in ["azuread_security_group"] : {
          identifier   = "${scope_key}-${role_name}-${principal_key}"
          scope        = scope
          role_name    = role_name
          principal_id = "azuread_security_group"
        }
        ] : [
        for principal_key, principal_id in var.principal_ids : {
          identifier   = "${scope_key}-${role_name}-${principal_key}"
          scope        = scope
          principal_id = principal_id
          role_name    = role_name
        }
      ]]
  ])]])
  security_group_name = var.azuread_security_group.enable ? "sg-${var.azuread_security_group.name}-${terraform.workspace}" : null
}

resource "azurerm_role_assignment" "main" {
  for_each                         = { for assignment in local.falttened_scopes_principal_assignment : assignment.identifier => assignment }
  scope                            = each.value.scope
  role_definition_name             = each.value.role_name
  principal_id                     = each.value.principal_id == "azuread_security_group" ? azuread_group.main.0.id : each.value.principal_id
  skip_service_principal_aad_check = var.skip_service_principal_aad_check
  depends_on                       = [terraform_data.conditions]
}

# This data resource is just used as a dummy resource to trigger the preconditions every time one of the input variables changes.
resource "terraform_data" "conditions" {
  input = {
    principal_ids          = var.principal_ids
    scopes                 = var.scopes
    role_definitions       = var.role_definitions
    azuread_security_group = var.azuread_security_group
  }
  lifecycle {
    precondition {
      # make shure that principal_ids contains at least one element, if azuread_security_group is not enabled
      condition     = !var.azuread_security_group.enable ? length(var.principal_ids) > 0 : true
      error_message = "Specify at least one principal_id in the principal_ids input map."
    }
    precondition {
      # make shure that principal_ids is empty if azuread_security_group is enabled
      condition     = var.azuread_security_group.enable ? length(var.principal_ids) == 0 : true
      error_message = "If azuread_security_group is used, principal_ids must be empty."
    }
  }
}

data "azuread_user" "main" {
  for_each            = var.azuread_security_group.member_upns
  user_principal_name = each.key
}

resource "azuread_group" "main" {
  count                   = var.azuread_security_group.enable ? 1 : 0
  display_name            = local.security_group_name
  security_enabled        = true
  description             = var.azuread_security_group.description
  members                 = setunion(var.azuread_security_group.member_object_ids, toset([for user in data.azuread_user.main : user.id]))
  prevent_duplicate_names = true
}
