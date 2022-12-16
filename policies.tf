locals {
  additional_policies = length(var.additional_policies) > 0 ? flatten([
    for stack in var.stacks : [
      for policy in var.additional_policies : {
        stack_name  = stack.name
        policy_id = policy
      }
    ]
  ]) : [] 
  module_namespace = "alex067/terraform-spacelift-stacks"
}

data "local_file" "trigger_policy" {
  filename = "${path.module}/trigger.rego"
}

data "local_file" "git_push_policy" {
  filename = "${path.module}/git_push.rego"
}

resource "spacelift_policy" "push" {
  name = "${local.module_namespace} Git Push Policy"
  body = data.local_file.git_push_policy.content
  type = "GIT_PUSH"
}

resource "spacelift_policy" "trigger" {
  name = "${local.module_namespace} Trigger Policy"
  body = data.local_file.trigger_policy.content
  type = "TRIGGER"
}

resource "spacelift_policy_attachment" "git_push" {
  for_each = { for stack in spacelift_stack.main : stack.name => stack }

  policy_id = spacelift_policy.push.id
  stack_id  = each.value.id
}

resource "spacelift_policy_attachment" "trigger" {
  for_each = { for stack in spacelift_stack.main : stack.name => stack }

  policy_id = spacelift_policy.trigger.id
  stack_id  = each.value.id
}

resource "spacelift_policy_attachment" "additional" {
  for_each = {for policy in local.additional_policies : "${policy.stack_name} ${policy.policy_id}" => policy}

  policy_id = each.value.policy_id
  stack_id  = spacelift_stack.main[each.value.stack_name].id

  depends_on = [
    spacelift_stack.main
  ]
}

