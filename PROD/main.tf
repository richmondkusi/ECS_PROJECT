# configuring our network for Tenacity IT
resource "aws_vpc" "elearning-VPC" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = var.instance_tenancy
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = true 
  

  tags = {
    Name        = "${var.project_name}-VPC"
    Environment = var.environment
  }
}





# Using Data source for my Availability Zone
data "aws_availability_zones" "az" {

}



# Creating 2 public subnets
resource "aws_subnet" "web-pub-sub" {
  vpc_id            = aws_vpc.elearning-VPC.id
  count             = length(var.web_pub_sub_cidrs)
  cidr_block        = var.web_pub_sub_cidrs[count.index]
  availability_zone = data.aws_availability_zones.az.names[count.index]

  tags = {
    Name        = "web-pub-sub ${count.index + 1}"
    Environment = var.environment
  }
}

# Creating 2 private subnets
resource "aws_subnet" "app-priv-sub" {
  vpc_id            = aws_vpc.elearning-VPC.id
  count             = length(var.app_priv_sub_cidrs)
  cidr_block        = var.app_priv_sub_cidrs[count.index]
  availability_zone = data.aws_availability_zones.az.names[count.index]

  tags = {
    Name        = "app-priv-sub ${count.index + 1}"
    Environment = var.environment
  }
}





# Creating a public route table

resource "aws_route_table" "web-pub-RT" {
  vpc_id = aws_vpc.elearning-VPC.id

  tags = {
    Name        = "web-pub-RT"
    Environment = var.environment
  }
}

# public route table association with public subnets

resource "aws_route_table_association" "Pub-sub-assoc" {
  count          = length(var.web_pub_sub_cidrs)
  subnet_id      = element(aws_subnet.web-pub-sub[*].id, count.index)
  route_table_id = aws_route_table.web-pub-RT.id
}






# creating internet gateway

resource "aws_internet_gateway" "web-igw" {
  vpc_id = aws_vpc.elearning-VPC.id

  tags = {
    Name        = "elearning-igw"
    Environment = var.environment
  }
}



# Route the public subnet traffic through the IGW (Thus IGW association with public route table)
resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.web-pub-RT.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.web-igw.id
}



# Create a NAT gateway with an Elastic IP for each private subnet to get internet connectivity
resource "aws_eip" "app-eip" {
  count      = 2
  vpc        = true
  depends_on = [aws_internet_gateway.web-igw]
}

resource "aws_nat_gateway" "app-Nat-gateway" {
  count         = 2
  subnet_id     = element(aws_subnet.web-pub-sub.*.id, count.index)
  allocation_id = element(aws_eip.app-eip.*.id, count.index)
}

# Create a new route table for the private subnets, make it route non-local traffic through the NAT gateway to the internet
resource "aws_route_table" "app-priv-RT" {
  count  = 2
  vpc_id = aws_vpc.elearning-VPC.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.app-Nat-gateway.*.id, count.index)
  }

  tags = {
    Name        = "app-priv-RT ${count.index + 1}"
    Environment = var.environment
  }
}

# Explicitly associate the newly created route tables to the private subnets (so they don't default to the main route table)
resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = element(aws_subnet.app-priv-sub.*.id, count.index)
  route_table_id = element(aws_route_table.app-priv-RT.*.id, count.index)
}






#Creation of Security Group for alb
resource "aws_security_group" "elearning-sg" {
  name        = "elearning-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.elearning-VPC.id

  ingress {
    description = "HTTPS access from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description = "HTTP access from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "elearning-sg"
  }
}

#Creating a datadase security group
resource "aws_security_group" "rds-sg" {
  name   = "rds-sg"
  vpc_id = aws_vpc.elearning-VPC.id


  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    cidr_blocks = [ "0.0.0.0/0"]
    security_groups    = [aws_security_group.elearning-sg.id]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
}

# Subnet group creation
resource "aws_db_subnet_group" "dbsubgp" {
  name       = "dbsubgp"
  subnet_ids = var.all-subnet-ids

  tags = {
    Name = "dbsubgp"
  }
}



# Creating a database using Postgres
resource "aws_db_instance" "mydb1" {
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "12.15"
  instance_class         = "db.t2.micro"
  db_name                = "mydb1"
  username               = "hope"
  password               = "hopeforall"
  vpc_security_group_ids = ["${aws_security_group.rds-sg.id}"]
  parameter_group_name = "default.postgres12"
  availability_zone      = data.aws_availability_zones.az.names[1]
  skip_final_snapshot    = true
  publicly_accessible = true
  db_subnet_group_name = aws_db_subnet_group.dbsubgp.name


  tags = {
    "Name" = "mydb1"
  }
}

variable "container_port" {
  default = "80"
  description = "making my container port a variable"
}


# creation of security group for ECS Tasks
resource "aws_security_group" "ecs-tasks-sg" {
  name   = "${var.project_name}-sg-task-${var.environment}"
  vpc_id = aws_vpc.elearning-VPC.id
  
 
  ingress {
   protocol         = "tcp"
   from_port        = var.container_port
   to_port          = var.container_port
   security_groups    = [aws_security_group.elearning-sg.id]
   
  }
 
  egress {
   protocol         = "-1"
   from_port        = 0
   to_port          = 0
   cidr_blocks      = ["0.0.0.0/0"]
   ipv6_cidr_blocks = ["::/0"]
  }
}



# ECS CLUSTER creation
resource "aws_ecs_cluster" "elearning-cluster" {
  name = "${var.project_name}-cluster-${var.environment}"
}



# TASK DEFINITION creation


