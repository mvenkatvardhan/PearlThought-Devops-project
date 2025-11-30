
# Strapi Deployment on AWS using Terraform

This project deploys a **Strapi Headless CMS** on an AWS EC2 instance using **Terraform** and a custom **userdata.sh** script.  
The architecture is built to be simple, secure, and easy to understand for beginners.

---

##  Project Overview

This Terraform project creates:

- A **VPC** with public & private subnets  
- Internet Gateway + Route Tables  
- Security Groups  
- EC2 Instance (Private subnet)  
- User Data script to install Docker & run Strapi  
- Outputs for accessing the instance  

Strapi will run inside a **Docker container** initialized automatically via the user data script.

---

##  Project File Structure

                          ┌─────────────────────────────── ┐
                          │            VPC                 │
                          │                                │
                          │   ┌─────────────────────────┐  │
                          │   │      Public Subnet      │  │
                          │   │                         │  │
                          │   │   Pub-SN1               │  │
                          │   │      │                  │  │
                          │   │      ▼                  │  │
                          │   │    ALB                  │  │
                          │   │      │                  │  │
                          │   │      ▼                  │  │
                          │   │   NAT Gateway           │  │
                          │   │      │                  │  │
                          │   │      ▼                  │  │
                          │   │     Priv-SN1            │  │
                          │   └─────────────────────────┘  │
                          │               │                │
                          │               ▼                │
                          │   ┌─────────────────────────┐  │
                          │   │     Private Subnet      │  │
                          │   │                         │  │
                          │   │       TG  ─────────────▶│  │
                          │   │                         │  │
                          │   │        Strapi (EC2)      │ │
                          │   │                         │  │
                          │   │      Priv-SN2            │ │
                          │   └─────────────────────────┘  │
                          │                                │
                          └───────────────────────────────┘
## Terraform Deployment Process

Follow the steps below to deploy the complete AWS infrastructure and 
automatically install Strapi in the private subnet.

### Initialize Terraform
Initializes all required providers and modules.
terraform init

### Validate Terraform Files
Checks for syntax errors or unsupported arguments.
terraform validate

### Generate a Terraform Plan
Shows the infrastructure changes Terraform will apply.
terraform plan

### Apply the Terraform Configuration
Creates the AWS resources such as VPC, Subnets, ALB, EC2, IGW, Security Groups,
and installs Strapi via user_data.
terraform apply -auto-approve

