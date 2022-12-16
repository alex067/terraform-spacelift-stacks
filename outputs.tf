output "stack_ids" {
  value = [for stack in spacelift_stack.main : stack.id]
}