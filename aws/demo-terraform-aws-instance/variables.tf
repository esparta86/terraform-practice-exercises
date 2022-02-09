variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type = string
  default = "ExampleAppServerInstance"
}

variable "instance_ami" {
  description = "Value of the ami EC2"
  type = string
  default = "ami-0ab4d1e9cf9a1215a"
}