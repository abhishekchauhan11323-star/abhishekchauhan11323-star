# ==============================================================================
# CONTINUOUS OBSERVABILITY & METRICS SUITE
# ==============================================================================

# Central Log Analytics Workspace with 90-Day Retention
resource "azurerm_log_analytics_workspace" "central" {
  name                = "${var.prefix}-law-central"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 90 # Strict 90-day retention SLA

  tags = var.tags
}

# Application Insights (Workspace-based)
resource "azurerm_application_insights" "appinsights" {
  name                = "${var.prefix}-appi-telemetry"
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.central.id
  application_type    = "web"

  tags = var.tags
}

# CloudOps Action Group (PagerDuty / Email Escalations)
resource "azurerm_monitor_action_group" "cloudops" {
  name                = "${var.prefix}-ag-cloudops"
  resource_group_name = var.resource_group_name
  short_name          = "CloudOps"

  email_receiver {
    name                    = "PrimaryIncidentResponder"
    email_address           = var.admin_email
    use_common_alert_schema = true
  }

  tags = var.tags
}

# Enterprise Metric Alert: High CPU Alert
resource "azurerm_monitor_metric_alert" "cpu_alert" {
  name                = "${var.prefix}-alert-high-cpu"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_log_analytics_workspace.central.id]
  description         = "Triggered when query processing latency or CPU capacity exceeds 85%"
  severity            = 1
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.OperationalInsights/workspaces"
    metric_name      = "AverageUtilization"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 85
  }

  action {
    action_group_id = azurerm_monitor_action_group.cloudops.id
  }

  tags = var.tags
}
