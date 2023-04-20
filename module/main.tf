data "aws_availability_zones" "available" {}

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.7.0"
  name    = format("%s-%s-asg", var.Environment, var.name)

  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  vpc_zone_identifier       = var.vpc_zone_identifier
  wait_for_capacity_timeout = var.wait_for_capacity_timeout
  target_group_arns         = var.target_group_arns
  health_check_type         = var.health_check_type
  default_instance_warmup   = var.default_instance_warmup
  enabled_metrics           = var.enabled_metrics

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


  launch_template_name         = "final-${var.name}"
  launch_template_description  = "Launch template example"
  update_default_version       = var.update_default_version

  image_id                     = var.image_id
  instance_type                = var.instance_type
  key_name                     = module.key_pair.key_pair_name
  ebs_optimized                = var.ebs_optimized
  enable_monitoring            = var.enable_monitoring
  security_groups              = [aws_security_group.asg-sg.id]
  iam_instance_profile_name    = aws_iam_instance_profile.instance-profile.name

  tags = {
    Environment = var.Environment
    Owner       = var.Owner
  }
}

module "key_pair" {
  source      = "terraform-aws-modules/key-pair/aws"
  key_name    = format("%s-%s-key", var.Environment, var.name)
}

resource "aws_security_group" "asg-sg" {
  name        = format("%s_%s_app_asg_sg", var.Environment, var.name)
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
      from_port   = 3000
      to_port     = 3000
      protocol    = "TCP"
      cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = var.name
    Environment = var.Environment
    Owner       = var.Owner
  }
}


resource "aws_autoscaling_policy" "asg_cpu_policy" {
  count                     = var.asg_cpu_policy ? 1 : 0
  name                      = "${var.name}-cpu-policy"
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

resource "aws_autoscaling_policy" "asg_ALB_request_count_policy" {
  count                     = var.asg_ALB_request_count_policy ? 1 : 0
  name                      = "${var.name}-cpu-policy"
  autoscaling_group_name    = module.asg.autoscaling_group_name
  estimated_instance_warmup = 60
  policy_type               = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
    }
    target_value = var.request_count_value_threshold
  }
}


