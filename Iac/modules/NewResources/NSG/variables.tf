variable "nsg_name" {
  type        = string
  description = "Specifies the name of the network security group"
}
variable "location" {
  type        = string
  description = "Specifies the supported Azure location where the resource exists."
  default     = "eastus"
}
variable "rg_name" {
  type        = string
  description = "The name of the resource group in which to create the network security group"
}
