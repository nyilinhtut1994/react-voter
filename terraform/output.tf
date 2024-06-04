output "instance_public_ip" {
  value = resource.aws_instance.nodejs-server.public_ip
}