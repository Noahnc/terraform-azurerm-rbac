# Azure RBAC-Policy

Module for assigning azure rbac role definitions. The module allows you to assign multiple role_definitions over multiple scopes to multiple principle_ids or a single security group.
The module is therefore highly flexible and can be used to create lots of rbac rules at once.

## Requirements

In order for the module to be able to create AzureAD security groups, the User creating the security group must have the following permissions in AzureAD:

- Group.ReadWrite.All
- Directory.ReadWrite.All

## Example

The following example creates a security group and assigns it the roles "Contributor" and "Reader" over the scope of a resource group:

```bash
module "example_rbac_security_group" {
  source = "spacelift.io/cminformatik/azure_security_rbac_policy/azure"
  version = "2.0.0"
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
    member_upns = ["peter.muster@example.ch", "hans.muster@example.ch"]
    member_object_ids = [module.example_rbac_security_group.azuread_security_group_object_id]
  }
  role_definitions = ["KeyVautl Administrator"]
}
```
