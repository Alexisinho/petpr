# Pet — Flask Calculator CI/CD on AWS (concise)

Short repo documentation for provisioning, deploying and monitoring a small Flask app on EC2 using Terraform + Ansible and Docker.

## Quick summary
- Terraform: provisions VPC, subnet, security group, key pair and EC2 instances.
- Ansible: installs Docker, pulls the app image, runs containers and deploys Prometheus + node_exporter.
- CI: builds image, pushes to Docker Hub, runs Terraform + Ansible (via pipeline).

## Prerequisites (control host)
- Terraform >= 1.0
- Ansible >= 2.10
- Python3, pip
- Install collections & libs:
```bash
pip3 install --user boto3 botocore
ansible-galaxy collection install amazon.aws community.docker
```
- AWS credentials in env or `~/.aws/credentials`
- Docker Hub credentials for pipeline

## Files of interest
- main.tf — root Terraform config
- modules/ — Terraform modules (subnet, webserver)
- terraform/terraform.tfvars — variables (keys, CIDRs)
- pet-playbook.yaml — Ansible playbook
- inventory/aws_ec2.yaml — dynamic inventory (aws_ec2 plugin)
- pipeline.yaml — CI pipeline
- app.py, Dockerfile — application

## Quick start (local)
1. Edit terraform/terraform.tfvars (public_key_path, private_key_location, etc.)
2. Provision infra:
```bash
cd g:\DevOps\pet
terraform init
terraform apply -var-file=terraform/terraform.tfvars
```
3. Verify outputs (public IPs):
```bash
terraform output
```
4. Test Ansible inventory:
```bash
ansible-inventory -i inventory/aws_ec2.yaml --list -vvv
```
5. Run playbook:
```bash
ansible-playbook -i inventory/aws_ec2.yaml pet-playbook.yaml -vv
```

## SSH to instances
```bash
ssh -i C:/Users/you/.ssh/myapp_key ec2-user@<PUBLIC_IP>
```
Ensure the private key matches the public key uploaded to AWS.

## Notes / common fixes
- Permission denied (publickey): wrong private key, wrong key format, or instance created with a different key — regenerate or recreate instance.
- aws_ec2 inventory fails to parse: ensure boto3/botocore installed and AWS credentials available; run ansible-inventory with -vvv to see traceback.
- Ansible docker modules error (docker_login/docker_image): install `community.docker` collection and ensure remote host has Python `docker` package (`pip3 install docker`).
- urllib3 / OpenSSL errors on remote: either pin `urllib3<2` via pip or upgrade Python/OpenSSL on the remote. Example workaround in playbook:
```yaml
- pip:
    name: "urllib3<2"
    executable: pip3
```
- Duplicate SG / keypair errors in Terraform: create keypair and security group in root module and pass them into modules (avoid creating duplicates inside count-based modules).

## Outputs & testing
- App: http://<EC2_IP> — web UI
- Health: http://<EC2_IP>/health — {"status":"ok"}
- Prometheus: http://<EC2_IP>:9090 — targets show node-exporter and app

## CI/CD
- pipeline.yaml builds and pushes Docker image, runs Terraform and Ansible.
- Save secrets (AWS creds, DOCKERHUB_USERNAME, DOCKERHUB_TOKEN) in CI secret store.

## License
MIT — learning project.

If you want, I can:
- generate a static inventory from Terraform outputs,
- add outputs to main.tf (public IP list),
- or produce exact Ansible role/tasks for the playbook.