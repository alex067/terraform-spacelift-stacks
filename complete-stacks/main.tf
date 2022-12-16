module "stacks" {
  source = "../../"

  additional_policies            = ["all-of-sre-gets-read-access", "all-of-engineering-gets-read-access"]
  git_repository                 = "infrastructure"
  terraform_version              = "1.2.4"
  trunk_branch                   = "main"
  global_project_root            = "terraform"
  global_stack_delete_protection = false

  stacks = [{
    name         = "Test Stack A"
    description  = "Spacelift Stack Module Example"
    project_root = "dev/foo/bar"
    }, {
    name         = "Test Stack B"
    description  = "Spacelift Stack Module Example"
    project_root = "dev/foo/bar"
    dependencies = ["modules/network"]
    }, {
    name         = "Test Stack C"
    project_root = "dev/foo/bar"
    dependencies = ["modules/network", "modules/compute"]
  }]
}