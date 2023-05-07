

data "azurerm_resource_group" "platform" {
  name = "NetworkWatcherRG"
}

data "azurerm_subnet" "test" {
  name                 = "mySubnet"
  virtual_network_name = "myVnet"
  resource_group_name  = "NetworkWatcherRG"
}

locals {
  disable_password_authentication = length(var.ssh_public_key) > 0 ? true : false
  admin_username                  = "vmssadmin"
  admin_password                  = local.disable_password_authentication ? null : length(var.vm_password) > 0 ? var.vm_password : random_string.admin_password.result
  os_disk_ephmeral                = length(var.os_disk_ephmeral) > 0
  os_disk_storage_account_type    = local.os_disk_ephmeral ? "Standard_LRS" : var.os_disk_storage_account_type
  os_disk_caching                 = local.os_disk_ephmeral ? "ReadOnly" : var.os_disk_caching
}

resource "random_string" "admin_password" {
  length           = 16
  upper            = true
  lower            = true
  numeric          = true
  special          = true
  override_special = "@.#$%"
}

resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                 = var.vmss_name
  computer_name_prefix = var.vm_prefix
  resource_group_name  = data.azurerm_resource_group.platform.name
  location             = data.azurerm_resource_group.platform.location
  sku                  = var.vm_size
  instances            = var.instances
  admin_username       = local.admin_username
  admin_password       = local.admin_password
  priority             = var.use_spot ? "Spot" : "Regular"
  eviction_policy      = var.use_spot ? "Delete" : null

  dynamic "admin_ssh_key" {
    for_each = local.disable_password_authentication ? [var.ssh_public_key] : []
    content {
      username   = local.admin_username
      public_key = admin_ssh_key.value
    }
  }

  source_image_id = length(var.source_image_id) > 0 ? var.source_image_id : null
  dynamic "source_image_reference" {
    for_each = length(var.source_image_id) > 0 ? [] : var.source_image_reference
    content {
      publisher = source_image_reference.value["publisher"]
      offer     = source_image_reference.value["offer"]
      sku       = source_image_reference.value["sku"]
      version   = source_image_reference.value["version"]
    }
  }

  dynamic "plan" {
    for_each = var.plan
    content {
      publisher = plan.value["publisher"]
      product   = plan.value["product"]
      name      = plan.value["name"]
    }
  }

  dynamic "identity" {
    for_each = length(var.identity_ids) > 0 ? { UserAssigned = var.identity_ids } : { SystemAssigned = null }
    content {
      type         = identity.key
      identity_ids = identity.value
    }
  }

  os_disk {
    disk_size_gb         = var.os_disk_size
    caching              = local.os_disk_caching
    storage_account_type = local.os_disk_storage_account_type
    dynamic "diff_disk_settings" {
      for_each = local.os_disk_ephmeral ? [var.os_disk_ephmeral] : []
      content {
        option    = "Local"
        placement = diff_disk_settings.value
      }
    }
  }

  network_interface {
    name    = var.vmss_name
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = var.subnet_id
    }
  }

  dynamic "automatic_os_upgrade_policy" {
    for_each = var.upgrade_mode == "Automatic" ? [var.automatic_os_upgrade_policy] : []
    content {
      disable_automatic_rollback  = automatic_os_upgrade_policy.value["disable_automatic_rollback"]
      enable_automatic_os_upgrade = automatic_os_upgrade_policy.value["enable_automatic_os_upgrade"]
    }
  }

  disable_password_authentication = local.disable_password_authentication
  overprovision                   = var.overprovision
  single_placement_group          = var.single_placement_group
  upgrade_mode                    = var.upgrade_mode
  tags                            = var.tags
  custom_data                     = length(var.custom_data) > 0 ? var.custom_data : null
  user_data                       = length(var.user_data) > 0 ? var.user_data : null

  lifecycle {
    ignore_changes = [tags, instances]
  }
}