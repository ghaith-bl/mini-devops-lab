# Security group for the app instance
resource "aws_security_group" "app" {
  name        = "mini-devops-lab-app"
  description = "Allow app port from my IP only"
  vpc_id      = data.aws_vpc.default.id
}

# Inbound: Flask app port, only from my public IP
resource "aws_vpc_security_group_ingress_rule" "app_port" {
  security_group_id = aws_security_group.app.id
  description       = "Flask app from my IP"
  cidr_ipv4         = "${var.my_ip}/32"
  from_port         = 5000
  to_port           = 5000
  ip_protocol       = "tcp"
}

# Outbound: allow all (needed to install docker and pull the image)
resource "aws_vpc_security_group_egress_rule" "all_out" {
  security_group_id = aws_security_group.app.id
  description       = "Allow all outbound traffic"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
