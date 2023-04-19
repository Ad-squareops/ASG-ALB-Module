variable "region" {
  description = "Region where resources to be deployed"
  type        = string
  default     = ""
}

variable "app_name" {
  description = "Name of the Application"
  type        = string
  default     = ""
}

variable "asg_config" {
  description = ""
  type        = map (string)
}

variable "vpc_zone_identifier" {
  description = "A list of subnet IDs to launch resources in. Subnets automatically determine which availability zones the group will reside. Conflicts with `availability_zones`"
  type        = list(string)
  default     = []
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


variable "domain_name" {
  description = "Domain Name for the application"
  type        = string
  default     = ""
}

variable "host_headers" {
  description = ""
  type        = string
  default     = ""
}

variable "zone_id" {
  description = "ID of the Hosted Zone of Route53"
  type        = string
  default     = ""
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

variable "backend_protocol" {
  type    = string
  default = ""
}

variable "backend_port" {
  type    = number
  default = 0
}

variable "target_type" {
  type    = string
  default = ""
}

variable "alb_enable" {
  type    = bool
  default = true
}

variable "sg_enable" {
  type    = bool
  default = true
}

variable "route_enable" {
  type    = bool
  default = true
}

variable "cert_enable" {
  type    = bool
  default = true
}


variable "certificate_arn" {
  type    = string
  default = ""
}

variable "lb_dnsname" {
  type    = string
  default = ""
}

variable "hosted_zone_id" {
  type    = string
  default = "hosted_zone_id"
}


variable "vpn_security_group" {
  description = "Security group ID Of VPN"
  type        = string
  default     = ""
}

variable "alb_sg_id" {
  description = "Security group ID Of ALB"
  type        = string
  default     = ""
}
