output "ami_id" {
  description = "ID of the selected Amazon Linux 2023 image"
  value       = data.aws_ami.al2023.id
}

output "ami_name" {
  description = "Name of the selected image"
  value       = data.aws_ami.al2023.name
}
