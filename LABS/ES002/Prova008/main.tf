module "network" {
  source = "./modules/network"
}

module "virtual_machine" {
  source = "./modules/virtual-machine"

  subnet_id = module.network.subnet_id
}


module "storage" {
  source = "./modules/storage"

  name                = "stappdev001"
  location            = "westeurope"
  replication_type    = "LRS"
}