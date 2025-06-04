##################################################
# Service Bus Namespace + FIFO-enabled Queue
##################################################

# ----------------------------------------------------------------------------
# 1. Create Service Bus Namespace
#
# Cost considerations:
#   • Use “Basic” if you don’t need features like message sessions; otherwise “Standard”.
# ----------------------------------------------------------------------------
resource "azurerm_servicebus_namespace" "sb" {
  name                = "${var.name_prefix}${var.environment}sbns"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku

  tags = {
    Environment = var.environment
    Role        = "ServiceBus"
    CreatedBy   = "terraform"
  }
}

# ----------------------------------------------------------------------------
# 2. Create a FIFO-enabled queue requiring sessions
#
# Sessions allow strict message ordering; keep other settings moderate.
# ----------------------------------------------------------------------------
resource "azurerm_servicebus_queue" "employee_commands" {
  name                             = "EmployeeCommandQueue"
  namespace_id                     = azurerm_servicebus_namespace.sb.id
  requires_session                 = true
  max_size_in_megabytes            = 1024       # 1 GB capacity
  default_message_ttl              = "P14D"     # Messages expire after 14 days
  lock_duration                    = "PT5M"     # 5-minute lock per receiver
  dead_lettering_on_message_expiration = true
}
