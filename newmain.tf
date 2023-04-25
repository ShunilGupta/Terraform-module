locals {
  nsg_inbound_rules = { for idx, security_rule in var.nsg_inbound_rules : security_rule.name => {
    idx : idx,
    security_rule : security_rule,
    }
  }
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_subnet" "snet" {
  name                 = var.subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.rg.name
}

data "azurerm_storage_account" "storeacc" {
  count               = var.storage_account_name != null ? 1 : 0
  name                = var.storage_account_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "random_password" "passwd" {
  count       = (var.os_flavor == "linux" && var.disable_password_authentication == false && var.admin_password == null ? 1 : (var.os_flavor == "windows" && var.admin_password == null ? 1 : 0))
  length      = var.random_password_length
  min_upper   = 4
  min_lower   = 2
  min_numeric = 4
  special     = false

  keepers = {
    admin_password = var.vmscaleset_name
  }
}

#---------------------------------------------------------------
# Network security group for Virtual Machine Network Interface
#---------------------------------------------------------------
resource "azurerm_network_security_group" "nsg" {
  count               = var.existing_network_security_group_id == null ? 1 : 0
  name                = lower("nsg_${var.vmscaleset_name}_${data.azurerm_resource_group.rg.location}_in")
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  tags                = merge({ "resourcename" = lower("nsg_${var.vmscaleset_name}_${data.azurerm_resource_group.rg.location}_in") }, var.tags, )

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "azurerm_network_security_rule" "nsg_rule" {
  for_each                    = { for k, v in local.nsg_inbound_rules : k => v if k != null }
  name                        = each.key
  priority                    = 100 * (each.value.idx + 1)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = each.value.security_rule.destination_port_range
  source_address_prefix       = each.value.security_rule.source_address_prefix
  destination_address_prefix  = element(concat(data.azurerm_subnet.snet.address_prefixes, [""]), 0)
  description                 = "Inbound_Port_${each.value.security_rule.destination_port_range}"
  resource_group_name         = data.azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.0.name
  depends_on                  = [azurerm_network_security_group.nsg]
}

#---------------------------------------
# Linux Virutal machine scale set
#---------------------------------------
resource "azurerm_linux_virtual_machine_scale_set" "linux_vmss" {
  count                                             = var.os_flavor == "linux" ? 1 : 0
  name                                              = format("vm%s%s", lower(replace(var.vmscaleset_name, "/[[:^alnum:]]/", "")), count.index + 1)
  computer_name_prefix                              = var.computer_name_prefix == null && var.instances_count == 1 ? substr(var.vmscaleset_name, 0, 15) : substr(format("%s%s", lower(replace(var.vmscaleset_name, "/[[:^alnum:]]/", "")), count.index + 1), 0, 15)
  resource_group_name                               = data.azurerm_resource_group.rg.name
  location                                          = data.azurerm_resource_group.rg.location
  sku                                               = var.virtual_machine_size
  instances                                         = var.instances_count
  admin_username                                    = var.admin_username
  admin_password                                    = var.disable_password_authentication == false && var.admin_password == null ? element(concat(random_password.passwd.*.result, [""]), 0) : var.admin_password
  custom_data                                       = var.custom_data
  disable_password_authentication                   = var.disable_password_authentication
  overprovision                                     = var.overprovision
  do_not_run_extensions_on_overprovisioned_machines = var.do_not_run_extensions_on_overprovisioned_machines
  encryption_at_host_enabled                        = var.enable_encryption_at_host
  health_probe_id                                   = var.enable_load_balancer ? azurerm_lb_probe.lbp[0].id : null
  platform_fault_domain_count                       = var.platform_fault_domain_count
  provision_vm_agent                                = true
  proximity_placement_group_id                      = var.enable_proximity_placement_group ? azurerm_proximity_placement_group.appgrp.0.id : null
  scale_in_policy                                   = var.scale_in_policy
  single_placement_group                            = var.single_placement_group
  source_image_id                                   = var.source_image_id != null ? var.source_image_id : null
  upgrade_mode                                      = var.os_upgrade_mode
  zones                                             = var.availability_zones
  zone_balance                                      = var.availability_zone_balance
  tags                                              = merge({ "resourcename" = format("vm%s%s", lower(replace(var.vmscaleset_name, "/[[:^alnum:]]/", "")), count.index + 1) }, var.tags, )

  dynamic "admin_ssh_key" {
    for_each = var.disable_password_authentication ? [1] : []
    content {
      username   = var.admin_username
      public_key = var.admin_ssh_key_data == null ? tls_private_key.rsa[0].public_key_openssh : file(var.admin_ssh_key_data)
    }
  }

  dynamic "source_image_reference" {
    for_each = var.source_image_id != null ? [] : [1]
    content {
      publisher = var.custom_image != null ? var.custom_image["publisher"] : var.linux_distribution_list[lower(var.linux_distribution_name)]["publisher"]
      offer     = var.custom_image != null ? var.custom_image["offer"] : var.linux_distribution_list[lower(var.linux_distribution_name)]["offer"]
      sku       = var.custom_image != null ? var.custom_image["sku"] : var.linux_distribution_list[lower(var.linux_distribution_name)]["sku"]
      version   = var.custom_image != null ? var.custom_image["version"] : var.linux_distribution_list[lower(var.linux_distribution_name)]["version"]
    }
  }

  os_disk {
    storage_account_type      = var.os_disk_storage_account_type
    caching                   = var.os_disk_caching
    disk_encryption_set_id    = var.disk_encryption_set_id
    disk_size_gb              = var.disk_size_gb
    write_accelerator_enabled = var.enable_os_disk_write_accelerator
  }

  dynamic "additional_capabilities" {
    for_each = var.enable_ultra_ssd_data_disk_storage_support ? [1] : []
    content {
      ultra_ssd_enabled = var.enable_ultra_ssd_data_disk_storage_support
    }
  }

  dynamic "data_disk" {
    for_each = var.additional_data_disks
    content {
      lun                  = data_disk.key
      disk_size_gb         = data_disk.value
      caching              = "ReadWrite"
      create_option        = "Empty"
      storage_account_type = var.additional_data_disks_storage_account_type
    }
  }

  network_interface {
    name                          = lower("nic-${format("vm%s%s", lower(replace(var.vmscaleset_name, "/[[:^alnum:]]/", "")), count.index + 1)}")
    primary                       = true
    dns_servers                   = var.dns_servers
    enable_ip_forwarding          = var.enable_ip_forwarding
    enable_accelerated_networking = var.enable_accelerated_networking
    network_security_group_id     = var.existing_network_security_group_id == null ? azurerm_network_security_group.nsg.0.id : var.existing_network_security_group_id

    ip_configuration {
      name                                   = lower("ipconig-${format("vm%s%s", lower(replace(var.vmscaleset_name, "/[[:^alnum:]]/", "")), count.index + 1)}")
      primary                                = true
      subnet_id                              = data.azurerm_subnet.snet.id
      load_balancer_backend_address_pool_ids = var.enable_load_balancer ? [azurerm_lb_backend_address_pool.bepool[0].id] : null
      load_balancer_inbound_nat_rules_ids    = var.enable_load_balancer && var.enable_lb_nat_pool ? [azurerm_lb_nat_pool.natpol[0].id] : null

      dynamic "public_ip_address" {
        for_each = var.assign_public_ip_to_each_vm_in_vmss ? [1] : []
        content {
          name                = lower("pip-${format("vm%s%s", lower(replace(var.vmscaleset_name, "/[[:^alnum:]]/", "")), "0${count.index + 1}")}")
          public_ip_prefix_id = var.public_ip_prefix_id
        }
      }
    }
  }

  dynamic "automatic_os_upgrade_policy" {
    for_each = var.os_upgrade_mode == "Automatic" ? [1] : []
    content {
      disable_automatic_rollback  = true
      enable_automatic_os_upgrade = true
    }
  }

  dynamic "rolling_upgrade_policy" {
    for_each = var.os_upgrade_mode != "Manual" ? [1] : []
    content {
      max_batch_instance_percent              = var.rolling_upgrade_policy.max_batch_instance_percent
      max_unhealthy_instance_percent          = var.rolling_upgrade_policy.max_unhealthy_instance_percent
      max_unhealthy_upgraded_instance_percent = var.rolling_upgrade_policy.max_unhealthy_upgraded_instance_percent
      pause_time_between_batches              = var.rolling_upgrade_policy.pause_time_between_batches
    }
  }

  dynamic "automatic_instance_repair" {
    for_each = var.enable_automatic_instance_repair ? [1] : []
    content {
      enabled      = var.enable_automatic_instance_repair
      grace_period = var.grace_period
    }
  }

  dynamic "identity" {
    for_each = var.managed_identity_type != null ? [1] : []
    content {
      type         = var.managed_identity_type
      identity_ids = var.managed_identity_type == "UserAssigned" || var.managed_identity_type == "SystemAssigned, UserAssigned" ? var.managed_identity_ids : null
    }
  }

  dynamic "boot_diagnostics" {
    for_each = var.enable_boot_diagnostics ? [1] : []
    content {
      storage_account_uri = var.storage_account_name != null ? data.azurerm_storage_account.storeacc.0.primary_blob_endpoint : var.storage_account_uri
    }
  }

  lifecycle {
    ignore_changes = [
      tags,
      automatic_instance_repair,
      automatic_os_upgrade_policy,
      rolling_upgrade_policy,
      instances,
      data_disk,
    ]
  }


#-----------------------------------------------
# Auto Scaling for Virtual machine scale set
#-----------------------------------------------
resource "azurerm_monitor_autoscale_setting" "auto" {
  count               = var.enable_autoscale_for_vmss ? 1 : 0
  name                = lower("auto-scale-set-${var.vmscaleset_name}")
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  target_resource_id  = var.os_flavor == "windows" ? azurerm_windows_virtual_machine_scale_set.winsrv_vmss.0.id : azurerm_linux_virtual_machine_scale_set.linux_vmss.0.id

  profile {
    name = "default"
    capacity {
      default = var.instances_count
      minimum = var.minimum_instances_count == null ? var.instances_count : var.minimum_instances_count
      maximum = var.maximum_instances_count
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = var.os_flavor == "windows" ? azurerm_windows_virtual_machine_scale_set.winsrv_vmss.0.id : azurerm_linux_virtual_machine_scale_set.linux_vmss.0.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = var.scale_out_cpu_percentage_threshold
      }
      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = var.scaling_action_instances_number
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = var.os_flavor == "windows" ? azurerm_windows_virtual_machine_scale_set.winsrv_vmss.0.id : azurerm_linux_virtual_machine_scale_set.linux_vmss.0.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = var.scale_in_cpu_percentage_threshold
      }
      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = var.scaling_action_instances_number
        cooldown  = "PT1M"
      }
    }
  }
}
new
