applications = [
  {
    name = "vm-api"
    instance_type = "Standard_D2s_v5"
    enabled = true
  },
  {
    name = "vm-worker"
    instance_type = "Standard_B2s"
    enabled = true
  },
  {
    name = "vm-db"
    instance_type = "Standard_B2s"
    enabled = true
  }
]


vpcs = {
  vpc-1 = {
    cidr_block = "10.0.0.0/16"
  },
  vpc-2 = {
    cidr_block = "10.1.0.0/22"
  }
}