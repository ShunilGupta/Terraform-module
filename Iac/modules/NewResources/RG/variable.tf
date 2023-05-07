variable "location"{
    description = "The Azure Region in which all the resources groups should be created."
}

variable "rg_name"{
    description = "The name of the resource group"
}

variable "tags"{
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
variable "project_name"{}
variable "environment"{}

