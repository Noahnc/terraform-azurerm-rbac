provider "azurerm" {
  features {}
}

variables {
  role_definitions = [
    "Contributor",
    "Reader",
    "Owner"
  ]
  scopes = {
    "test_subscription" = "subscriptions/00000000-0000-0000-0000-000000000000"
  }
}

run "test_with_principal_ids" {
  command = plan

  variables {
    principal_ids = {
      "test_user" = "00000000-0000-0000-0000-000000000000"
    }
  }

  assert {
    condition     = length(azurerm_role_assignment.main) == 3
    error_message = "Expected 3 role assignments, got ${length(azurerm_role_assignment.main)}"
  }
  assert {
    condition     = length(azuread_group.main) == 0
    error_message = "Expected no Azure AD group to be created but got one in the plan"
  }
}

run "test_with_azuread_security_group" {
  command = plan
  variables {
    azuread_security_group = {
      name        = "test"
      description = "test group"
      member_object_ids = [
        "00000000-0000-0000-0000-000000000000",
        "00000000-0000-0000-0000-000000000001",
      ]

    }
  }
  assert {
    condition     = length(azurerm_role_assignment.main) == 3
    error_message = "Expected 3 role assignments, got ${length(azurerm_role_assignment.main)}"
  }
  assert {
    condition     = length(azuread_group.main) == 1
    error_message = "Expected no Azure AD group to be created but got one in the plan"
  }
  assert {
    condition     = azuread_group.main[0].display_name == "sg-test-default"
    error_message = "Expected Azure AD group to be named sg-test-default but got ${azuread_group.main[0].display_name}"
  }
}