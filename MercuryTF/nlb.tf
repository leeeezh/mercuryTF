#create nlb ssl
resource "aws_lb" "nlb" {
  name               = "mercurynlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_subnet.pub-frontend.id]
  
  tags = {
    Name = "MercuryNLB80"
  }
}

#nlb add target group still not working
resource "aws_lb_listener" "nlb_front_end" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = "80"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.httpsTG.arn
  }
}



#create target group 
resource "aws_lb_target_group" "httpsTG" {
  name     = "FrontendHttpsTG"
  port              = "80"
  protocol = "TCP"
  target_type = "instance"
  vpc_id   = aws_vpc.mainvpc.id

  health_check {
      
      protocol = "TCP"
      healthy_threshold = 2
      interval = 30
  }
  
  tags = {
    Name = "FrontendHttpsTG"
  }
  
} 



#add frontend and backend to targetgroup
resource "aws_lb_target_group_attachment" "lbbackend" {
  target_group_arn = aws_lb_target_group.httpsTG.id
  target_id        = aws_instance.ec2Backend.id
  port             = 80
  

  
}
 

resource "aws_lb_target_group_attachment" "lbfrontend" {
  target_group_arn = aws_lb_target_group.httpsTG.id
  target_id        = aws_instance.ec2webserver.id
  port             = 80
  
} 
