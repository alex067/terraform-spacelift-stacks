# Spacelift Stacks Teraform Module

Terraform module which helps streamline and manage the creation of Spacelift Stacks. 

![](assets/banner.png)

## Usage

```hcl
module "stacks" {
  source  = "alex067/stacks/spacelift"

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
    }, {
    name         = "Test Stack C"
    project_root = "dev/hello/world"
    dependencies = ["modules/network", "modules/compute"]
  }]

}
```

## Description

> Visit Spacelift: https://spacelift.io/ 

Spacelift is an amazing platform, allowing your Terraform code to endlessly scale and easily manage your environments. However, the initial setup process can be a bit confusing.

This module aims to streamline the core process of creating and managing your Spacelift stacks. 

The design of the module revolves around the following workflow process and assumptions:
* Your Stacks are managed by a top level Administrative Stack.
* You are following a trunk based model.
* Your Stack will execute ```terraform plan``` when a Pull Request is created.
* Your Stack will execute ```terraform apply --auto-approve``` when a Pull Request is approved and merged to the trunk branch.

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
