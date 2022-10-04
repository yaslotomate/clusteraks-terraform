terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.12.0"
    }
  }
}


provider "azurerm" {
  subscription_id = "${var.aks-cluster-sp-sub}"
  client_id       = "${var.aks-cluster-sp-client-id}"
  client_secret   = "${var.aks-cluster-sp-client-secret}"
  tenant_id       = "${var.aks-cluster-sp-client-tenant}"

  features {}
}



locals {
  tags = {
      projet      = "aks"
      environment = "Dev"
    }
}


# ============================================
#cree resoruce group
# ==========================================================
 resource "azurerm_resource_group" "tf-rg" {
    name        = "${var.aks-resource-group-name}"
    location    = "${var.aks-resource-group-location}"
   #tags        = "${local.tags}"
 }

# ===================================================
#cree conatiner registry
# ====================================================
resource "azurerm_container_registry" "acr" {
  name                     = "${var.registry-name}"
  location                 ="${var.aks-resource-group-location}" 
  resource_group_name      = "${var.aks-resource-group-name}"
  sku                      = "Basic"
  admin_enabled            = false
  depends_on               = [azurerm_resource_group.tf-rg] 
}

# ==============================================================
# deploie le cluster aks
# =======================================
resource "azurerm_kubernetes_cluster" "cluster-aks" {
  name                    = "${var.aks-cluster-name}"
  location                = "${var.aks-resource-group-location}"
  resource_group_name     = "${var.aks-resource-group-name}"
  kubernetes_version      = "1.24.0"
  dns_prefix              = "${var.aks-cluster-name}-dns"
  #tags                    = "${local.tags}"
   
  default_node_pool {
    name                  = "default"
    vm_size               = "Standard_D2_v2"
    enable_auto_scaling   = false
    node_count            = 1
  #  availability_zones    = ["1", "2", "3"]
    type                  = "VirtualMachineScaleSets"
  }

  network_profile {
    network_plugin = "azure"
    load_balancer_sku = "standard"
  }

  service_principal {
    client_id     = "${var.aks-cluster-sp-client-id}"
    client_secret = "${var.aks-cluster-sp-client-secret}"
  }
}

