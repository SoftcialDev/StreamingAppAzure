variable "name_prefix" {
  description = "Lowercase prefix used in naming AAD resources (e.g., 'collettehealthprod')"
  type        = string
}

variable "environment" {
  description = "Deployment environment identifier (e.g., 'prod')"
  type        = string
}

variable "create_redirect_uri" {
  type        = bool
  description = "Whether to create a redirect URI for the AAD application"
  default     = true
}
