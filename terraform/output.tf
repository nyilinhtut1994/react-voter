output "instance_public_ip" {
  value = resource.aws_instance.public_ip
  sensitive = true
}