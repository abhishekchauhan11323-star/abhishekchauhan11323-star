# ==============================================================================
# HUB VNET & SUB-ALLOCATIONS
# ==============================================================================
resource "azurerm_virtual_network" "hub" {
  name                = "${var.prefix}-vnet-hub"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.hub_address_space
  tags                = var.tags
}

resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.3.0/24"]
}

# ==============================================================================
# AZURE FIREWALL PREMIUM WITH IDPS & THREAT INTEL
# ==============================================================================
resource "azurerm_public_ip" "firewall_pip" {
  name                = "${var.prefix}-pip-afw"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
  tags                = var.tags
}

resource "azurerm_firewall_policy" "fw_policy" {
  name                = "${var.prefix}-afw-policy"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Premium"
  threat_intelligence_mode = "Alert"

  intrusion_detection {
    mode = "Deny" # Active IDPS enforcement
  }

  tags = var.tags
}

resource "azurerm_firewall" "firewall" {
  name                = "${var.prefix}-afw-hub"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Premium"
  firewall_policy_id  = azurerm_firewall_policy.fw_policy.id
  zones               = ["1", "2", "3"]

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.firewall.id
    public_ip_address_id = azurerm_public_ip.firewall_pip.id
  }

  tags = var.tags
}

# ==============================================================================
# AZURE BASTION (ZERO DIRECT PUBLIC IP ACCESS TO WORKLOADS)
# ==============================================================================
resource "azurerm_public_ip" "bastion_pip" {
  name                = "${var.prefix}-pip-bastion"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_bastion_host" "bastion" {
  name                = "${var.prefix}-bastion-hub"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  tunneling_enabled   = true

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion_pip.id
  }

  tags = var.tags
}

# ==============================================================================
# SPOKE 1: WORKLOAD VNET
# ==============================================================================
resource "azurerm_virtual_network" "spoke_workload" {
  name                = "${var.prefix}-vnet-spoke-workload"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.spoke_workload_address_space
  tags                = var.tags
}

resource "azurerm_subnet" "workload_app" {
  name                 = "snet-workload-app"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke_workload.name
  address_prefixes     = ["10.1.1.0/24"]
}

# ==============================================================================
# SPOKE 2: DATA TIER VNET
# ==============================================================================
resource "azurerm_virtual_network" "spoke_data" {
  name                = "${var.prefix}-vnet-spoke-data"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.spoke_data_address_space
  tags                = var.tags
}

resource "azurerm_subnet" "data_tier" {
  name                 = "snet-data-private"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke_data.name
  address_prefixes     = ["10.2.1.0/24"]
}

# ==============================================================================
# VNET PEERINGS (HUB <-> SPOKES)
# ==============================================================================
resource "azurerm_virtual_network_peering" "hub_to_workload" {
  name                         = "peer-hub-to-workload"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke_workload.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "workload_to_hub" {
  name                         = "peer-workload-to-hub"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = azurerm_virtual_network.spoke_workload.name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "hub_to_data" {
  name                         = "peer-hub-to-data"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke_data.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "data_to_hub" {
  name                         = "peer-data-to-hub"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = azurerm_virtual_network.spoke_data.name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

# ==============================================================================
# UDR ROUTE TUNNELING (0.0.0.0/0 NEXT HOP -> AZURE FIREWALL)
# ==============================================================================
resource "azurerm_route_table" "spoke_udr" {
  name                          = "${var.prefix}-rt-spoke-tunneling"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  disable_bgp_route_propagation = false

  route {
    name                   = "DefaultRouteToAzureFirewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.firewall.ip_configuration[0].private_ip_address
  }

  tags = var.tags
}

resource "azurerm_subnet_route_table_association" "workload_udr" {
  subnet_id      = azurerm_subnet.workload_app.id
  route_table_id = azurerm_route_table.spoke_udr.id
}

resource "azurerm_subnet_route_table_association" "data_udr" {
  subnet_id      = azurerm_subnet.data_tier.id
  route_table_id = azurerm_route_table.spoke_udr.id
}

# ==============================================================================
# NETWORK SECURITY GROUPS (NSGs) WITH ZERO-TRUST MICRO-SEGMENTATION
# ==============================================================================
resource "azurerm_network_security_group" "workload_nsg" {
  name                = "${var.prefix}-nsg-workload"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "Allow-IntraVNet-Inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "Deny-All-Inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "workload_nsg_assoc" {
  subnet_id                 = azurerm_subnet.workload_app.id
  network_security_group_id = azurerm_network_security_group.workload_nsg.id
}

# ==============================================================================
# PRIVATE DNS ZONES
# ==============================================================================
resource "azurerm_private_dns_zone" "kv_dns" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "kv_hub_link" {
  name                  = "link-kv-hub"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.kv_dns.name
  virtual_network_id    = azurerm_virtual_network.hub.id
}
