# variable "region" {
#   default = "us-east-1"
# }

variable "instance_type" {
  default = "t2.micro"
 }
# variable "cidr-block-subnet" {
#     type= list
#     default= ["10.0.0.0/24", "10.0.1.0/24"]
# }
variable "tag-subnet" {
    default = ["public-subnet", "private-subnet"]
  
}

variable "private_ip" {
  default = [ "10.0.1.20", "10.0.1.50"]
}
