module "stacks" {
  source = "../../"

  aws_integration_id             = "123456"
  additional_policies            = ["all-of-sre-gets-read-access", "all-of-engineering-gets-read-access"]
  git_repository                 = "infrastructure"
  terraform_version              = "1.2.4"
  trunk_branch                   = "spaceliftmodule"
  global_project_root            = "terraform"
  global_stack_delete_protection = false

  stacks = [{
    name         = "Test Stack Oracle Service"
    description  = "Spacelift Stack Module Example"
    project_root = "dev/applications/oracle"
    dependencies = ["modules/oracle"]
  }]
}