variable "scopes" {
  description = <<EOF
  A map of scopes to assign this role to. The key is an unique identifier containing only a-z, 0-9, _ and - as characters. The name of the key can be freely chosen. 
  The Value of the map is the actual scope (e.g a subscription or a resource_group).
  EOF
  type        = map(string)
  validation {
    # Check that the key of the map only uses the following characters: a-z, 0-9 and -
    condition     = alltrue([for key, value in var.scopes : can(regex("^([a-z0-9-_]+)$", key))])
    error_message = "The key of the map can only contain the following characters: a-z, 0-9, _ and -."
  }
}

variable "principal_ids" {
  description = <<EOF
  A map of principal_ids to assign this role to. The key is an unique identifier containing only a-z, 0-9, _ and - as characters. The name of the key can be freely chosen.
  The Value is the id of the principal (e.g User, Group, SP or Managed-Identity) to assign the role to.
  EOF
  type        = map(string)
  default     = {}
  validation {
    # Check that the key of the map only uses the following characters: a-z, 0-9 and -
    condition     = alltrue([for key, value in var.principal_ids : can(regex("^([a-z0-9-_]+)$", key))])
    error_message = "The key of the map can only contain the following characters: a-z, 0-9, _ and -."
  }
}

variable "azuread_security_group" {
  description = <<EOF
  Specifie this variable if you want to create an AzureAD security group and assign it the role definition.
  Either this or principal_ids must be set.
  The variable is an object with the following attributes:
  - name: (required) The name of the security group to create. Must be unique in the AzureAd tennant.
  - enable: (optional) Whether to create the security group. Default is true. If set to false, all other settings will be ignored.
  - description: (optional) The description of the security group.
  - member_upns: (optional) A set of user principal names to add to the security group. Example: ["peter.muster@cmiag.ch"]
  - member_object_ids: (optional) A set of object ids of e.g Users, Groups or managed Identities to assign to the security group.
  EOF
  type = object({
    name              = string
    enable            = optional(bool, true)
    description       = optional(string)
    member_upns       = optional(set(string), [])
    member_object_ids = optional(set(string), [])
  })
  default = {
    name   = "do_not_create_azuread_security_group"
    enable = false
  }
  validation {
    # If not null, check that the name of the group only contains the following characters: a-z, A-Z, 0-9 and _
    condition     = var.azuread_security_group == null ? true : can(regex("^([a-zA-Z0-9-_]+)$", var.azuread_security_group.name))
    error_message = "The name of the group can only contain the following characters: a-z, A-Z, 0-9 and _."
  }
  validation {
    # if not null, check that at least one of the member_upns or member_object_ids contains a element
    condition     = var.azuread_security_group.enable ? (length(var.azuread_security_group.member_upns) > 0 || length(var.azuread_security_group.member_object_ids) > 0) : true
    error_message = "At least one of the member_upns or member_object_ids must contain at least one element."
  }
}
variable "role_definitions" {
  type        = set(string)
  description = "A set of role definition names to assign to the principals or the azuread_security_group."
}
variable "skip_service_principal_aad_check" {
  description = "If set to true, Service Principal will not be checked. Useful if the Service Principal was created a short time ago and the AAD replication has not completed yet. Should only be set when principal_ids are only Service-Principals."
  type        = bool
  default     = false
}
