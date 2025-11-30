
# PROVIDER

provider "aws" {
  region = var.region
}

# SECURITY GROUPS

# ALB Security Group (Public)
resource "aws_security_group" "alb_sg" {
  name   = "alb-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# PUBLIC EC2 SECURITY GROUP

resource "aws_security_group" "public_ec2_sg" {
  name   = "public-ec2-sg"
  vpc_id = aws_vpc.main.id

  # Allow SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]     # you can restrict to your IP later
  }

  # Allow HTTP (optional)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "public-ec2-sg"
  }
}


# Private EC2 Security Group (Only accepts ALB traffic)
resource "aws_security_group" "private_sg" {
  name   = "private-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 1337
    to_port         = 1337
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

    # Allow SSH from Public EC2
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_ec2_sg.id]
  }
  

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#####################
# APPLICATION LOAD BALANCER


resource "aws_lb" "alb" {
  name               = "my-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public[*].id

  tags = {
    Name = "my-alb"
  }
}

#####################
# TARGET GROUP
#####################

resource "aws_lb_target_group" "tg" {
  name     = "my-tg"
  port     = 1337
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
  path                = "/_health"
  protocol            = "HTTP"
  port                = "1337"
  healthy_threshold   = 2
  unhealthy_threshold = 2
  interval            = 30
  timeout             = 5
}


  lifecycle {
    create_before_destroy = true
    ignore_changes        = [port]
  }
}

#####################
# ALB LISTENER
#####################

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}


# PUBLIC EC2 (Jump Server)

resource "aws_instance" "public" {
  ami                         = "ami-0c7217cdde317cfec"
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public[0].id
  key_name                    = var.key_name
  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.public_ec2_sg.id
  ]

  tags = {
    Name = "public-jump-server"
  }
}

#####################
# PRIVATE EC2 INSTANCE
#####################

resource "aws_instance" "app" {
  ami           = "ami-0c7217cdde317cfec"
  instance_type = var.instance_type
  subnet_id     = aws_subnet.private[0].id
  key_name      =var.key_name

  vpc_security_group_ids = [aws_security_group.private_sg.id]

  user_data = file("${path.module}/userdata.sh")

  tags = {
    Name = "private-app-server"
  }
}

#####################
# REGISTER INSTANCE TO TARGET GROUP
#####################

resource "aws_lb_target_group_attachment" "attach" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.app.id
  port             = 1337
}
