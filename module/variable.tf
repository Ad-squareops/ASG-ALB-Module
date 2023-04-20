variable "region" {
  description = "Region where resources to be deployed"
  type        = string
  default     = ""
}

variable "launch_template_name" {
  description = "Name of launch template to be created"
  type        = string
  default     = ""
}

variable "create_iam_instance_profile" {
  description = "Determines whether an IAM instance profile is created or to use an existing IAM instance profile"
  type        = bool
  default     = false
}

variable "launch_template_description" {
  description = "Description of the launch template"
  type        = string
  default     = null
}

variable "iam_role_name" {
  description = "Name to use on IAM role created"
  type        = string
  default     = null
}

variable "iam_role_path" {
  description = "IAM role path"
  type        = string
  default     = null
}

variable "iam_role_description" {
  description = "Description of the role"
  type        = string
  default     = null
}

variable "iam_role_policies" {
  description = "IAM policies to attach to the IAM role"
  type        = map(string)
  default     = {}
}


variable "iam_role_tags" {
  description = "A map of additional tags to add to the IAM role created"
  type        = map(string)
  default     = {}
}


variable "name" {
  description = "Name of the Application"
  type        = string
  default     = ""
}

variable "update_default_version" {
  description = "Whether to update Default Version each update. Conflicts with `default_version`"
  type        = string
  default     = null
}

variable "instance_name" {
  description = "Name that is propogated to launched EC2 instances via a tag - if not provided, defaults to `var.name`"
  type        = string
  default     = ""
}

variable "default_instance_warmup" {
  description = "Amount of time, in seconds, until a newly launched instance can contribute to the Amazon CloudWatch metrics. This delay lets an instance finish initializing before Amazon EC2 Auto Scaling aggregates instance metrics, resulting in more reliable usage data. Set this value equal to the amount of time that it takes for resource consumption to become stable after an instance reaches the InService state."
  type        = number
  default     = null
}

variable "vpc_zone_identifier" {
  description = "A list of subnet IDs to launch resources in. Subnets automatically determine which availability zones the group will reside. Conflicts with `availability_zones`"
  type        = list(string)
  default     = null
}


variable "min_size" {
  description = "The minimum size of the autoscaling group"
  type        = number
  default     = null
}

variable "max_size" {
  description = "The maximum size of the autoscaling group"
  type        = number
  default     = null
}

variable "desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the autoscaling group"
  type        = number
  default     = null
}

variable "wait_for_capacity_timeout" {
  description = ""
  type        = number
  default     = 0
}

variable "health_check_type" {
  description = ""
  type        = string
  default     = "ELB"
}


variable "enabled_metrics" {
  description = "A list of metrics to collect. The allowed values are `GroupDesiredCapacity`, `GroupInServiceCapacity`, `GroupPendingCapacity`, `GroupMinSize`, `GroupMaxSize`, `GroupInServiceInstances`, `GroupPendingInstances`, `GroupStandbyInstances`, `GroupStandbyCapacity`, `GroupTerminatingCapacity`, `GroupTerminatingInstances`, `GroupTotalCapacity`, `GroupTotalInstances`"
  type        = list(string)
  default     = []
}

variable "instance_refresh" {
  description = "If this block is configured, start an Instance Refresh when this Auto Scaling Group is updated"
  type        = any
  default     = {}
}

variable "image_id" {
  description = "The AMI from which to launch the instance"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "The type of the instance. If present then `instance_requirements` cannot be present"
  type        = string
  default     = ""
}

variable "key_name" {
  description = "The key name that should be used for the instance"
  type        = string
  default     = ""
}


variable "security_groups" {
  description = "A list of security group IDs to associate"
  type        = list(string)
  default     = []
}

variable "public_subnets" {
  description = "A list of Public Subnets to associate"
  type        = list(string)
  default     = []
}

variable "enable_monitoring" {
  description = "Enables/disables detailed monitoring"
  type        = bool
  default     = false
}

variable "ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized"
  type        = bool
  default     = false
}

variable "target_group_arns" {
  description = "A set of `aws_alb_target_group` ARNs, for use with Application or Network Load Balancing"
  type        = list(string)
  default     = [] 
}


variable "target_group_arn" {
  description = "Value of `aws_alb_target_group` ARNs, for use with Application or Network Load Balancer"
  type        = list(string)
  default     = []
}


variable "iam_instance_profile_arn" {
  description = "Amazon Resource Name (ARN) of an existing IAM instance profile. Used when `create_iam_instance_profile` = `false`"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
  default     = {}
}

