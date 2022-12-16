# Spacelift Stacks Teraform Module

Terraform module which helps streamline and manage the creation of Spacelift Stacks.  
** This module currently supports AWS Integrations with Spacelift **

![](assets/banner.png)

## Usage

```hcl
module "stacks" {
  source  = "alex067/stacks/spacelift"
  
  aws_integration_id             = "12345"
  additional_policies            = ["all-of-engineering-gets-read-access"]
  git_repository                 = "infrastructure"
  terraform_version              = "1.2.4"
  trunk_branch                   = "main"

  stacks = [{
    name         = "Test Stack A"
    description  = "Spacelift Stack Module Example"
    project_root = "dev/foo/bar"
    }, {
    name         = "Test Stack B"
    description  = "Spacelift Stack Module Example"
    project_root = "dev/fizz/buzz"
    dependencies = ["modules/network"]
  }]

}
```

## Description

> Visit Spacelift: https://spacelift.io/ 

Spacelift is an amazing platform, allowing your Terraform code to endlessly scale and easily manage your environments. However, the initial setup process can be a bit confusing.

This module aims to streamline the core process of creating and managing your Spacelift stacks. 

The design of the module revolves around the following workflow process and assumptions:
* Your Stacks are managed by a top level Administrative Stack
* You are following a trunk based model
* Your Stack will execute ```terraform plan``` when a Pull Request is created
* Your Stack will execute ```terraform apply --auto-approve``` when a Pull Request is approved and merged to the trunk branch

The logic to enable this workflow is found in the ```git_push.rego``` policy.

## Stack Settings

```hcl
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
```

* ```additional_labels``` extra metadata attached to the Stack
* ```dependencies``` local modules called by the root module managed by the Stack. 
  - This is used in the ```git_push.rego``` policy to accurately trigger a ```terraform plan``` or ```terraform apply --auto-approve``` if changes to a local module were detected
  - For example, if your root module called a local module ```modules/network``` then this is considered a dependency

```hcl
variable "additional_policies" {
  type        = list(string)
  description = "A list of additional policy-ids to attach to every Stack"
  default     = []
}
```

A list of policy ids which will be assumed by all Stacks. Common to provide global read permissions to all Stacks within your org.

```hcl
variable "aws_integration_id" {
  type = string 
  description = "The Spacelift AWS Integration Id attached to all Stacks"
}
```

The AWS Integration Id created in Spacelift, assumed by all Stacks.

```hcl
variable "global_project_root" {
  type        = string
  default     = ""
  description = <<EOH
  The top level directory containing Terraform infrastructure code. Defaults to root level directory of the repository. 
  If set, all Stack dependencices and the Stack project root directory are prepended with the global_project_root value.
EOH
}
```

A common organizational pattern, is to group resources by an environment such as Development, Staging, Production, and so on. In this case, infrastructure paths are prefixed by the environment folder, such as ```dev/*```

The ```global_project_root``` provides a standard prefix to be added to the project path, for all all Spacelift Stacks.
