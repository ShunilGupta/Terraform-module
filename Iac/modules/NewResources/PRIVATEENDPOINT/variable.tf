variable "rg_name"{
    description = "The name of the resource group"
}
variable "private_endpoint_name"{
    description = "The name of the virtual Network"
}
variable "location"{
    description = "The Subnet Address space"
}
variable "subnet_id"{
    description = "The Subnet Name"
}
variable "private_service_conn_name"{
    description = "The Name for Private Service Connection Name"
}
variable "subresource_names"{
    description = "The Name for subresources in private end point"
}
variable "private_connection_resource_id"{
    description = "The id of private service connection id"
}