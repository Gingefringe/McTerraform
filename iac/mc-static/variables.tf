# aws profile
variable "aws-profile" {
  type = string
}

# region
variable "aws-region" {
  type = string
}

# key-name
variable "ec2-key-pair-name" {
  type = string
}

# bucket name for tf state
variable "tf-bucket" {
  type = string
}

# define the region specific ami images
variable "ami-images" {
  type = map(string)

  default = {
    "eu-west-2" = "ami-f976839e"
  }
}

# define the region specific availability zone
variable "aws-zones" {
  type = map(string)

  default = {
    "eu-west-2" = "eu-west-2a"
  }
}
