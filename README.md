# Azure RBAC-Policy

Module to assign RBAC roles to principal_ids or a AzureAD security group.

## Requirements

In order for the module to be able to create AzureAD security groups, the User creating the security group must have the following permissions in AzureAD:

- Group.ReadWrite.All
- Directory.ReadWrite.All

## Example

The following example assigns the role "Contributor" to the principal with the id <principal_id> on the specified resource group:

```bash
module "example_rbac_security_group" {
  source = "spacelift.io/cminformatik/azure_security_rbac_policy/azure"
  version = "2.0.0"
  scopes = {
    rg = <ressource_group_id>
  }
  azuread_security_group = {
    name    = "test_rbac"
    member_upns = ["peter.muster@cmiag.ch", "hans.muster@cmiag.ch"]
  }
  role_definitions = ["Contributor", "Reader"]
}
```

The following example assigns the role "DNS Zone Contributor" to a managed identity over the scope of two subscriptions:

```bash
module "example_rbac_prinicpal_ids" {
  source = "spacelift.io/cminformatik/azure_security_rbac_policy/azure"
  version = "2.0.0"
  scopes = {
    subscription_1 = <subscription_id1>
    subscription_2 = <subscription_id2>
  }
  principal_ids = {
    managed_identity = <managged_identity_id>
  }
  role_definitions = ["DNS Zone Contributor", "Reader"]
}
```

It is also possible to assign roles to the security group created within another module block:

```bash
module "example_rbac_include_sub_group" {
  source = "spacelift.io/cminformatik/azure_security_rbac_policy/azure"
  version = "2.0.0"
  scopes = {
    subscription_1 = <subscription_id1>
  }
  azuread_security_group = {
    name    = "test_rbac_include"
    member_upns = ["peter.muster@cmiag.ch", "hans.muster@cmiag.ch"]
    member_object_ids = [module.example_rbac_security_group.azuread_security_group_object_id]
  }
  role_definitions = ["KeyVautl Administrator"]
}
```

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                               | Version  |
| ------------------------------------------------------------------ | -------- |
| <a name="requirement_azurerm"></a> [azurerm](#requirement_azurerm) | >=3.50.0 |

## Providers

| Name                                                               | Version  |
| ------------------------------------------------------------------ | -------- |
| <a name="provider_azuread"></a> [azuread](#provider_azuread)       | n/a      |
| <a name="provider_azurerm"></a> [azurerm](#provider_azurerm)       | >=3.50.0 |
| <a name="provider_terraform"></a> [terraform](#provider_terraform) | n/a      |

## Modules

No modules.

## Resources

| Name                                                                                                                            | Type        |
| ------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [azuread_group.main](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group)                     | resource    |
| [azurerm_role_assignment.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource    |
| [terraform_data.conditions](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data)             | resource    |
| [azuread_user.main](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/user)                    | data source |

## Inputs

| Name                                                                                                                              | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             | Type                                                                                                                                                                                                            | Default                                                                                   | Required |
| --------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------- | :------: |
| <a name="input_azuread_security_group"></a> [azuread_security_group](#input_azuread_security_group)                               | Specifie this variable if you want to create an AzureAD security group and assign it the role definition.<br> Either this or principal_ids must be set.<br> The variable is an object with the following attributes:<br> - name: (required) The name of the security group to create. Must be unique in the AzureAd tennant.<br> - enable: (optional) Whether to create the security group. Default is true. If set to false, all other settings will be ignored.<br> - description: (optional) The description of the security group.<br> - member_upns: (optional) A set of user principal names to add to the security group. Example: ["peter.muster@cmiag.ch"]<br> - member_object_ids: (optional) A set of object ids of e.g Users, Groups or managed Identities to assign to the security group. | <pre>object({<br> name = string<br> enable = optional(bool, true)<br> description = optional(string)<br> member_upns = optional(set(string), [])<br> member_object_ids = optional(set(string), [])<br> })</pre> | <pre>{<br> "enable": false,<br> "name": "do_not_create_azuread_security_group"<br>}</pre> |    no    |
| <a name="input_principal_ids"></a> [principal_ids](#input_principal_ids)                                                          | A map of principal_ids to assign this role to. The key is an unique identifier containing only a-z, 0-9, \_ and - as characters. The name of the key can be freely chosen.<br> The Value is the id of the principal (e.g User, Group, SP or Managed-Identity) to assign the role to.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    | `map(string)`                                                                                                                                                                                                   | `{}`                                                                                      |    no    |
| <a name="input_role_definitions"></a> [role_definitions](#input_role_definitions)                                                 | A set of role definition names to assign to the principals or the azuread_security_group.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               | `set(string)`                                                                                                                                                                                                   | n/a                                                                                       |   yes    |
| <a name="input_scopes"></a> [scopes](#input_scopes)                                                                               | A map of scopes to assign this role to. The key is an unique identifier containing only a-z, 0-9, \_ and - as characters. The name of the key can be freely chosen. <br> The Value of the map is the actual scope (e.g a subscription or a resource_group).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             | `map(string)`                                                                                                                                                                                                   | n/a                                                                                       |   yes    |
| <a name="input_skip_service_principal_aad_check"></a> [skip_service_principal_aad_check](#input_skip_service_principal_aad_check) | If set to true, Service Principal will not be checked. Useful if the Service Principal was created a short time ago and the AAD replication has not completed yet. Should only be set when principal_ids are only Service-Principals.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   | `bool`                                                                                                                                                                                                          | `false`                                                                                   |    no    |

## Outputs

| Name                                                                                                                                   | Description                                                                             |
| -------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------- |
| <a name="output_azuread_sercurity_group_name"></a> [azuread_sercurity_group_name](#output_azuread_sercurity_group_name)                | Name of the security group. Only available if a security group was specified.           |
| <a name="output_azuread_sercurity_group_object_id"></a> [azuread_sercurity_group_object_id](#output_azuread_sercurity_group_object_id) | The id of the created security group. Only available if a security group was specified. |

<!-- END_TF_DOCS -->

# Breaking changes

## 2.0.0

- Die Input variabel "role_definition" wurde durch die variabel "role_definitions" ersetzt. Die neue Variabel erwartet ein Set von Rollen-Namen. Rollen-IDs oder Custom-Rollen werden nicht mehr unterstützt. Wird eine Custom-Rolle mit spezifischen Berechtigungen benötigt, muss diese im CMI-Shared-Infrastructure Repository im Projekt "Custom-Roles" angelegt werden.