variable "asg_cpu_policy" {
  description = "Enable or Disable CPU based utilization policy"
  type        = bool
  default     = false
}



variable "cpu_value_threshold" {
  description = "Target value of CPU based utlization Policy"
  type        = number
  default     = 70
}

variable "asg_ALB_request_count_policy" {
  description = ""
  type        = bool
  default     = false
}

variable "request_count_value_threshold" {
  description = ""
  type        = number
  default     = 20
}

variable "asg_RAM_based_scale_up_policy" {
  description = "Enable or Disable RAM based utilization Policy"
  type        = bool
  default     = false
}

variable "threshold_to_scale_up" {
  description = "Target value for RAM based utilization Policy"
  type        = number
  default     = 20
}

variable "asg_RAM_based_scale_down_policy" {
  description = "Enable or Disable RAM based utilization Policy"
  type        = bool
  default     = false
}

variable "threshold_to_scale_down" {
  description = "Target value for RAM based utilization Policy"
  type        = number
  default     = 50
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
  default     = ""
}

variable "Environment" {
  description = "Environment name of the project"
  type        = string
  default     = ""
}

variable "Owner" {
  description = "Name of the Owner"
  type        = string
  default     = ""
}

variable "Terraform" {
  description = "Created by terraform"
  type        = bool
  default     = true
}

variable "sg_enable" {
  type    = bool
  default = true
}


variable "certificate_arn" {
  type    = string
  default = ""
}

variable "alb_sg_id" {
  description = "Security group ID Of ALB"
  type        = string
  default     = ""
}

#ALB
variable "load_balancer_type" {
  description = "The type of load balancer to create. Possible values are application or network."
  type        = string
  default     = "application"
}

variable "public_subnets" {
  description = "A list of subnets to associate with the load balancer. e.g. ['subnet-1a2b3c4d','subnet-1a2b3c4e','subnet-1a2b3c4f']"
  type        = list(string)
  default     = null
}

variable "backend_protocol" {
  description = "backend protocol Of ALB"
  type        = string
  default     = "HTTP"
}

variable "backend_port" {
  description = "backend port Of ALB"
  type        = number
  default     = "80"
}

variable "target_type" {
  description = ""
  type        = string
  default     = "instance"
}

variable "target_groups" {
  description = "A list of maps containing key/value pairs that define the target groups to be created. Order of these maps is important and the index of these are to be referenced in listener definitions. Required key/values: name, backend_protocol, backend_port"
  type        = any
  default     = []
}

variable "https_listeners" {
  description = "A list of maps describing the HTTPS listeners for this ALB. Required key/values: port, certificate_arn. Optional key/values: ssl_policy (defaults to ELBSecurityPolicy-2016-08), target_group_index (defaults to https_listeners[count.index])"
  type        = any
  default     = []
}

variable "http_tcp_listeners" {
  description = "A list of maps describing the HTTP listeners or TCP ports for this ALB. Required key/values: port, protocol. Optional key/values: target_group_index (defaults to http_tcp_listeners[count.index])"
  type        = any
  default     = []
}

variable "https_listener_rules" {
  description = "A list of maps describing the Listener Rules for this ALB. Required key/values: actions, conditions. Optional key/values: priority, https_listener_index (default to https_listeners[count.index])"
  type        = any
  default     = []
}

variable "http_tcp_listener_rules" {
  description = "A list of maps describing the Listener Rules for this ALB. Required key/values: actions, conditions. Optional key/values: priority, http_tcp_listener_index (default to http_tcp_listeners[count.index])"
  type        = any
  default     = []
}

#route53
variable "route_enable" {
  type    = bool
  default = true
}

variable "hosted_zone_id" {
  type    = string
  default = "hosted_zone_id"
}

variable "lb_dnsname" {
  type    = string
  default = ""
}

variable "alb_enable" {
  type    = bool
  default = true
}

#acm
variable "domain_name" {
  description = "A domain name for which the certificate should be issued"
  type        = string
  default     = ""
}

variable "zone_id" {
  description = "ID of DNS zone"
  type        = string
  default     = null
}

variable "subject_alternative_names" {
  description = "A list of domains that should be SANs in the issued certificate"
  type        = list(string)
  default     = []
}

variable "host_headers" {
  description = "A domain name for which the certificate should be issued"
  type        = string
  default     = ""
}

variable "cert_enable" {
  type    = bool
  default = true
}
