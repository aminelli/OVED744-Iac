virtual_machine = {
  name   = "vm-app-01"
  region = "westeurope"

  network = {
    subnet_id  = "subnet-app"
    private_ip = "10.0.1.10"
  }

  disks = [
    {
      name = "disk1"
      size = 128
      type = "Standard_LRS"
    }
  ]
}