variable "azure_directory" {
  description = "Your Azure directory."
}

variable "azure_subscription" {
  description = "Your Azure subscription."
}

variable "resource_group" {
  description = "Resource group name to deploy."
}

variable "site_location" {
  description = "The location for the site deployment."
}

variable "site_name" {
  description = "The name of the site to deploy."
}

variable "sku" {
  description = "The sku of the site."
}

variable "dnsimple_domain" {
  description = "The domain we are creating a record for."
}
