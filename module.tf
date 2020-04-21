module "caf_name_la" {
  source  = "aztfmod/caf-naming/azurerm"
  version = "~> 0.1.0"
    
  name    = var.name
  type    = "la"
  convention  = var.convention
}

resource "azurerm_log_analytics_workspace" "log_analytics" {
  name                = module.caf_name_la.la
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.retention_in_days
  tags                = local.tags
}

locals {
  solution_list = keys(var.solution_plan_map)
}

resource "azurerm_log_analytics_solution" "la_solution" {
  count                 = length(local.solution_list)
  solution_name         = element(local.solution_list, count.index)
  location              = var.location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.log_analytics.id
  workspace_name        = azurerm_log_analytics_workspace.log_analytics.name

  // tags = var.tags
  // Tags not implemented in TF for azurerm_log_analytics_solution

  plan {
      product        = var.solution_plan_map[element(local.solution_list, count.index)].product
      publisher      = var.solution_plan_map[element(local.solution_list, count.index)].publisher
    }
  }
