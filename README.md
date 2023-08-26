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
