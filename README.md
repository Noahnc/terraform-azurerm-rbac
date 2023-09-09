# Azure RBAC-Policy

Module for assigning azure rbac role definitions. The module allows you to assign multiple role_definitions over multiple scopes to multiple principle_ids or a single security group.
The module is therefore highly flexible and can be used to create lots of rbac rules at once.

## Requirements

In order for the module to be able to create AzureAD security groups, the user used by azurerm needs the following permissions in AzureAD:

- Group.ReadWrite.All
- Directory.ReadWrite.All

## Example

The following example creates a security group and assigns it the roles "Contributor" and "Reader" over the scope of a resource group:

```bash
module "example_rbac_security_group" {
  source  = "Noahnc/rbac/azurerm"
  version = "1.0.1"
  scopes = {
    rg = <ressource_group_id>
  }
  azuread_security_group = {
    name    = "test_rbac"
    member_upns = ["peter.muster@example.ch", "hans.muster@example.ch"]
  }
  role_definitions = ["Contributor", "Reader"]
}
```

The following example assigns the role "DNS Zone Contributor" to a managed identity over the scope of two subscriptions:

```bash
module "example_rbac_prinicpal_ids" {
  source  = "Noahnc/rbac/azurerm"
  version = "1.0.1"
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
  source  = "Noahnc/rbac/azurerm"
  version = "1.0.1"
  scopes = {
    subscription_1 = <subscription_id1>
  }
  azuread_security_group = {
    name    = "test_rbac_include"
    member_upns = ["peter.muster@example.ch", "hans.muster@example.ch"]
    member_object_ids = [module.example_rbac_security_group.azuread_security_group_object_id]
  }
  role_definitions = ["KeyVautl Administrator"]
}
```

The Input for Scopes and principal_ids can also be generated with for loops on the fly:

```bash
module "example_rbac_prinicpal_ids" {
  source  = "Noahnc/rbac/azurerm"
  version = "1.0.1"
  scopes = {for key, value in azurerm_subscription.main : value.name => value.id}
  principal_ids = {for key, value in azurerm_user_assigned_identity.main : value.name => value.principal_id}
  role_definitions = ["DNS Zone Contributor", "Reader"]
}
```

> **_NOTE:_** The Key of the `scopes` and `principal_ids` map can be freely chosen, they are only used to generate unique terraform for_each keys.
