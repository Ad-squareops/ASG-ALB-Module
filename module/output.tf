output "name_of_application" {
   description = "The name of Application"
   value       = var.name
 }


output "autoscaling_group_id" {
   description = "The autoscaling group ID"
   value       = module.asg.autoscaling_group_id
 }

 output "autoscaling_group_name" {
   description = "The autoscaling group name"
   value       = module.asg.autoscaling_group_name
 }

 output "autoscaling_group_min_size" {
   description = "The minimum size of the autoscale group"
   value       = module.asg.autoscaling_group_min_size
 }

 output "autoscaling_group_max_size" {
   description = "The maximum size of the autoscale group"
   value       = module.asg.autoscaling_group_max_size
 }

 output "autoscaling_group_desired_capacity" {
   description = "The desired capacity of the autoscale group"
   value       = module.asg.autoscaling_group_desired_capacity
 }

 output "autoscaling_group_health_check_type" {
   description = "EC2 or ELB. Controls how health checking is done"
   value       = module.asg.autoscaling_group_health_check_type
 }

 output "autoscaling_group_load_balancers" {
   description = "The load balancer names associated with the autoscaling group"
   value       = module.asg.autoscaling_group_load_balancers
 }

output "lb_id" {
  description = "The ID and ARN of the load balancer we created."
  value       = var.alb_enable ? module.alb[0].lb_id : null
}

output "lb_arn" {
  description = "The ID and ARN of the load balancer we created."
  value       = var.alb_enable ? module.alb[0].lb_arn : null
}

output "lb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = var.alb_enable ? module.alb[0].lb_dns_name : null
}

output "lb_arn_suffix" {
  description = "ARN suffix of our load balancer - can be used with CloudWatch."
  value       = var.alb_enable ? module.alb[0].lb_arn_suffix : null
}

output "lb_zone_id" {
  description = "The zone_id of the load balancer to assist with creating DNS records."
  value       = var.alb_enable ? module.alb[0].lb_zone_id : null
}

output "http_tcp_listener_arns" {
  description = "The ARN of the TCP and HTTP load balancer listeners created."
  value       = var.alb_enable ? module.alb[0].http_tcp_listener_arns : null
}

output "http_tcp_listener_ids" {
  description = "The IDs of the TCP and HTTP load balancer listeners created."
  value       = var.alb_enable ? module.alb[0].http_tcp_listener_ids : null
}

output "https_listener_arns" {
  description = "The ARNs of the HTTPS load balancer listeners created."
  value       = var.alb_enable ? module.alb[0].https_listener_arns : null
}

output "https_listener_ids" {
  description = "The IDs of the load balancer listeners created."
  value       = var.alb_enable ? module.alb[0].https_listener_ids : null
}

output "target_group_arns" {
  description = "ARNs of the target groups. Useful for passing to your Auto Scaling group."
  value       = var.alb_enable ? module.alb[0].target_group_arns : null
}

output "target_group_arn_suffixes" {
  description = "ARN suffixes of our target groups - can be used with CloudWatch."
  value       = var.alb_enable ? module.alb[0].target_group_arn_suffixes : null
}

output "target_group_names" {
  description = "Name of the target group. Useful for passing to your CodeDeploy Deployment Group."
  value       = var.alb_enable ? module.alb[0].target_group_names : null
}

output "target_group_attachments" {
  description = "ARNs of the target group attachment IDs."
  value       = var.alb_enable ? module.alb[0].target_group_attachments : null
}


output "key_pair_name" {
  description = "The key pair name."
  value       = module.key_pair.key_pair_name
}

output "iam_instance_profile_arn" {
  description = "The ARN of the instance Profile"
  value       = aws_iam_instance_profile.instance-profile.arn
}

output "iam_instance_profile_name" {
  description = "The name of the instance Profile"
  value       = aws_iam_instance_profile.instance-profile.name
}
