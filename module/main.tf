module "key_pair" {
  source      = "squareops/keypair/aws"
  environment = var.Environment
  key_name    = format("%s-%s-key", var.Environment, var.app_name)
  ssm_parameter_path = format("%s_%s_key", var.Environment, var.app_name)
}

resource "aws_security_group" "asg-sg" {
  name        = format("%s-%s-app_asg_sg", var.Environment, var.app_name)
  description = "Security group for Application Instances"
  vpc_id      = var.vpc_id

    ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = var.app_name
    Environment = var.Environment
    Owner       = var.Owner
  }
}

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.7.0"
  name    = format("%s-%s-asg", var.Environment, var.app_name)

  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  vpc_zone_identifier       = var.private_subnets
  wait_for_capacity_timeout = 0
  target_group_arns         = module.alb.target_group_arns
  health_check_type         = var.health_check_type
  default_instance_warmup   = 300
  enabled_metrics = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]

  instance_refresh = {
    strategy = "Rolling"
    preferences = {
      checkpoint_delay         = 60
      checkpoint_percentages   = [35, 70, 100]
      instance_warmup          = 300
      min_healthy_percentage   = 50
    }
    triggers = ["tag"]
  }

 # Launch template
  launch_template_name         = "${var.app_name}-lt"
  launch_template_description  = "Launch template example"
  update_default_version       = true
  image_id                     = var.image_id
  instance_type                = var.instance_type
  key_name                     = module.key_pair.key_pair_name
  ebs_optimized                = true
  enable_monitoring            = true
  security_groups              = [aws_security_group.asg-sg.id]
  iam_instance_profile_name    = aws_iam_instance_profile.instance-profile.name

  tags = {
    Environment = var.Environment
    Owner       = var.Owner
    Name        = var.app_name
  }
}



# Scaling Policies
# disk usage 
resource "aws_autoscaling_policy" "scale_up_on_high_disk_usage" {
  count                  = var.asg_scale_updown_disk_usage_policy ? 1 : 0
  name                   = "asg-disk-scale-up-policy"
  autoscaling_group_name = module.asg.autoscaling_group_name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1"
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "disk_usage_high_alarm" {
  count               = var.asg_scale_updown_disk_usage_policy ? 1 : 0
  alarm_name          = "asg-scale-up-alarm"
  alarm_description   = "asg-scale-up-disk-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "LogicalDisk % Used Space"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = var.disk_threshold_to_scale_up
  dimensions = {
    "AutoScalingGroupName" = module.asg.autoscaling_group_name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.scale_up_on_high_disk_usage[0].arn]
  depends_on      = [aws_autoscaling_policy.scale_up_on_high_disk_usage]
}


resource "aws_autoscaling_policy" "scale_down_on_low_disk_usage" {
  count                  = var.asg_scale_updown_disk_usage_policy ? 1 : 0
  name                   = "asg-disk-scale-down-policy"
  autoscaling_group_name = module.asg.autoscaling_group_name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1"
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "disk_usage_low_alarm" {
  count               = var.asg_scale_updown_disk_usage_policy ? 1 : 0
  alarm_name          = "asg-scale-down-alarm"
  alarm_description   = "asg-scale-down-disk-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "LogicalDisk % Used Space"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = var.disk_threshold_to_scale_down
  dimensions = {
    "AutoScalingGroupName" = module.asg.autoscaling_group_name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.scale_down_on_low_disk_usage[0].arn]
  depends_on      = [aws_autoscaling_policy.scale_down_on_low_disk_usage]
}


# ASGAverageCPUUtilization
resource "aws_autoscaling_policy" "asg_cpu_policy" {
  count                     = var.asg_cpu_policy ? 1 : 0
  name                      = "${var.app_name}-cpu-policy"
  autoscaling_group_name    = module.asg.autoscaling_group_name
  estimated_instance_warmup = 60
  policy_type               = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.cpu_value_threshold
  }
}

# ALBRequestCountPerTarget
resource "aws_autoscaling_policy" "asg_ALB_request_count_policy" {
  depends_on                = [module.alb]
  #count                     = var.asg_ALB_request_count_policy ? 1 : 0
  name                      = "${var.app_name}-ALBRequestCountPerTarget-policy"
  autoscaling_group_name    = module.asg.autoscaling_group_name
  estimated_instance_warmup = 60
  policy_type               = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label = "${module.alb.lb_arn_suffix}/${module.alb.target_group_arn_suffixes[0]}" 
    }
    target_value = var.target_value
  }
}

