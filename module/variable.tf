#General
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

variable "app_name" {
  description = "Name of the Application"
  type        = string
  default     = ""
}


#Launch Template 
variable "image_id" {
  description = "The AMI from which to launch the instance"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "The type of the instance. If present then `instance_requirements` cannot be present"
  type        = string
  default     = "t3a.small"
}

variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
  default     = ""
}

#ASG
variable "private_subnets" {
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

variable "health_check_type" {
  description = ""
  type        = string
  default     = "EC2"
}

variable "asg_cpu_policy" {
  description = "Enable or Disable CPU based utilization policy"
  type        = bool
  default     = true
}

variable "cpu_value_threshold" {
  description = "Target value of CPU based utlization Policy"
  type        = number
  default     = 50
}

variable "asg_ALB_request_count_policy" {
  description = ""
  type        = bool
  default     = true
}

variable "target_value" {
  description = "alb request count target value"
  type        = number
  default     = 200
}

variable "asg_RAM_based_scale_updown_policy" {
  description = "Enable or Disable RAM based utilization Policy"
  type        = bool
  default     = false
}

variable "RAM_threshold_to_scale_up" {
  description = "Target value for RAM based utilization Policy"
  type        = number
  default     = 70
}

variable "RAM_threshold_to_scale_down" {
  description = "Target value for RAM based utilization Policy"
  type        = number
  default     = 50
}

variable "asg_scale_updown_disk_usage_policy" {
  description = "enable or disable disk based utilization Policy"
  type        = bool
  default     = false
}

variable "disk_threshold_to_scale_up" {
  description = "Target value for disk based utilization Policy"
  type        = number
  default     = 70
}

variable "disk_threshold_to_scale_down" {
  description = "Target value for disk based utilization Policy"
  type        = number
  default     = 50
}

variable "asg_SQS_based_policy" {
  description = "enable or disable SQS based utilization Policy"
  type        = bool
  default     = false
}

variable "target_value_SQS" {
  description = "target value SQS based utilization Policy"
  type        = number
  default     = 200
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

variable "interval" {
  description = "health check interval"
  type        = number
  default     = 5
}

variable "path" {
  description = "health check path"
  type        = string
  default     = "/"
}

variable "protocol" {
  description = "health check protocol"
  type        = string
  default     = "HTTP"
}

variable "matcher" {
  description = "health check matcher"
  type        = number
  default     = 200
}

variable "stickiness_enabled" {
  description = "stickiness enabled or disable"
  type        = bool
  default     = false
}

variable "cookie_duration" {
  description = "stickiness cookie duration"
  type        = number
  default     = 500
}

variable "stickiness_type" {
  description = "stickiness stickiness type - lb_cookie or app_cookie"
  type        = string
  default     = "lb_cookie"
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
