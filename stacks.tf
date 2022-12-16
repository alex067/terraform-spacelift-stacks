locals {
  stack_dependencies = {
    for stack in var.stacks : stack.name => flatten([
      for dependency in stack.dependencies : [
        "dep:${var.global_project_root != "" ? "${var.global_project_root}/" : ""}${dependency}"
      ] 
    ]) if stack.dependencies != null
  }
}

resource "spacelift_stack" "main" {
  for_each = { for stack in var.stacks : stack.name => stack }

  administrative        = false
  autodeploy            = true
  branch                = var.trunk_branch
  description           = "${each.value.description != null && each.value.description != "" ? "${each.value.description} - " : ""}Managed by Terraform"
  enable_local_preview  = false
  labels                = flatten([lookup(local.stack_dependencies, each.value.name, []), each.value.additional_labels != null ? each.value.additional_labels : []])
  manage_state          = false
  name                  = each.value.name
  project_root          = "${var.global_project_root != null && var.global_project_root != "" ? "${var.global_project_root}/" : ""}${each.value.project_root}"
  protect_from_deletion = var.global_stack_delete_protection
  repository            = var.git_repository
  terraform_version     = var.terraform_version
}