 output "webserver-private-ip"{
     value = aws_instance.ansible-hosts[0].private_ip
}

 output "webserver-private-ip1"{
     value = aws_instance.ansible-hosts[1].private_ip
}