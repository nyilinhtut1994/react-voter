terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}


data "aws_ami" "app_ami" {
    most_recent = true
    owners = ["099720109477"] # ubuntu #if owner is amazon add "amazon"

    filter {
        name = "name"
        values = ["ubuntu/images/*ubuntu-*-22.04-*"]
    }
}

resource "aws_instance" "nodejs-server" {
  #count = 1
  ami = data.aws_ami.app_ami.id
  instance_type = var.instance_type
  key_name = aws_key_pair.deployer.key_name
  connection {
    type = "ssh"
    host = self.public_ip
    user = "ubuntu"
    private_key = var.private_key
    timeout = "5m"
  }
  availability_zone = "ap-southeast-1a"
  vpc_security_group_ids = aws_security_group.nodejs
  iam_instance_profile = aws_iam_instance_profile.EC2_access_ECR.name

  tags = {
    "name" = "nodejs-server"
  }
}

resource "aws_iam_instance_profile" "EC2_access_ECR" {
  name = "ec2_access_ecr"
  role = "ec2_access_ecr"
}
resource "aws_security_group" "nodejs" {
  egress = [ 
    {
        cidr_blocks = ["0.0.0.0/0"]
        description = "egress"
        from_port = 0
        ipv6_cidr_blocks = ["::/0"]
        prefix_list_ids = []
        protocol = "-1"
        security_groups = []
        self = false
        to_port = 0
    }
  ]
  ingress = [
    {
        cidr_blocks = ["0.0.0.0/0"]
        description = "allow icmp"
        from_port = 0
        ipv6_cidr_blocks = ["::/0"]
        prefix_list_ids = []
        protocol = "-1"
        security_groups = []
        self = false
        to_port = 0
    },
    {
        cidr_blocks = ["0.0.0.0/0"]
        description = "allow ssh"
        from_port = 22
        ipv6_cidr_blocks = ["::/0"]
        prefix_list_ids = []
        protocol = "tcp"
        security_groups = []
        self = false
        to_port = 22
    },   
    {
        cidr_blocks = ["0.0.0.0/0"]
        description = "allow http"
        from_port = 80
        ipv6_cidr_blocks = ["::/0"]
        prefix_list_ids = []
        protocol = "tcp"
        security_groups = []
        self = false
        to_port = 80
    },
        {
        cidr_blocks = ["0.0.0.0/0"]
        description = "custom port"
        from_port = 8080
        ipv6_cidr_blocks = ["::/0"]
        prefix_list_ids = []
        protocol = "tcp"
        security_groups = []
        self = false
        to_port = 8080
    }
   ]
}

resource "aws_key_pair" "deployer" {
  key_name = var.key_name
  public_key = var.public_key
}