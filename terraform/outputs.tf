output "ami_id" {
  description = "ID of the selected Amazon Linux 2023 image"
  value       = data.aws_ami.al2023.id
}

output "ami_name" {
  description = "Name of the selected image"
  value       = data.aws_ami.al2023.name
}

output "instance_id" {
  description = "ID of the app server"
  value       = aws_instance.app.id
}

output "public_ip" {
  description = "Public IP of the app server"
  value       = aws_instance.app.public_ip
}

output "app_url" {
  description = "URL to test the app"
  value       = "http://${aws_instance.app.public_ip}:5000"
}

