

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
