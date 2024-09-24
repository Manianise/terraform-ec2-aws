# Output the public IPs for the instances that need internet access
output "node_api_instance_public_ip" {
  value = aws_instance.node_api_instance.public_ip
}

output "monitoring_instance_public_ip" {
  value = aws_instance.monitoring_instance.public_ip
}

output "delivery_instance_public_ip" {
  value = aws_instance.delivery_instance.public_ip
}

# Output the private IP for the database instance (no public IP)
output "database_instance_private_ip" {
  value = aws_instance.database_instance.private_ip
}