variable "rg_name" {
  type        = string
  description = "RG name in Azure"
}

variable "location" {
  type        = string
  description = "Resources location in Azure"
}

variable "aks_name" {
  type        = string
  description = "AKS name in Azure"
}

variable "container_registry_id"{
  description = "ACR ID"
}
variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version"
}

variable "system_node_count" {
  type        = number
  description = "Number of AKS worker nodes"
}

variable "node_resource_group" {
  type        = string
  description = "RG name for cluster resources in Azure"
}

variable "vnet_subnet_id"{
    type        = string
  description = "Subnet id"
}

variable "default_node_pool_labels"{
    type        = map(string)
  description = "Subnet id"
}