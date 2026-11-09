output "hub_vnet_id" {
  value = azurerm_virtual_network.hub.id
}

output "firewall_private_ip" {
  value = azurerm_firewall.firewall.ip_configuration[0].private_ip_address
}

output "firewall_public_ip" {
  value = azurerm_public_ip.firewall_pip.ip_address
}

output "workload_vnet_id" {
  value = azurerm_virtual_network.spoke_workload.id
}

output "data_vnet_id" {
  value = azurerm_virtual_network.spoke_data.id
}

output "workload_subnet_id" {
  value = azurerm_subnet.workload_app.id
}

output "data_subnet_id" {
  value = azurerm_subnet.data_tier.id
}
