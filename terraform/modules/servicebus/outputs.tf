# File: terraform/modules/servicebus/outputs.tf

output "namespace_id" {
  description = "Resource ID of the Service Bus Namespace"
  value       = azurerm_servicebus_namespace.sb.id
}

output "namespace_name" {
  description = "Name of the Service Bus Namespace"
  value       = azurerm_servicebus_namespace.sb.name
}

output "queue_name" {
  description = "Name of the Service Bus queue"
  value       = azurerm_servicebus_queue.employee_commands.name
}

output "queue_id" {
  description = "Resource ID of the Service Bus queue"
  value       = azurerm_servicebus_queue.employee_commands.id
}
