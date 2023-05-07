variable "rg_name" {
  type        = string
  description = "RG name in Azure"
}

variable "location" {
  type        = string
  description = "Resources location in Azure"
}

variable "function_app" {
  type        = string
  description = "Function app name in Azure"
}

variable "storage_account_name"{
  description = "Storage Account Name"
}

variable "app_service_plan" {
  type        = string
}

 variable "storage_account_access_key"{
   type       = string
 }