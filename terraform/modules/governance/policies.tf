# ==============================================================================
# POLICY ENFORCEMENT & CIS AZURE FOUNDATIONS v2.0 BENCHMARK
# ==============================================================================

# Custom Policy Definition: Automated Deny Public IP Creation
resource "azurerm_policy_definition" "deny_public_ips" {
  name         = "deny-public-ip-creation"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Deny creation of Network Interfaces with Public IPs"
  description  = "Enforces Zero-Trust network boundary by denying any NIC configured with a public IP"

  metadata = <<METADATA
    {
      "category": "Network Security",
      "version": "1.0.0"
    }
  METADATA

  policy_rule = <<POLICY_RULE
    {
      "if": {
        "allOf": [
          {
            "field": "type",
            "equals": "Microsoft.Network/networkInterfaces"
          },
          {
            "not": {
              "field": "Microsoft.Network/networkInterfaces/ipConfigurations[*].publicIpAddress.id",
              "equals": ""
            }
          }
        ]
      },
      "then": {
        "effect": "Deny"
      }
    }
  POLICY_RULE
}

# Policy Assignment to Resource Group
resource "azurerm_resource_group_policy_assignment" "deny_public_ip_assignment" {
  name                 = "assign-deny-public-ip"
  resource_group_id    = var.primary_resource_group_id
  policy_definition_id = azurerm_policy_definition.deny_public_ips.id
  display_name         = "Zero-Trust: Deny Public IPs on Workload NICs"
}

# Mandatory Tagging Policy Assignment (Require Environment tag)
resource "azurerm_resource_group_policy_assignment" "require_env_tag" {
  name                 = "assign-require-env-tag"
  resource_group_id    = var.primary_resource_group_id
  # Built-in policy: Require a tag on resources
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/87488d51-3cb2-42b3-aab0-42403127a4e1"
  display_name         = "Mandatory Governance: Require Environment Tag"

  parameters = jsonencode({
    tagName = {
      value = "Environment"
    }
  })
}
