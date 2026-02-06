provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_instance" "example" {
  ami           = "ami-0130d8d35bcd2d433"
  instance_type = "t3.micro"

  tags = {
    Name = "ExampleInstance"
  }
}

