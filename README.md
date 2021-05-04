# Terraform Lean Bootstrap
This repo contains modules for bootstrapping Terraform with remote state 
storage using pure Terraform.


## Objectives
* Bootstrapping Terraform from scratch with minimal boilerplate code
* All resources to be managed by Terraform including remote state storage
* Pure Terraform implementation - no scripts or cloud CLI commands


## Background
Bootstrapping Terraform to use remote state storage requires the remote storage
resources to be created before a Terraform remote backend can be configured to 
use these resources for storing Terraform state. This is sometimes referred to 
as the Terraform chicken & egg problem.

A common solution is to first create the required remote storage resources 
using Terraform with local state storage and then set up a remote backend 
configuration and reinitialize Terraform in order to migrate the local state
to remote storage.

Unfortunately, setting up a remote backend configuration normally involves 
manual work, which is error-prone, or some form of scripting solution, due to
the fact that backend configurations cannot be parametrized in Terraform.

The modules provided in this repo solve this complication by using a 
Terraform `local_file` resource to automatically create a `.tf` file with 
the correct backend configuration after the remote storage resources 
have been created.


## License

Please see [LICENSE.txt](https://github.com/mihai-gherman/terraform-lean-bootstrap/blob/main/LICENSE.txt) for details.