resource "aws_autoscaling_policy" "RAM_based_scale_up" {
  count                  = var.asg_RAM_based_scale_up_policy ? 1 : 0
  name                   = "${var.name}-asg-RAM-scale-up-policy"
  autoscaling_group_name = module.asg.autoscaling_group_name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1"
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "RAM_based_scale_down_alarm" {
  count               = var.asg_RAM_based_scale_up_policy ? 1 : 0
  alarm_name          = "${var.name}-asg-scale-up-alarm"
  alarm_description   = "asg-scale-up-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "mem_used_percent"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = var.threshold_to_scale_up
  dimensions = {
    "AutoScalingGroupName" = module.asg.autoscaling_group_name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.RAM_based_scale_up[0].arn]
  depends_on      = [aws_autoscaling_policy.RAM_based_scale_up]
}

resource "aws_autoscaling_policy" "RAM_based_scale_down" {
  count                  = var.asg_RAM_based_scale_down_policy ? 1 : 0
  name                   = "${var.name}-asg-RAM-scale-down-policy"
  autoscaling_group_name = module.asg.autoscaling_group_name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1"
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  count               = var.asg_RAM_based_scale_down_policy ? 1 : 0
  alarm_name          = "${var.name}-asg-scale-down-alarm"
  alarm_description   = "asg-scale-down-cpu-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "mem_used_percent"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = var.threshold_to_scale_down
  dimensions = {
    "AutoScalingGroupName" = module.asg.autoscaling_group_name
  }
  actions_enabled = true
  alarm_actions   = [resource.aws_autoscaling_policy.RAM_based_scale_down[0].arn]
  depends_on = [
    aws_autoscaling_policy.RAM_based_scale_down
  ]
}

resource "aws_iam_instance_profile" "instance-profile" {
  name = "${var.name}-instance-profile"
  role = aws_iam_role.instance-role.name
}

resource "aws_iam_role" "instance-role" {
  name = "${var.name}-instance-role"


  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ssm-policy" {
  role       = aws_iam_role.instance-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

resource "aws_iam_role_policy_attachment" "cloudwatch-asg" {
  role       = aws_iam_role.instance-role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy" "instance-profile" {
  name = "${var.name}-deploy-policy"
  role = aws_iam_role.instance-role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:CompleteLifecycleAction",
                "autoscaling:DeleteLifecycleHook",
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeLifecycleHooks",
                "autoscaling:PutLifecycleHook",
                "autoscaling:RecordLifecycleActionHeartbeat",
                "autoscaling:CreateAutoScalingGroup",
                "autoscaling:UpdateAutoScalingGroup",
                "autoscaling:EnableMetricsCollection",
                "autoscaling:DescribePolicies",
                "autoscaling:DescribeScheduledActions",
                "autoscaling:DescribeNotificationConfigurations",
                "autoscaling:SuspendProcesses",
                "autoscaling:ResumeProcesses",
                "autoscaling:AttachLoadBalancers",
                "autoscaling:AttachLoadBalancerTargetGroups",
                "autoscaling:PutScalingPolicy",
                "autoscaling:PutScheduledUpdateGroupAction",
                "autoscaling:PutNotificationConfiguration",
                "autoscaling:PutWarmPool",
                "autoscaling:DescribeScalingActivities",
                "autoscaling:DeleteAutoScalingGroup",
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceStatus",
                "ec2:TerminateInstances",
                "tag:GetResources",
                "sns:Publish",
                "cloudwatch:DescribeAlarms",
                "cloudwatch:PutMetricAlarm",
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:DescribeInstanceHealth",
                "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
                "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:DescribeTargetHealth",
                "elasticloadbalancing:RegisterTargets",
                "elasticloadbalancing:DeregisterTargets"
            ],
            "Resource": "*"
        },
       {
            "Effect": "Allow",
            "Action": [
                "s3:*",
                "s3-object-lambda:*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "iam:PassRole",
                "ec2:CreateTags",
                "ec2:RunInstances"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

  
  
module "alb" {
  source             = "terraform-aws-modules/alb/aws"
  version            = "~> 6.0"
  name               = format("%s-%s-alb", var.Environment, var.name)
  load_balancer_type = "application"
  vpc_id             = var.vpc_id
  subnets            = var.public_subnets
  security_groups    = [aws_security_group.alb-sg.id]

    access_logs = {
    bucket = "${var.name}-access-logs"
  }

  target_groups = [
    {
      name                  = format("%s-%s-TG", var.Environment, var.name)
      backend_protocol      = var.backend_protocol
      backend_port          = var.backend_port
      target_type           = var.target_type
      health_check          = {
        enabled             = true
        interval            = 6
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 3
        timeout             = 5
        protocol            = "HTTP"
        matcher             = "200"
      }
    }
  ]
  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = var.cert_enable ? module.acm[0].acm_certificate_arn: var.certificate_arn
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
    name        = "${var.name}-alb"
    Owner       = var.Owner
    Environment = var.Environment
    Terraform   = var.Terraform
  }
}

module "route53-record" {
  count           = var.route_enable ? 1 : 0
  allow_overwrite = true
  source          = "clouddrove/route53-record/aws"
  version         = "1.0.1"
  zone_id         = var.zone_id
  name       = "${var.name}.${var.domain_name}"
  type            = "A"
  alias = {
    name              = var.alb_enable ? module.alb[0].lb_dns_name : var.lb_dnsname
    zone_id                = var.alb_enable ? module.alb[0].lb_zone_id  : var.hosted_zone_id
    evaluate_target_health = true
  }
}


module "acm" {
  count   = var.cert_enable ? 1 : 0
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = "*.${var.domain_name}"
  zone_id     = var.zone_id

  subject_alternative_names = [
    "*.${var.domain_name}",
    "${var.name}.${var.domain_name}",
    "${var.host_headers}",
  ]

  wait_for_validation = true

  tags = {
    Environment = var.Environment
    Terraform   = true
    Owner       = var.Owner
    name        = var.name
  }
}

module "s3_bucket_alb_access_logs" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.7.0"

  bucket = "${var.name}-access-logs"
  acl    = "log-delivery-write"
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
  tags = {
    
    name        = "${var.name}-access-logs"
    Environment = var.Environment
    Terraform   = true
    Owner       = var.Owner
    
  }
}
  
#ALB Security Group  
resource "aws_security_group" "alb-sg" {
  name        = format("%s_%s_alb_sg", var.Environment, var.name)
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
    Name        = var.name
    Environment = var.Environment
    Owner       = var.Owner
  }
}
