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

variable "resource_names_map" {
  description = "A map of key to resource_name that will be used by tf-launch-module_library-resource_name to generate resource names"
  type = map(object({
    name       = string
    max_length = optional(number, 60)
  }))

  default = {
    mysql_server = {
      name       = "psql"
      max_length = 60
    }
    resource_group = {
      name       = "rg"
      max_length = 60
    }
  }
}

variable "instance_env" {
  type        = number
  description = "Number that represents the instance of the environment."
  default     = 0

  validation {
    condition     = var.instance_env >= 0 && var.instance_env <= 999
    error_message = "Instance number should be between 0 to 999."
  }
}

variable "instance_resource" {
  type        = number
  description = "Number that represents the instance of the resource."
  default     = 0

  validation {
    condition     = var.instance_resource >= 0 && var.instance_resource <= 100
    error_message = "Instance number should be between 0 to 100."
  }
}

variable "logical_product_family" {
  type        = string
  description = <<EOF
    (Required) Name of the product family for which the resource is created.
    Example: org_name, department_name.
  EOF
  nullable    = false

  validation {
    condition     = can(regex("^[_\\-A-Za-z0-9]+$", var.logical_product_family))
    error_message = "The variable must contain letters, numbers, -, _, and .."
  }

  default = "launch"
}

variable "logical_product_service" {
  type        = string
  description = <<EOF
    (Required) Name of the product service for which the resource is created.
    For example, backend, frontend, middleware etc.
  EOF
  nullable    = false

  validation {
    condition     = can(regex("^[_\\-A-Za-z0-9]+$", var.logical_product_service))
    error_message = "The variable must contain letters, numbers, -, _, and .."
  }

  default = "database"
}

variable "class_env" {
  type        = string
  description = "(Required) Environment where resource is going to be deployed. For example. dev, qa, uat"
  nullable    = false
  default     = "dev"

  validation {
    condition     = length(regexall("\\b \\b", var.class_env)) == 0
    error_message = "Spaces between the words are not allowed."
  }
}

variable "location" {
  description = "Location of the Postgres Flexible Server"
  type        = string
  default     = "eastus"
}

variable "public_network_access_enabled" {
  description = "Whether or not public network access is allowed for this server"
  type        = bool
  default     = false
}

variable "authentication" {
  description = <<-EOT
    active_directory_auth_enabled = Whether or not Active Directory authentication is enabled for this server
    password_auth_enabled         = Whether or not password authentication is enabled for this server
    tenant_id                     = The tenant ID of the Active Directory to use for authentication
  EOT
  type = object({
    active_directory_auth_enabled = optional(bool)
    password_auth_enabled         = optional(bool)
    tenant_id                     = optional(string)
  })
  default = null
}

variable "administrator_login" {
  description = <<-EOT
    The administrator login for the Postgres Flexible Server.
    Required when `create_mode` is Default and `authentication.password_auth_enabled` is true
  EOT
  type        = string
  default     = null
}

variable "administrator_password" {
  description = <<-EOT
    The administrator password for the Postgres Flexible Server.
    Required when `create_mode` is Default and `authentication.password_auth_enabled` is true
  EOT
  type        = string
  default     = null
}

variable "storage_mb" {
  description = "The storage capacity of the Postgres Flexible Server in megabytes"
  type        = number
  default     = 32768

  validation {
    condition = contains([
      32768,
      65536,
      131072,
      262144,
      524288,
      1048576,
      2097152,
      4193280,
      4194304,
      8388608,
      16777216,
      33553408
    ], var.storage_mb)
    error_message = "Invalid storage_mb value"
  }
}

variable "zone" {
  description = "The zone of the Postgres Flexible Server"
  type        = string
  default     = null

  validation {
    condition     = var.zone == null || can(regex("^[0-9]$", var.zone))
    error_message = "Invalid value for `zone`"
  }
}

variable "server_configuration" {
  description = "Map of configurations to apply to the postgres flexible server"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