# RAM based
resource "aws_autoscaling_policy" "RAM_based_scale_up" {
  count                  = var.asg_RAM_based_scale_updown_policy ? 1 : 0
  name                   = "${var.app_name}-asg-RAM-scale-up-policy"
  autoscaling_group_name = module.asg.autoscaling_group_name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1"
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

resource "aws_autoscaling_policy" "RAM_based_scale_down" {
  count                  = var.asg_RAM_based_scale_updown_policy ? 1 : 0
  name                   = "${var.app_name}-asg-RAM-scale-down-policy"
  autoscaling_group_name = module.asg.autoscaling_group_name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1"
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "RAM_based_scale_up_alarm" {
  count               = var.asg_RAM_based_scale_updown_policy ? 1 : 0
  alarm_name          = "${var.app_name}-asg-scale-up-alarm"
  alarm_description   = "asg-scale-up-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "RAM_used_percent"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = var.RAM_threshold_to_scale_up
  dimensions = {
    "AutoScalingGroupName" = module.asg.autoscaling_group_name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.RAM_based_scale_up[0].arn]
  depends_on      = [aws_autoscaling_policy.RAM_based_scale_up]
}

resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  count               = var.asg_RAM_based_scale_updown_policy ? 1 : 0
  alarm_name          = "${var.app_name}-asg-scale-down-alarm"
  alarm_description   = "asg-scale-down-cpu-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "RAM_used_percent"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = var.RAM_threshold_to_scale_down
  dimensions = {
    "AutoScalingGroupName" = module.asg.autoscaling_group_name
  }
  actions_enabled = true
  alarm_actions   = [resource.aws_autoscaling_policy.RAM_based_scale_down[0].arn]
  depends_on      = [aws_autoscaling_policy.RAM_based_scale_down]
}



#SQS
resource "aws_autoscaling_policy" "customized_metric_specification" {
  count                  = var.asg_SQS_based_policy ? 1 : 0
  autoscaling_group_name = module.asg.autoscaling_group_name
  name                   = "${var.app_name}-customized-metric-SQS-policy"
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    target_value = var.target_value_SQS
    customized_metric_specification {
      metrics {
        label = "Get the queue size (the number of messages waiting to be processed)"
        id    = "m1"
        metric_stat {
          metric {
            namespace   = "AWS/SQS"
            metric_name = "ApproximateNumberOfMessagesVisible"
            dimensions {
              name  = "QueueName"
              value = "my-queue"
            }
          }
          stat = "Sum"
        }
        return_data = false
      }
      metrics {
        label = "Get the group size (the number of InService instances)"
        id    = "m2"
        metric_stat {
          metric {
            namespace   = "AWS/AutoScaling"
            metric_name = "GroupInServiceInstances"
            dimensions {
              name  = "AutoScalingGroupName"
              value = module.asg.autoscaling_group_name
            }
          }
          stat = "Average"
        }
        return_data = false
      }
      metrics {
        label       = "Calculate the backlog per instance"
        id          = "e1"
        expression  = "m1 / m2"
        return_data = true
      }
    }
  }
}



#ALB Security Group  
resource "aws_security_group" "alb-sg" {
  name        = format("%s-%s-alb-sg", var.Environment, var.app_name)
  description = "alb-sg"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ALL"
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
    Name        = "${var.app_name}-alb-sg"
    Environment = var.Environment
    Owner       = var.Owner
  }
}   
  
module "alb" {
  source             = "terraform-aws-modules/alb/aws"
  version            = "~> 6.0"
  name               = format("%s-%s-alb", var.Environment, var.app_name)
  load_balancer_type = var.load_balancer_type
  vpc_id             = var.vpc_id
  subnets            = var.public_subnets
  security_groups    = [aws_security_group.alb-sg.id]
  enable_http2       = true

  access_logs = {
    bucket = "${var.app_name}-access-logs"
  }

  target_groups = [
    {
      name                  = format("%s-%s-TG", var.Environment, var.app_name)
      backend_protocol      = var.backend_protocol
      backend_port          = var.backend_port
      target_type           = var.target_type
      health_check          = {
        enabled             = true
        interval            = var.interval
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 3
        timeout             = 4
        protocol            = var.protocol
        matcher             = var.matcher
      },
      stickiness = {
      enabled         = var.stickiness_enabled
      cookie_duration = var.cookie_duration
      type            = var.stickiness_type
      }
    }
  ]
  
  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = module.acm.acm_certificate_arn
      target_group_index = 0
    }
  ]


  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]
  tags = {
    Name        = "${var.app_name}-alb"
    Owner       = var.Owner
    Environment = var.Environment
    Terraform   = var.Terraform
  }
}

module "s3_bucket_alb_access_logs" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.7.0"

  bucket = "${var.app_name}-access-logs"
  lifecycle_rule = [
    {
      id      = "monthly_retention"
      prefix  = "/"
      enabled = true

      expiration = {
        days = 10
      }
    }
  ]
   versioning = {
    enabled = true
  }

  force_destroy = true

  attach_elb_log_delivery_policy = true
  attach_lb_log_delivery_policy  = true

  tags = {
    Name        = "${var.app_name}-access-logs"
    Environment = var.Environment
    Terraform   = true
    Owner       = var.Owner
  }
}

module "route53-record" {
  allow_overwrite = true
  source          = "clouddrove/route53-record/aws"
  version         = "1.0.1"
  zone_id         = var.zone_id
  name            = "${var.app_name}.${var.domain_name}"
  type            = "A"
  alias = {
    name                   = module.alb.lb_dns_name 
    zone_id                = module.alb.lb_zone_id 
    evaluate_target_health = true
  }
}


module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = "${var.app_name}.${var.domain_name}"
  zone_id     = var.zone_id
  wait_for_validation = true

  tags = {
    Environment = var.Environment
    Terraform   = true
    Owner       = var.Owner
    Name        = var.app_name
  }
}
