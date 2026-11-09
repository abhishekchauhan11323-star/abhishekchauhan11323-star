# 🔒 Security & Compliance Governance — CIS Azure Foundations v2.0 Benchmark

**Lead Architect:** Abhishek Chauhan  
**Security Standard:** CIS Azure Foundations Benchmark v2.0 / NIST SP 800-53 / ISO 27001  

---

## 1. Compliance Matrix

| CIS Control # | CIS Recommendation | Landing Zone Implementation | Status |
|---|---|---|---|
| **1.1** | Ensure Multi-Factor Authentication (MFA) is enabled for all privileged users | Conditional Access Policies + Azure AD Privileged Identity Management (PIM) | **ENFORCED** |
| **2.1** | Ensure that Microsoft Defender for Cloud is enabled for all subscriptions | `azurerm_security_center_subscription_pricing` enabled for VMs, Storage & Containers | **ENFORCED** |
| **3.1** | Ensure storage accounts disallow public blob access | Storage accounts enforce private endpoints and `allow_nested_items_to_be_public = false` | **ENFORCED** |
| **3.7** | Ensure default network access rule for storage accounts is set to deny | Key Vault & Storage ACLs configured with `default_action = "Deny"` | **ENFORCED** |
| **4.1** | Ensure that Azure Key Vault has Purge Protection enabled | `purge_protection_enabled = true` on `azurerm_key_vault` | **ENFORCED** |
| **4.2** | Ensure that Azure Key Vault uses RBAC permissions model | `enable_rbac_authorization = true` on all Key Vault instances | **ENFORCED** |
| **5.1** | Ensure that Network Security Groups (NSGs) restrict inbound Internet traffic | Subnets protected with default-deny NSGs; zero direct inbound from 0.0.0.0/0 | **ENFORCED** |
| **5.2** | Ensure that Azure Firewall IDPS mode is set to Alert & Deny | `azurerm_firewall_policy.intrusion_detection.mode = "Deny"` | **ENFORCED** |
| **6.1** | Ensure Log Analytics retention is configured to at least 90 days | `azurerm_log_analytics_workspace.retention_in_days = 90` | **ENFORCED** |
| **7.1** | Ensure Customer-Managed Keys (CMK) are used for disk encryption | `azurerm_disk_encryption_set` using RSA-4096 HSM key | **ENFORCED** |

---

## 2. Policy Enforcement Engine

Azure Policy definitions deployed in this repository:
1. **Automated Deny Public IPs**: Blocks creation of any Network Interface containing `publicIpAddress.id`.
2. **Mandatory Tagging**: Requires `Environment`, `Owner`, `Compliance`, and `CostCenter` tags before resource provisioning succeeds.
3. **Audit Insecure TLS**: Flags any storage or API endpoint communicating with TLS versions lower than TLS 1.2.
