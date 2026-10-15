# The app server
resource "aws_instance" "app" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = "t3.micro"
  vpc_security_group_ids      = [aws_security_group.app.id]
  associate_public_ip_address = true

  # Bootstrap script: install docker and run the app
  user_data                   = file("${path.module}/user_data.sh")
  user_data_replace_on_change = true

  # Require IMDSv2 (token-based instance metadata)
  metadata_options {
    http_tokens = "required"
  }

  tags = {
    Name = "mini-devops-lab-app"
  }
}
