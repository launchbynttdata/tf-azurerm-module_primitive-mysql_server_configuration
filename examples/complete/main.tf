// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

module "resource_names" {
  source  = "terraform.registry.launch.nttdata.com/module_library/resource_name/launch"
  version = "~> 2.0"

  for_each = var.resource_names_map

  logical_product_family  = var.logical_product_family
  logical_product_service = var.logical_product_service
  region                  = var.location
  class_env               = var.class_env
  cloud_resource_type     = each.value.name
  instance_env            = var.instance_env
  maximum_length          = each.value.max_length
  instance_resource       = var.instance_resource
}

module "resource_group" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/resource_group/azurerm"
  version = "~> 1.0"

  name     = module.resource_names["resource_group"].minimal_random_suffix
  location = var.location

  tags = merge(var.tags, { resource_name = module.resource_names["resource_group"].standard })
}

module "managed_identity" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/user_managed_identity/azurerm"
  version = "~> 1.2"

  user_assigned_identity_name = module.resource_names["managed_identity"].minimal_random_suffix
  resource_group_name         = module.resource_group.name
  location                    = var.location

  depends_on = [module.resource_group]
}

# create a random password for the admin user
resource "random_password" "admin_password" {
  length           = 16
  special          = true
  min_lower        = 1
  min_upper        = 1
  min_special      = 1
  override_special = "_%@"
}

module "mysql_server" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/mysql_server/azurerm"
  version = "~> 1.1"

  name                   = module.resource_names["mysql_server"].minimal_random_suffix
  resource_group_name    = module.resource_group.name
  location               = var.location
  administrator_login    = var.administrator_login
  administrator_password = random_password.admin_password.result
  identity_ids           = [module.managed_identity.id]
  zone                   = var.zone

  tags       = merge(var.tags, { resource_name = module.resource_names["mysql_server"].standard })
  depends_on = [module.resource_group]
}

module "mysql_server_configuration" {
  source = "../.."

  for_each = var.server_configuration

  mysql_server_name   = module.mysql_server.name
  resource_group_name = module.resource_group.name

  configuration_key   = each.key
  configuration_value = each.value
}
