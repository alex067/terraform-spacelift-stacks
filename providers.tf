terraform {
  experiments = [ module_variable_optional_attrs ]
  required_providers {
    spacelift = {
      source = "spacelift-io/spacelift"
      version = ">= 0.1.35"
    }
  }
}