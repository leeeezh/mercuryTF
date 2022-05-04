#create nlb
resource "aws_lb" "nlb" {
  name               = "mercurynlb"
  internal           = false
  load_balancer_type = "network"
  
  subnets            = [aws_subnet.pub-frontend.id]
  
  

  tags = {
    Name = "MercuryNLB80"
  }
}
  



#create target group 
resource "aws_lb_target_group" "httpTG" {
  name     = "FrontendHttpTG"
  port     = 80
  protocol = "HTTP"
  target_type = "instance"
  vpc_id   = aws_vpc.mainvpc.id

  health_check {
      healthy_threshold = 2
      unhealthy_threshold = 3
      timeout = 60
      interval = 100
  }
  
  tags = {
    Name = "FrontendHttpTG"
  }
  
} 



#add frontend and backend to targetgroup
resource "aws_lb_target_group_attachment" "lbbackend" {
  target_group_arn = aws_lb_target_group.httpTG.id
  target_id        = aws_instance.ec2Backend.id
  port             = 80

  
}
 

resource "aws_lb_target_group_attachment" "lbfrontend" {
  target_group_arn = aws_lb_target_group.httpTG.id
  target_id        = aws_instance.ec2webserver.id
  port             = 80
} 