# GCP Virtual Machine (VM) terraform code with optional Rasa Ephemeral Installer (REI) installation

This code uses the Google Terraform provider (no version enforcement) to provision a GCP virtual machine, performs an apt update, apt upgrade, and installs some packages (pkg-config, jq, net-tools, docker.io, python3.8-venv, ngrok) to have the VM mostly prepared for a REI installation. The full details performed can be seen in the [startup.sh](scripts/startup.sh) script.

Once the GCP VM has been provisioned, you can, optionally, use the provided script to download and execute the REI installation script.
Running the REI installation script will install a [KIND](https://kind.sigs.k8s.io/) Kubernetes cluster and install the [rasactl](https://github.com/RasaHQ/rasactl) binary.

---
### Pre-requisites
- Terraform is installed (see: https://www.terraform.io/downloads)
- You have access to a GCP project with compute APIs enabled and compute roles assigned to your GCP account. 
- You are authenticated with gcloud to an account that has compute privileges in the targeted GCP project. **Note**: If you receive a 400 error this may be because your need to authenticate with the application-default flow: `gcloud auth application-default login`. (There are other methods for authenticating Terraform but those are beyond the scope of this example.)
- Copy the file `terraform.tfvars.skel` to `terraform.tfvars` and update the `REPLACE_ME` entries. It is **required** to update the REPLACE_ME entries with valid values! Use `gcloud config list` to see your current project, zone, and region.

---
### Usage
- `terraform init` # This downloads the provider plugins
- `terraform plan` # This shows what actions terraform will perform on the targeted infrastructure; creating a VM in this case
- `terraform apply` # This will execute the plan as seen in the previous step

The terraform output will provide you with the gcloud command to ssh into the new VM instance.

---
### Next steps
The MOTD (message of the day) after SSH'ing into the new VM instance will inform you of the next steps to run. They are here for reference as well:
- Download the helper script: `curl -so k8s-helper.sh -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/attributes/k8s-helper`
- Make it executable then run it:
    - Without installing REI: `chmod +x k8s-helper.sh && ./k8s-helper.sh`
    - With installing with REI: `chmod +x k8s-helper.sh && ./k8s-helper.sh rei`

### What does this helper script do?
- Ensures the user is a member of the *docker* group and provides instructions to follow if they are not
- (if REI option is given) Downloads and runs the REI script
- Sets up the user's environment to be able to use krew (https://krew.sigs.k8s.io/)
- Installs kubectx and kubens (https://github.com/ahmetb/kubectx)
- Sets up completion for kubectl/helm/kubectx/kubens (https://github.com/ahmetb/kubectx)
- Adds some handy kubectl aliases

---
### Feedback
If you have any feedback please submit an [issue](/issues)!