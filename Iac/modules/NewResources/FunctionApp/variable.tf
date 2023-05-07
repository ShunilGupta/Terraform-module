variable "location"{
    description = "The Azure Region in which all the resources groups should be created."
}

variable "rg_name"{
    description = "The name of the resource group"
}

variable "function_name"{
    description = "The name of the Function app"
}

variable "app_service_plan_id" {
    description = "App service plan id"
}

variable "storag_account_name" {
    description = "Storage account Name"
}

variable "storage_account_access_key"{
    description = "Storage account access key"
}