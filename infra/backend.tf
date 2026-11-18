terraform {
    backend "azure" {
        resource_group_name  = "rg-tfstate"
        storage_account_name = "tfstatecurso9087"
        container_name       = "tfstate"
        key                  = "terraform.tfstate"
    }
} 
    
