provider "aws" {
  region = "us-east-1"
}

# create vpc

resource "aws_vpc" "Altschool_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "Altschool_vpc"
  }
}

# create internet gateway

resource "aws_internet_gateway" "Altschool_internet_gateway" {
  vpc_id = aws_vpc.Altschool_vpc.id
  tags = {
    "name" = "altschool-igw"
  }
}

# create public route table

resource "aws_route_table" "Altschool-route-table-public" {
  vpc_id = aws_vpc.Altschool_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Altschool_internet_gateway.id
  }
  tags = {
    Name = "Altschool-route-table-public"
  }
}

# Associate public subnet 1 with route table

resource "aws_route_table_association" "Altschool-public-subnet1-association" {
  subnet_id      = aws_subnet.Altschool-public-subnet1.id
  route_table_id = aws_route_table.Altschool-route-table-public.id
}

# Associate public subnet 2 with public route table

resource "aws_route_table_association" "Altschool-public-subnet2-association" {
  subnet_id      = aws_subnet.Altschool-public-subnet2.id
  route_table_id = aws_route_table.Altschool-route-table-public.id
}

# create subnet 1

resource "aws_subnet" "Altschool-public-subnet1" {
  vpc_id                  = aws_vpc.Altschool_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name = "Altschool-public-subnet1"
  }
}
 # creat subnet 2

resource "aws_subnet" "Altschool-public-subnet2" {
  vpc_id                  = aws_vpc.Altschool_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"
  tags = {
    Name = "Altschool-public-subnet2"
  }
}

# create network acl

resource "aws_network_acl" "Altschool-network_acl" {
  vpc_id     = aws_vpc.Altschool_vpc.id
  subnet_ids = [aws_subnet.Altschool-public-subnet1.id, aws_subnet.Altschool-pu>
  ingress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}

#create security group for load balancer

resource "aws_security_group" "Altschool-load_balancer_sg" {
  name        = "Altschool-load-balancer-sg"
  description = "Security group for the load balancer"
  vpc_id      = aws_vpc.Altschool_vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# create security group to allow port 22, 80 and 443

resource "aws_security_group" "Altschool-security-grp-rule" {
  name        = "allow_ssh_http_https"
  description = "Allow SSH, HTTP and HTTPS inbound traffic for private instance>
  vpc_id      = aws_vpc.Altschool_vpc.id
 ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.Altschool-load_balancer_sg.id]
  }
 ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.Altschool-load_balancer_sg.id]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
  tags = {
    Name = "Altschool-security-grp-rule"
  }
}

# creating instances 1

resource "aws_instance" "Altschool1" {
  ami             = "ami-00874d747dde814fa"
  instance_type   = "t2.micro"
  key_name        = "holidaychalleng"
  security_groups = [aws_security_group.Altschool-security-grp-rule.id]
  subnet_id       = aws_subnet.Altschool-public-subnet1.id
  availability_zone = "us-east-1a"
  tags = {
    Name   = "tmetiko-Altschool-1"
    source = "terraform"
  }
}

# creating instance 2

 resource "aws_instance" "Altschool2" {
  ami             = "ami-00874d747dde814fa"
  instance_type   = "t2.micro"
  key_name        = "holidaychalleng"
  security_groups = [aws_security_group.Altschool-security-grp-rule.id]
  subnet_id       = aws_subnet.Altschool-public-subnet2.id
  availability_zone = "us-east-1b"
  tags = {
    Name   = "tmetiko-Altschool-2"
    source = "terraform"
  }
}

# creating instance 3

resource "aws_instance" "Altschool3" {
  ami             = "ami-00874d747dde814fa"
  instance_type   = "t2.micro"
  key_name        = "holidaychalleng"
  security_groups = [aws_security_group.Altschool-security-grp-rule.id]
  subnet_id       = aws_subnet.Altschool-public-subnet1.id
  availability_zone = "us-east-1a"
  tags = {
    Name   = "tmetiko-Altschool-3"
    source = "terraform"
  }
}

# crewte a file to store the IP addresses of the instances

resource "local_file" "Ip_address" {
  filename = "/vagrant/altterrafoamproject/host-inventory"
  content  = <<EOT
${aws_instance.Altschool1.public_ip}
${aws_instance.Altschool2.public_ip}
${aws_instance.Altschool3.public_ip}
  EOT
}

# create an application load balancer

resource "aws_lb" "Altschool-load-balancer" {
  name               = "Altschool-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.Altschool-load_balancer_sg.id]
  subnets            = [aws_subnet.Altschool-public-subnet1.id, aws_subnet.Alts>

# enable_cross_zone_load_balancing = true

  enable_deletion_protection = false
  depends_on                 = [aws_instance.Altschool1, aws_instance.Altschool>
}

# create target groups

resource "aws_lb_target_group" "Altschool-target-group" {
  name     = "Altschool-target-group"
  target_type = "instance"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.Altschool_vpc.id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

# Create the listener
resource "aws_lb_listener" "Altschool-listener" {
  load_balancer_arn = aws_lb.Altschool-load-balancer.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.Altschool-target-group.arn
  }
}

# Create the listener rule

resource "aws_lb_listener_rule" "Altschool-listener-rule" {
  listener_arn = aws_lb_listener.Altschool-listener.arn
  priority     = 1
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.Altschool-target-group.arn
  }
  condition {
    path_pattern {
      values = ["/"]
    }
  }
}

# Attach the target group to the load balancer
resource "aws_lb_target_group_attachment" "Altschool-target-group-attachment1" {
  target_group_arn = aws_lb_target_group.Altschool-target-group.arn
  target_id        = aws_instance.Altschool1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "Altschool-target-group-attachment2" {
  target_group_arn = aws_lb_target_group.Altschool-target-group.arn
  target_id        = aws_instance.Altschool2.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "Altschool-target-group-attachment3" {
  target_group_arn = aws_lb_target_group.Altschool-target-group.arn
  target_id        = aws_instance.Altschool3.id
  port             = 80
}

