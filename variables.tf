variable "additional_policies" {
  type        = list(string)
  description = "A list of additional policy-ids to attach to every Stack"
  default     = []
}

variable "git_repository" {
  type        = string
  description = "The Github Repository name containing Terraform infrastructure code"
}

variable "global_project_root" {
  type        = string
  default     = ""
  description = <<EOH
  The top level directory containing Terraform infrastructure code. Defaults to root level directory of the repository. 
  If set, all Stack dependencices and the Stack project root directory are prepended with the global_project_root value.
EOH
}

variable "global_stack_delete_protection" {
  type  = bool 
  description = "Whether to toggle on deletion prevention for all Spacelift Stacks"
  default = true 
}

variable "stacks" {
  type = list(object({
    additional_labels = optional(list(string))
    name              = string
    description       = optional(string)
    dependencies      = optional(list(string))
    project_root      = string
  }))
  description = "List of Spacelift Stacks to generate"

  validation {
    condition     = length(var.stacks) > 0
    error_message = "Must supply a list of stacks with a length of greater than 0"
  }
}

variable "terraform_version" {
  type        = string
  description = "The Terraform version used for every Stack"
}

variable "trunk_branch" {
  type        = string
  default     = "main"
  description = "The Github repository trunk branch to detect for any changes"
}