resource "aws_ecs_task_definition" "elearning-task-definition" {
  family                   = "elearning-task-definition"
  container_definitions    = <<EOF
  [
    {
      "name": "${var.project_name}-container-${var.environment}",
      "image": "${var.container_image}:latest",
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80,
          "protocol": "tcp"
         
        }
      ]
    }
  ]
EOF

  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "512"
  memory = "1024"
  task_role_arn = aws_iam_role.ecs_task_role.arn
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
}


# Create an IAM ROLE for ECS tasks to interact with ECR (using a Postgres)
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.project_name}-ecs-task-role"
 
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}


# IAM Policy for Postgresql
resource "aws_iam_policy" "postgres_policy" {
  name        = "${var.project_name}-task-policy-postgres"
  description = "IAM policy for PostgreSQL database"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "rds-db:connect"
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = [
          "rds:DescribeDBInstances",
          "rds:DescribeDBClusters",
          "rds:DescribeDBClusterEndpoints"
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = [
          "rds:ListTagsForResource",
          "rds:AddTagsToResource"
        ],
        Resource = "*"
      }
    ]
  })
}


 

 
resource "aws_iam_role_policy_attachment" "ecs-task-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.postgres_policy.arn
}

# Task Execution Role, because the application will be run serverless
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project_name}-ecsTaskExecutionRole"
 
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}
 
resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# SERVICE Creation
resource "aws_ecs_service" "elearning-service" {
 name                               = "${var.project_name}-service-${var.environment}"
 cluster                            = aws_ecs_cluster.elearning-cluster.id
 task_definition                    = aws_ecs_task_definition.elearning-task-definition.arn
 desired_count                      = 3
 deployment_minimum_healthy_percent = 50
 deployment_maximum_percent         = 200
 launch_type                        = "FARGATE"
 scheduling_strategy                = "REPLICA"
 
 network_configuration {
   security_groups  = [aws_security_group.ecs-tasks-sg.id]
   subnets          = var.app_priv_sub_ids
   assign_public_ip = true
 }
 
 load_balancer {
   target_group_arn = aws_alb_target_group.elearning-tg.arn
   container_name   = "${var.project_name}-container-${var.environment}"
   container_port   = var.container_port
 }
 
 lifecycle {
   ignore_changes = [task_definition, desired_count]
 }
}



# APPLICATION LOAD BALANCER
resource "aws_lb" "elearning-alb" {
  name               = "${var.project_name}-alb-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.elearning-sg.id]
  subnets            = var.web_pub_sub_ids
 
  enable_deletion_protection = false
}
 
resource "aws_alb_target_group" "elearning-tg" {
  name        = "${var.project_name}-tg-${var.environment}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.elearning-VPC.id
  target_type = "ip"
 
  health_check {
   healthy_threshold   = "3"
   interval            = "30"
   protocol            = "HTTP"
   matcher             = "200"
   timeout             = "3"
   path                = "/"
   unhealthy_threshold = "2"
  }
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.elearning-alb.id
  port              = 80
  protocol          = "HTTP"
 
  default_action {
   type = "redirect"
 
   redirect {
     port        = 443
     protocol    = "HTTPS"
     status_code = "HTTP_301"
   }
  }
}
 
resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_lb.elearning-alb.id
  port              = 443
  protocol          = "HTTPS"
  
  #NB: Create TLS Certificate for the HTTPS on console
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.alb_tls_cert_arn
 
  default_action {
    target_group_arn = aws_alb_target_group.elearning-tg.id
    type             = "forward"
  }
}



# AUTOSCALING
resource "aws_appautoscaling_target" "autoscale_target" {
  max_capacity       = 4
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.elearning-cluster.name}/${aws_ecs_service.elearning-service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# AUTOSCALING POLICY
resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  name               = "memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.autoscale_target.resource_id
  scalable_dimension = aws_appautoscaling_target.autoscale_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.autoscale_target.service_namespace
 
  target_tracking_scaling_policy_configuration {
   predefined_metric_specification {
     predefined_metric_type = "ECSServiceAverageMemoryUtilization"
   }
 
   target_value       = 80
  }
}
 
resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  name               = "cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.autoscale_target.resource_id
  scalable_dimension = aws_appautoscaling_target.autoscale_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.autoscale_target.service_namespace
 
  target_tracking_scaling_policy_configuration {
   predefined_metric_specification {
     predefined_metric_type = "ECSServiceAverageCPUUtilization"
   }
 
   target_value       = 60
  }
}


############

# CloudWatch alarm that triggers the autoscaling up policy
resource "aws_cloudwatch_metric_alarm" "ecs_policy_memory" {
  alarm_name          = "cb_cpu_utilization_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "85"

  dimensions = {
    ClusterName = aws_ecs_cluster.elearning-cluster.name
    ServiceName = aws_ecs_service.elearning-service.name
  }

  alarm_actions = [aws_appautoscaling_policy.ecs_policy_memory.arn]
}

# CloudWatch alarm that triggers the autoscaling down policy
resource "aws_cloudwatch_metric_alarm" "ecs_policy_cpu" {
  alarm_name          = "cb_cpu_utilization_low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "10"

  dimensions = {
    ClusterName = aws_ecs_cluster.elearning-cluster.name
    ServiceName = aws_ecs_service.elearning-service.name
  }

  alarm_actions = [aws_appautoscaling_policy.ecs_policy_cpu.arn]
}


# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "elearning_log_group" {
  name              = "/ecs/elearning-app"
  retention_in_days = 30

  tags = {
    Name = "elearning-log-group"
  }
}

resource "aws_cloudwatch_log_stream" "elearning_log_stream" {
  name           = "elearning-log-stream"
  log_group_name = aws_cloudwatch_log_group.elearning_log_group.name
}
