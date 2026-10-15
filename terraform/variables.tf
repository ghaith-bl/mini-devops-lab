variable "region" {
  description = "AWS region to deploy into (project home region)"
  type        = string
  default     = "eu-north-1"
}

variable "my_ip" {
  description = "My public IPv4 address, allowed to reach the app on port 5000"
  type        = string
}
