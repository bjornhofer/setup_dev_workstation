// locals
locals {
  settings = yamldecode(file("settings.yaml"))
  default_suffix = local.settings.default_suffix
  customers = local.settings.customers
  default_vm_size = local.settings.vmsize
}