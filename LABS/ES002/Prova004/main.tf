# dynamic "example_rule" {
#   for_each = local.ports
# 
#   content {
#     port = example_rule.value
#   }
# }

# example_rule {
#   port = 80
# }
# 
# example_rule {
#   port = 443
# }
# 
# example_rule {
#   port = 8080
# }

variable "ingresses" {
  type = list(
    object(
      {
        from_port   = number
        to_port     = number
        protocol    = string
        cidr_blocks = list(string)
      }
    )
  )
}


resource "aws_security_group" "web2" {
  name = "web-sg-2"

  dynamic "ingress" {
    for_each = var.ingresses

    labels = [ "value", "ingress" ]

    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks

    }
  }
}

resource "aws_security_group" "web" {
  name = "web-sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.10/32"]
  }
}


### dynamic "block_type" {
###   for_each = collection
###   iterator = item### 

###   content {
###     # Argomenti del blocco annidato generato
###   }
### }

locals {
  ports = [80, 443, 8080]
}


