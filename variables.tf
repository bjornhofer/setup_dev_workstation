// locals
locals {
  settings = jsondecode(file("settings.json"))
  default_suffix = local.settings.default_suffix
  customers = local.settings.customers
  default_vm_size = local.settings.vmsize
}

variable "management" {
  type = string
  default = "management"
}