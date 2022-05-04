
#create 2 private ec2 that auto install docker and assign to private subnet
#private
resource "aws_instance" "ec2Backend" {
  ami = "ami-0fe23c115c3ba9bac"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.pvt-backend.id
  security_groups  = [aws_security_group.block_tls.id]
  user_data = "${file("install_dockerbackend.sh")}"
  

   tags = {
    Name = "PublicEC2Backend"
  }


}

resource "aws_instance" "ec2webserver" {
  ami = "ami-0fe23c115c3ba9bac"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.pvt-backend.id
  security_groups  = [aws_security_group.block_tls.id]
  user_data = "${file("install_dockerfrontend.sh")}"
  
   tags = {
    Name = "PublicEC2Webserver"
  }


}

