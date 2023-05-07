variable "vmss_name" {
  description = "The name of the Virtual Machine Scale Set"
  type        = string
}
variable "vm_prefix" {
  description = "The prefix for the Virtual Machine Scale Set VM names. If empty vmss_name will be used."
  type        = string
  default     = ""
  validation {
    condition     = length(var.vm_prefix) <= 9
    error_message = "vm_prefix must be 9 characters at most"
  }
}
variable "instances" {
  description = "The number of Virtual Machines in the Scale Set"
  type        = number
  default     = 0
}
variable "os_type" {
  description = "Either Linux or Windows"
  type        = string
}
variable "rg_name" {
  description = "The name of the Resource Group in which VMSS will be created. Changing this forces a new resource to be created."
  type        = string
}
variable "subnet_id" {
  description = "The id of the subnet in which VMSS will be created. Changing this forces a new resource to be created."
  type        = string
}
variable "vm_size" {
  description = "The size of the Virtual Machine for VMSS"
  type        = string
}
variable "upgrade_mode" {
  description = "Specifies how Upgrades should be performed. Possible values are Automatic, Manual and Rolling"
  type        = string
  default     = "Manual"
}
variable "automatic_os_upgrade_policy" {
  description = "Settings for automatic upgrade mode"
  type = object({
    disable_automatic_rollback  = bool
    enable_automatic_os_upgrade = bool
  })
  default = {
    disable_automatic_rollback  = false
    enable_automatic_os_upgrade = false
  }
}
variable "os_disk_size" {
  description = "The size of the Virtual Machine in VMSS"
  type        = number
}
variable "overprovision" {
  description = "Should Azure over-provision Virtual Machines in this Scale Set"
  type        = bool
  default     = false
}
variable "single_placement_group" {
  description = "Should this Virtual Machine Scale Set be limited to a Single Placement Group"
  type        = bool
  default     = false
}
variable "use_spot" {
  description = "If set to true spot instance will be used"
  type        = bool
  default     = false
}
variable "vm_password" {
  description = "The username of the local administrator used for Virtual Machine. This is mandatory for Windows Virtual Machine and optional for Linux Virtual Machine"
  type        = string
  sensitive   = true
  default     = ""
}
variable "os_disk_caching" {
  description = "The type of caching that should be used for OS disk. Possible values are None, ReadOnly and ReadWrite"
  type        = string
  default     = "ReadWrite"
}
variable "os_disk_ephmeral" {
  description = "Placement for ephmeral OS disk or empty if no ephmeral disk used"
  type        = string
  default     = ""
}
variable "os_disk_storage_account_type" {
  description = "The type of Storage Account which should back this OS disk. Possible values are Standard_LRS, StandardSSD_LRS, Premium_LRS, StandardSSD_ZRS and Premium_ZRS. Changing this forces a new resource to be created."
  type        = string
  default     = "StandardSSD_LRS"
}
variable "ssh_public_key" {
  description = "The Public Key which should be used for authentication,which needs to be atleast 2048-bit and in ssh-rsa format. Changing this forces a new resource to be created."
  type        = string
  sensitive   = true
  default     = ""
}
variable "tags" {
  description = "A map of tags to be add to all resources"
  type        = map(string)
  default     = {}
}
variable "source_image_id" {
  description = "The ID of the Image which this Virtual Machine should be created from. Changing this forces a new resource to be created."
  type        = string
  default     = ""
}
variable "plan" {
  type = set(object({
    publisher = string
    name      = string
    product   = string
  }))
  default = []
  validation {
    condition     = length(var.plan) <= 1
    error_message = "May contain only 1 element in the list"
  }
}
variable "source_image_reference" {
  description = "The ID of the Image which this Virtual Machine should be created from. Changing this forces a new resource to be created."
  type = set(object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  }))
  default = []
  validation {
    condition     = length(var.source_image_reference) <= 1
    error_message = "May contain only 1 element in the list"
  }
}
variable "identity_ids" {
  description = "List of user assigned managed identities"
  type        = list(string)
  default     = []
}
variable "custom_data" {
  description = "Base64 encoded cloud-init config"
  type        = string
  default     = ""
}
variable "user_data" {
  description = "Base64 encoded user_data"
  type        = string
  default     = ""
}