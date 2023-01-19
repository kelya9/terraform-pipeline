provider "aws" {
  region = "us-east-1"
}

 resource "aws_vpc" "main" {
   cidr_block = "10.0.0.0/16"
   enable_dns_hostnames = true
}

# }

 resource "aws_internet_gateway" "gw" {
 }


# # resource "aws_nat_gateway" "example" {
# #   allocation_id = aws_eip.example.id
# #   subnet_id     = aws_subnet.subnet2.id

# #   tags = {
# #     Name = "gw NAT"
# #   }
# #    depends_on = [aws_internet_gateway.gw]
# # }

 resource "aws_internet_gateway_attachment" "main" {
   internet_gateway_id = aws_internet_gateway.gw.id
   vpc_id              = aws_vpc.main.id
 }

 resource "aws_subnet" "subnet1" {
   vpc_id     = aws_vpc.main.id
   cidr_block = "10.0.0.0/24"
   map_public_ip_on_launch = true

  depends_on = [aws_internet_gateway.gw]


  tags = {
    Name = var.tag-subnet[0]
  }
 }


 resource "aws_subnet" "subnet2" {
   vpc_id     = aws_vpc.main.id
   cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true

  tags = {
    Name = var.tag-subnet[1]
  }
 }
 resource "aws_route_table" "main" {
   vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.gw.id
 }


 }

 resource "aws_route_table_association" "main" {
   subnet_id      = aws_subnet.subnet1.id
   route_table_id = aws_route_table.main.id
}

 resource "aws_security_group" "main" {
   name        = "ansible-sg"
   vpc_id      = aws_vpc.main.id

   ingress {
     description      = "Allow https connection"
     from_port        = 443
     to_port          = 443
     protocol         = "tcp"
     cidr_blocks      = ["0.0.0.0/0"]
    
   }
  
  ingress {
    description      = "Allow ssh traffic"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

   ingress {
     description      = "Allow http traffic"
     from_port        = 80
     to_port          = 80
     protocol         = "tcp"
     cidr_blocks      = ["0.0.0.0/0"]
    
   }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

   tags = {
     Name = "Ansible"
   }
 }

# # resource "aws_network_interface" "main" {
# #   subnet_id   = aws_subnet.public-subnet1.id
# #   private_ips = ["10.0.15.0", "10.0.50.0"]
# #   security_groups = [aws_security_group.main.id]

# #   tags = {
# #     Name = "primary_network_interface"
# #   }
# # }
   resource "aws_instance" "ansible-master" {
   ami           = "ami-06878d265978313ca"
   instance_type = var.instance_type
   subnet_id = aws_subnet.subnet1.id
   #private_ip = var.private_ip[count.index]
   associate_public_ip_address = "true"
    key_name = "ansible"
    vpc_security_group_ids = [aws_security_group.main.id]
     tags = {
     Name = "ansibleserver-master"
     }
     depends_on = [
       aws_instance.ansible-hosts]
     
 }


 resource "aws_instance" "ansible-hosts" {
   ami           = "ami-06878d265978313ca"
   count = 2
   instance_type = var.instance_type
   subnet_id = aws_subnet.subnet2.id
   #private_ip = var.private_ip[count.index]
   associate_public_ip_address = "true"
    key_name = "ansible"
    vpc_security_group_ids = [aws_security_group.main.id]
     tags = {
     Name = "ansibleserver.${count.index}"
     }
 }
# #   network_interface {
# #     network_interface_id = aws_network_interface.main.id
# #     device_index         = 0
# #   }
# }

# resource "aws_vpc" "default" {
#   cidr_block           = "10.0.0.0/16"
#   enable_dns_hostnames = true
# }

# resource "aws_internet_gateway" "gw" {
#   vpc_id = aws_vpc.default.id
# }

# resource "aws_subnet" "tf_test_subnet" {
#   vpc_id                  = aws_vpc.default.id
#   cidr_block              = "10.0.0.0/24"
#   map_public_ip_on_launch = true

#   depends_on = [aws_internet_gateway.gw]
# }

# resource "aws_instance" "foo" {
#   # us-west-2
#   ami           = "ami-06878d265978313ca"
#   instance_type = "t2.micro"

#   private_ip = "10.0.0.12"
#   subnet_id  = aws_subnet.tf_test_subnet.id
# }

# resource "aws_eip" "new" {
#   vpc = true
#   instance                  = "aws_instance.ansible-hosts[0]"
#   associate_with_private_ip = "10.0.0.12"
#   depends_on                = [aws_internet_gateway.gw]
# }

# resource "aws_eip" "new2" {
#   vpc = true
#   instance                  = "aws_instance.ansible-hosts[1]"
#   associate_with_private_ip = "10.0.0.50"
#   depends_on                = [aws_internet_gateway.gw]
# }