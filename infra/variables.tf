variable "resource_group" {
  type        = string
  description = "Nome do Resource Group no Azure"
  default     = "rh-devops-lab"
}

variable "storage_account" {
  type        = string
  description = "Nome da Storage Account para o tfstate"
  default     = "tfstatecurso"
}

variable "container_name" {
  type        = string
  description = "Nome do container do backend"
  default     = "tfstate"
}

variable "location" {
  type        = string
  description = "Região do Azure"
  default     = "eastus"
}

variable "registry_name" {
  type        = string
  description = "Nome do Azure Container Registry"
  default     = "devopsautomationid"
}