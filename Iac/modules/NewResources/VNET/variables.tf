variable "location"{
    description = "The Azure Region in which all the resources groups should be created."
}
variable "rg_name"{
    description = "The name of the resource group"
}
variable "vnetwork_name"{
    description = "The name of the virtual Network"
}
variable "vnet_address_space"{
    description = "The Network Address space"
}
variable "tags"{
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
variable "project_name"{}
variable "environment"{}

