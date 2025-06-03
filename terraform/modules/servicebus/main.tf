# ----------------------------------------------------------------------------
# 1. Create Service Bus Namespace
# ----------------------------------------------------------------------------
resource "azurerm_servicebus_namespace" "sb" {
  name                = "${var.name_prefix}-${var.environment}-sb"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  capacity            = 1      # Standard or Basic – 1 unit

  tags = {
    Environment = var.environment
    Role        = "ServiceBus"
    CreatedBy   = "terraform"
  }
}

# ----------------------------------------------------------------------------
# 2. Create a FIFO-enabled queue requiring sessions
# ----------------------------------------------------------------------------
resource "azurerm_servicebus_queue" "employee_commands" {
  name                = "EmployeeCommandQueue"
  namespace_id      = azurerm_servicebus_namespace.sb.name
  requires_session        = true
  max_size_in_megabytes   = 1024      # 1 GB capacity
  default_message_ttl     = "P14D"   # Messages expire after 14 days
  lock_duration           = "PT5M"   # 5 minutes lock for each receiver
  dead_lettering_on_message_expiration = true

}
