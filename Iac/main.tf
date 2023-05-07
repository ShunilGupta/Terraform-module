module "RG" {
    source                =  "/Data/RG"
    rg_name                  = var.rg_name
}

module "STORAGEACCOUNT" {
    source                 = "/Data/STORAGE_ACCOUNT"
    storage_account_name   = var.storage_account_name
    rg_name                = module.RG.name
}

module "FUNCTIONAPP" {
    source                  = "/MODULES/Functionapp"
    function_app            = var.function_app
    app_service_plan        = var.app_service_plan
    rg_name                 = module.RG.name
    location                = module.RG.location
    storage_account_name    = module.STORAGEACCOUNT.storage_account_name
    storage_account_access_key = module.STORAGEACCOUNT.storage_account_access_key
}