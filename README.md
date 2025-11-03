Task:

Full CI/CD Pipeline for Dockerized Web App on AWS EC2
Design and implement a simple web application (Node.js, Python, or static HTML).

Version control with Git, using feature branches and pull requests.

Build Docker image via GitHub Actions, push to Docker Hub (free tier).

Provision AWS EC2 instance using Terraform; ensure security group and IAM best practices.

Use Ansible to configure the EC2 instance, deploy the Docker container, and manage app lifecycle.

Add basic health-check monitoring (Prometheus + node_exporter or simple script).

Automate deployment: Every merge to main triggers the CI/CD pipeline.

Document steps and automation in README.

---

Pet Project – Flask Calculator with Automated Deployment and Monitoring
Overview

This project demonstrates a simple Flask-based calculator web app deployed automatically on AWS EC2 using Terraform and Ansible.
Monitoring and basic health checks are handled through Prometheus and Node Exporter.

The entire setup is automated end-to-end:

Terraform → Infrastructure provisioning → Ansible → App deployment + Monitoring setup

⚙️ Tech Stack
Layer	Tool	Purpose
Infrastructure	Terraform	Provision AWS EC2 instance and networking
Configuration Management	Ansible	Install Docker, deploy app containers, configure Prometheus
Application	Flask (Python)	Simple calculator with / UI and /health endpoint
Monitoring	Prometheus + Node Exporter	System and app-level health checks
📁 Project Structure
.
├── app.py                    # Flask calculator app
├── Dockerfile                # (if used to build the app image)
├── pet-playbook.yaml         # Ansible playbook (app + Prometheus deployment)
├── pipeline.yaml             # CI/CD pipeline definition
├── main.tf                   # Terraform infrastructure configuration
└── README.md                 # Project documentation

🏗️ Infrastructure Setup (Terraform)

Terraform provisions:

AWS EC2 instance

Security group with inbound rules for:

80/tcp – Flask app (HTTP)

9090/tcp – Prometheus UI

22/tcp – SSH access (for Ansible)

EC2 IAM role, networking, and key pair (if applicable)

Run Commands
terraform init
terraform plan
terraform apply


Once applied, Terraform outputs your EC2 public IP (you’ll use this in Ansible’s inventory).

⚡ Deployment Automation (Ansible)

The pet-playbook.yaml performs the following steps:

Installs Python, pip, and Docker on the EC2 host

Logs in to Docker Hub and pulls your app image (DOCKER_IMAGE)

Runs your pet-app container (port 80 → 80)

Deploys Prometheus + Node Exporter containers

Automatically creates prometheus.yml with health check targets

Opens ports 9090 (Prometheus) and 9100 (Node Exporter)

Example command:
ansible-playbook -i inventory.ini pet-playbook.yaml

Environment Variables (provided in CI/CD):
Variable	Description
DOCKERHUB_USERNAME	Docker Hub username
DOCKERHUB_TOKEN	Access token or password
DOCKER_IMAGE	Full image name, e.g. aliaksinho13/hub-repo:latest
🧩 Application Details

Flask web app with a simple calculator UI:

Routes:

/ — Web interface for arithmetic operations

/health — Basic health check (returns {status: "ok"})

Example response:

curl http://<EC2-IP>/health
# {"status": "ok"}

📊 Monitoring (Prometheus + Node Exporter)

Prometheus is deployed via Docker and automatically configured to scrape:

Node Exporter (localhost:9100) — EC2 system metrics (CPU, memory, disk, etc.)

App container (localhost:80/health) — App availability check

Access Prometheus:

http://<EC2_PUBLIC_IP>:9090


View active targets under Status → Targets:

node-exporter

pet-app

🛡️ Security Group Recommendations

If using Terraform for SG configuration:

# HTTP - app
ingress {
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

# Prometheus - restricted
ingress {
  from_port   = 9090
  to_port     = 9090
  protocol    = "tcp"
  cidr_blocks = ["YOUR_IP/32"]
}


❗ Node Exporter (9100) should remain internal — Prometheus scrapes it locally.

🔄 CI/CD Pipeline

The included pipeline.yaml automates:

Terraform apply (infra provisioning)

Ansible deploy (application + monitoring)

Docker login and image pull

Optional post-deploy validation

Secrets such as Docker credentials are securely stored in GitHub Actions Secrets or your CI platform environment variables.

🧠 Verification

After deployment:

Check	Command	Expected Result
Flask App	curl http://<EC2_IP>	Web page loads
Health	curl http://<EC2_IP>/health	{status:"ok"}
Prometheus	curl http://<EC2_IP>:9090/targets	Lists active targets
Node Exporter	curl http://<EC2_IP>:9100/metrics	Shows system metrics
🧰 Future Improvements

Add Grafana for visual dashboards

Include Alertmanager for uptime alerts

Use Ansible roles for modular deployments

Automate SSH key management for Terraform + Ansible integration

📄 License

MIT License © 2025 — Created as a learning pet project demonstrating Terraform, Ansible, and Prometheus integration.

Would you like me to tailor this README even further — for example,
add actual commands for your specific Terraform variables (from your main.tf) and link it directly with the EC2 outputs?