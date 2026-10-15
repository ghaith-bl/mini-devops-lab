# Latest official Amazon Linux 2023 image (x86_64)
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"] # only images published by AWS itself

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}
