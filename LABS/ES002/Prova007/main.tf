# META ARGUMENTS

resource "aws_instance" "web" {
  count = 3

  ami           = 1
  instance_type = "t3.micro"
}


variable "instance_names" {
  type    = list(string)
  default = ["web-01", "web-02", "web-03"]
}

###################################

resource "aws_instance" "web2" {
  count = length(var.instance_names)

  ami           = 1
  instance_type = "t3.micro"

  tags = {
    Name = var.instance_names[count.index]
  }
}


variable "enable_monitoring" {
  type    = bool
  default = true
}

resource "aws_instance" "monitoring" {
  count = var.enable_monitoring ? 1 : 0

  ami           = 1
  instance_type = "t3.micro"
}


###################################

# Approccio for_each
variable "instances" {
  type = map(object({
    instance_type = string
    environment   = string
  }))

  default = {
    api = {
      instance_type = "t3.small"
      environment   = "production"
    }

    worker = {
      instance_type = "t3.medium"
      environment   = "production"
    }
  }
}

resource "aws_instance" "app" {
  for_each = var.instances

  ami           = 1
  instance_type = each.value.instance_type

  tags = {
    Name        = each.key
    Environment = each.value.environment
  }
}

##############################

resource "aws_iam_role_policy" "app" {
  name = "app-policy"
  role = aws_iam_role.app.id

  policy = data.aws_iam_policy_document.app.json
}

resource "aws_instance" "app" {
  ami           = 1
  instance_type = "t3.micro"

  depends_on = [
    aws_iam_role_policy.app
  ]
}

####################################

provider "aws" {
  region = "eu-west-1"
}

provider "aws" {
  alias  = "us"
  region = "us-east-1"
}


resource "aws_s3_bucket" "us_logs" {
  provider = aws.us

  bucket = "company-example-us-logs"
}

module "application_us" {
  source = "./modules/application"

  providers = {
    aws = aws.us
  }
}

###################################


resource "aws_instance" "app" {
  ami           = 1
  instance_type = "t3.micro"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_s3_bucket" "critical" {
  bucket = "company-critical-data"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_instance" "app" {
  ami           = 1
  instance_type = "t3.micro"

  tags = {
    Name = "app"
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "aws_instance" "app" {
  ami           = 1
  instance_type = "t3.micro"

  lifecycle {
    replace_triggered_by = [
      aws_launch_template.app2
    ]
  }
}


resource "aws_instance" "app" {
  ami           = var.ami_id
  instance_type = var.instance_type

  lifecycle {
    precondition {
      condition     = var.instance_type != ""
      error_message = "Il tipo di istanza deve essere specificato."
    }
    postcondition {
      condition     = var.instance_type != "t3.micro"
      error_message = "Il tipo di istanza non può essere t3.micro."
    }
  }
}
