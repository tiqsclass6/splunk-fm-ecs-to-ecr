# 🚀 Splunk ECS on AWS – Infrastructure Deployment (Professional Documentation)

![Terraform](https://img.shields.io/badge/Terraform-IaC-844FBA?logo=terraform&logoColor=white)
![AWS Cloud](https://img.shields.io/badge/AWS-Cloud-FF9900?logo=amazonaws&logoColor=white)
![ECS](https://img.shields.io/badge/Amazon_ECS-EC2_Launch_Type-FF9900?logo=amazonaws&logoColor=white)
![ECR](https://img.shields.io/badge/Amazon_ECR-Container_Registry-FF4F00?logo=amazonaws&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Containers-2496ED?logo=docker&logoColor=white)
![Splunk](https://img.shields.io/badge/Splunk-Enterprise-black?logo=splunk&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-Bash_Scripting-gray?logo=linux&logoColor=white)
![Security](https://img.shields.io/badge/Security-Best_Practices-2E8B57?logo=awslambda&logoColor=white)
![DevOps](https://img.shields.io/badge/DevOps-Automation-20C997?logo=githubactions&logoColor=white)
![CloudWatch](https://img.shields.io/badge/AWS-CloudWatch_Logs-FF4F8B?logo=amazonaws&logoColor=white)

## 📌 Overview

This repository provides a modular, production‑grade Terraform and automation framework to deploy **Splunk Enterprise on Amazon ECS (EC2 Launch Type)**. The architecture emphasizes repeatability, clarity, automation, and enterprise DevOps standards.

![diagram.png](/Screenshots/diagram.png)

---

## 🏗 Architecture Summary

### **Core Components**

- Amazon VPC (public/private subnets)
- Application Load Balancer
- ECS Cluster (EC2 Launch Type)
- Auto Scaling Group
- ECS Task Definition (Splunk container)
- Amazon Linux 2023 ECS‑Optimized AMI
- ECR Repository (managed by script)
- IAM roles for EC2, ECS tasks, CloudWatch logs

### **Deployment Flow**

1. Build Splunk image → Push to ECR  
2. Provision infrastructure via Terraform  
3. ECS pulls image → Splunk becomes available via ALB  

---

## 🗂 Project Structure

```plaintext
📦 splunk-ecs-terraform/
│
├── 📂 Screenshots/
│   ├── aws-ecr-pt1.jpg
│   ├── aws-ecr-pt2.jpg
│   ├── aws-ecs-cluster-pt1.jpg
│   ├── aws-ecs-cluster-pt2.jpg
│   ├── aws-ecs-cluster-pt3.jpg
│   ├── aws-ecs-cluster-pt4.jpg
│   ├── aws-ecs-cluster-pt5.jpg
│   ├── aws-ecs-cluster-pt6.jpg
│   ├── cloudwatch-pt1.jpg
│   ├── cloudwatch-pt2.jpg
│   ├── docker-compose-pt1.jpg
│   ├── docker-compose-pt2.jpg
│   ├── ec2-instances.jpg
│   ├── splunk-pt1.jpg
│   ├── splunk-pt2.jpg
│   ├── splunk-pt3.jpg
│   ├── splunk-pt4.jpg
│   ├── teardown.jpg
│   ├── terraform-apply.jpg
│   ├── terraform-destroy.jpg
│   ├── terraform-init-validate.jpg
│   └── terraform-plan.jpg
│
├── 📂 scripts/
│   ├── 1-docker-compose.sh
│   ├── 2-ecs-agent.sh
│   ├── 3-teardown.sh
│   └── splunk-userdata.tpl
│
├── 📂 terraform/
│   ├── 0-authentication.tf
│   ├── 1-providers.tf
│   ├── 2-variables.tf
│   ├── 3-vpc.tf
│   ├── 4-subnets.tf
│   ├── 5-gateways.tf
│   ├── 6-rtbs.tf
│   ├── 7-sg-all.tf
│   ├── 8-launch-template.tf
│   ├── 9-tg.tf
│   ├── 10-load-balancer.tf
│   ├── 11-cloudwatch.tf
│   ├── 12-autoscaling-group.tf
│   ├── 13a-ecs-cluster.tf
│   ├── 13b-ecs-cluster-capacity.tf
│   ├── 13c-ecs-service.tf
│   ├── 13d-ecs-task_definitions.tf
│   ├── 14-iam.tf
│   └── 15-outputs.tf
│
└── 🚫 .gitignore
├── 🐳 docker-compose.yaml
├── 📘 README.md
└── 📗 USER_GUIDE.md
```

---

## 📘 Project Structure (With GitHub Links)

| 📄 **File** | 📝 **Description** |
|------------|------------------|
| 🔐 **[0-authentication.tf](https://github.com/tiqsclass6/splunk-fm-ecs-to-ecr/blob/main/0-authentication.tf)** | Configures AWS authentication references (profiles, credentials). |
| 🌍 **[1-providers.tf](https://github.com/tiqsclass6/splunk-fm-ecs-to-ecr/blob/main/1-providers.tf)** | Defines AWS provider and global region settings. |
| 🔧 **[2-variables.tf](https://github.com/tiqsclass6/splunk-fm-ecs-to-ecr/blob/main/2-variables.tf)** | Centralized variable definitions. |
| 🌐 **[3-vpc.tf](https://github.com/tiqsclass6/splunk-fm-ecs-to-ecr/blob/main/3-vpc.tf)** | Creates the VPC, CIDR ranges, DNS hostnames, DNS support. |
| 🛰️ **[4-subnets.tf](https://github.com/tiqsclass6/splunk-fm-ecs-to-ecr/blob/main/4-subnets.tf)** | Defines public and private subnets across AZs. |
| 🚪 **[5-gateways.tf](https://github.com/tiqsclass6/splunk-fm-ecs-to-ecr/blob/main/5-gateways.tf)** | Creates Internet Gateway (IGW) and NAT Gateways. |
| 🛣️ **[6-rtbs.tf](https://github.com/tiqsclass6/splunk-fm-ecs-to-ecr/blob/main/6-rtbs.tf)** | Route tables & associations for public/private subnets. |
| 🛡️ **[7-sg-all.tf](https://github.com/tiqsclass6/splunk-fm-ecs-to-ecr/blob/main/7-sg-all.tf)** | Security groups (ALB, ECS instances, outbound rules). |
| 📦 **[8-launch-template.tf](https://github.com/tiqsclass6/splunk-fm-ecs-to-ecr/blob/main/8-launch-template.tf)** | EC2 Launch Template incl. ECS agent config + user-data. |
| 🎯 **[9-tg.tf](https://github.com/tiqsclass6/splunk-fm-ecs-to-ecr/blob/main/9-tg.tf)** | Target group for ALB (port 8000 + health checks). |
| ⚖️ **[10-load-balancer.tf](https://github.com/tiqsclass6/splunk-fm-ecs-to-ecr/blob/main/10-load-balancer.tf)** | Application Load Balancer + listener config. |
| 📊 **[11-cloudwatch.tf](https://github.com/tiqsclass6/splunk-fm-ecs-to-ecr/blob/main/11-cloudwatch.tf)** | CloudWatch log groups for ECS tasks. |
| 📈 **[12-autoscaling-group.tf](https://github.com/tiqsclass6/splunk-fm-ecs-to-ecr/blob/main/12-autoscaling-group.tf)** | Auto Scaling Group for ECS EC2 instances. |
| 🏗️ **[13a-ecs-cluster.tf](https://github.com/tiqsclass6/splunk-fm-ecs-to-ecr/blob/main/13a-ecs-cluster.tf)** | ECS Cluster configuration. |
| 🔌 **[13b-ecs-cluster-capacity.tf](https://github.com/tiqsclass6/splunk-fm-ecs-to-ecr/blob/main/13b-ecs-cluster-capacity.tf)** | ECS capacity provider linked to ASG. |
| 🚀 **[13c-ecs-service.tf](https://github.com/tiqsclass6/splunk-fm-ecs-to-ecr/blob/main/13c-ecs-service.tf)** | ECS Service with ALB integration. |
| 📦 **[13d-ecs-task_definitions.tf](https://github.com/tiqsclass6/splunk-fm-ecs-to-ecr/blob/main/13d-ecs-task_definitions.tf)** | ECS Task Definitions defining Splunk container. |
| 🔑 **[14-iam.tf](https://github.com/tiqsclass6/splunk-fm-ecs-to-ecr/blob/main/14-iam.tf)** | IAM instance role, task exec role, task role. |
| 📤 **[15-outputs.tf](https://github.com/tiqsclass6/splunk-fm-ecs-to-ecr/blob/main/15-outputs.tf)** | Outputs DNS names, ARNs, IDs, LB URLs. |

---

## 🔧 Scripts Overview

### **1-docker-compose.sh**

- Builds/pulls Splunk Docker image  
- Creates ECR repo if missing  
- Logs into ECR  
- Pushes tagged image  

```bash
#!/usr/bin/env bash
###############################################################################
# Purpose: Create (if needed) and push Splunk image to Amazon ECR
# Author: T.I.Q.S.
# Version: 2.1
#
# Description:
#   This script:
#     - Resolves AWS caller identity
#     - Ensures the ECR repository exists (creates it if missing)
#     - Logs into ECR
#     - Ensures the local Docker image exists (pulls if missing)
#     - Tags a local Docker image
#     - Pushes the image to ECR
#
#   Default ECR repository:
#     tiqsclass6/splunk-ecs-to-ecr/splunk
#
###############################################################################

set -euo pipefail

########################################
# COLOR SETUP
########################################

if [ -t 1 ]; then
  RED="\033[0;31m"
  GREEN="\033[0;32m"
  YELLOW="\033[0;33m"
  BLUE="\033[0;34m"
  RESET="\033[0m"
else
  RED=""
  GREEN=""
  YELLOW=""
  BLUE=""
  RESET=""
fi

########################################
# DEFAULT CONFIGURATION
########################################

# Use REGION -> AWS_REGION -> AWS_DEFAULT_REGION -> fallback
REGION="${REGION:-${AWS_REGION:-${AWS_DEFAULT_REGION:-us-east-1}}}"

IMAGE="${IMAGE:-splunk/splunk}"                                 # Source image
REPOSITORY="${REPOSITORY:-tiqsclass6/splunk-ecs-to-ecr/splunk}" # ECR repo name
TAG="${TAG:-latest}"                                            # Tag to push

########################################
# USAGE / HELP
########################################

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Options:
  --region <aws-region>       AWS region (default: ${REGION})
  --image <image>             Source image name (default: ${IMAGE})
  --repository <name>         ECR repository name (default: ${REPOSITORY})
  --tag <tag>                 Image tag to push (default: ${TAG})
  -h, --help                  Show this help message and exit

Environment variables (optional):
  REGION, AWS_REGION, AWS_DEFAULT_REGION, IMAGE, REPOSITORY, TAG

Default ECR repository:
  ${REPOSITORY}

Example:
  $(basename "$0") --region us-east-1 --image splunk/splunk --tag latest
EOF
}

########################################
# ARGUMENT PARSING
########################################

while [[ $# -gt 0 ]]; do
  case "$1" in
    --region)
      REGION="$2"
      shift 2
      ;;
    --image)
      IMAGE="$2"
      shift 2
      ;;
    --repository)
      REPOSITORY="$2"
      shift 2
      ;;
    --tag)
      TAG="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo -e "${RED}[ERROR] Unknown option: $1${RESET}" >&2
      usage
      exit 1
      ;;
  esac
done

########################################
# LOGGING HELPERS
########################################

info()    { echo -e "${BLUE}[INFO ]${RESET} $*"; }
warn()    { echo -e "${YELLOW}[WARN ]${RESET} $*"; }
success() { echo -e "${GREEN}[OK   ]${RESET} $*"; }
error()   { echo -e "${RED}[ERROR]${RESET} $*" >&2; }

########################################
# PRE-FLIGHT CHECKS
########################################

command -v aws >/dev/null 2>&1    || { error "aws CLI is not installed or not in PATH."; exit 1; }
command -v docker >/dev/null 2>&1 || { error "docker is not installed or not in PATH."; exit 1; }

########################################
# FETCH AWS IDENTITY
########################################

echo -e "${YELLOW}Step 1: Fetching AWS caller identity...${RESET}"
Account=$(aws sts get-caller-identity --query "Account" --output text)
UserId=$(aws sts get-caller-identity --query "UserId" --output text)
Arn=$(aws sts get-caller-identity --query "Arn" --output text)

info "AWS Account:   ${Account}"
info "User ID:       ${UserId}"
info "ARN:           ${Arn}"
info "AWS Region:    ${REGION}"
echo -e "${GREEN}✅ AWS caller identity fetched successfully.${RESET}\n"

########################################
# BUILD ECR URIs / NAMES
########################################

echo -e "${YELLOW}Step 2: Building Elastic Container Registry URIs and names...${RESET}"
ECR_URI="${Account}.dkr.ecr.${REGION}.amazonaws.com"
ECR_REPO_NAME="${REPOSITORY}"                        # e.g., tiqsclass6/splunk-ecs-to-ecr/splunk
FULL_ECR_IMAGE="${ECR_URI}/${ECR_REPO_NAME}:${TAG}"  # full image URL with tag
info "ECR URI:       ${ECR_URI}"
info "ECR Repository: ${ECR_REPO_NAME}"
info "Full ECR Image: ${FULL_ECR_IMAGE}"
echo -e "${GREEN}✅ ECR URIs and names built successfully.${RESET}\n"

########################################
# ENSURE ECR REPOSITORY EXISTS (CREATE IF MISSING)
########################################

echo -e "${YELLOW}Step 3: Ensuring ECR repository exists...${RESET}"
info "Checking if ECR repository '${ECR_REPO_NAME}' exists in region '${REGION}'..."

if aws ecr describe-repositories \
    --repository-names "${ECR_REPO_NAME}" \
    --region "${REGION}" >/dev/null 2>&1; then

  success "ECR repository '${ECR_REPO_NAME}' already exists."

else
  warn "ECR repository '${ECR_REPO_NAME}' not found. Creating..."
  aws ecr create-repository \
    --repository-name "${ECR_REPO_NAME}" \
    --region "${REGION}" >/dev/null 2>&1
  success "ECR repository '${ECR_REPO_NAME}' created."
fi
echo -e "${GREEN}✅ ECR repository check/creation completed.${RESET}\n"

########################################
# LOGIN TO AMAZON ECR
########################################

echo -e "${YELLOW}Step 4: Logging into Amazon ECR...${RESET}"
info "Logging into Amazon ECR at ${ECR_URI}..."

aws ecr get-login-password --region "${REGION}" \
  | docker login --username AWS --password-stdin "${ECR_URI}"

success "Successfully logged into Amazon ECR."
echo -e "${GREEN}✅ ECR login completed.${RESET}\n"

########################################
# ENSURE LOCAL IMAGE EXISTS
########################################

echo -e "${YELLOW}Step 5: Ensuring local Docker image exists...${RESET}"
info "Checking for local image: ${IMAGE}:${TAG}"

if ! docker image inspect "${IMAGE}:${TAG}" >/dev/null 2>&1; then
  warn "Local image ${IMAGE}:${TAG} not found. Pulling from registry..."
  docker pull "${IMAGE}:${TAG}"
  success "Pulled image ${IMAGE}:${TAG}"
else
  success "Local image ${IMAGE}:${TAG} already present."
fi
echo -e "${GREEN}✅ Local image check/pull completed.${RESET}\n"

########################################
# TAG LOCAL IMAGE FOR ECR
########################################

echo -e "${YELLOW}Step 6: Tagging local image for ECR...${RESET}"
info "Tagging local image:"
info "   Source: ${IMAGE}:${TAG}"
info "   Target: ${FULL_ECR_IMAGE}"

docker tag "${IMAGE}:${TAG}" "${FULL_ECR_IMAGE}"

success "Local image tagged for ECR."
echo -e "${GREEN}✅ Image tagging completed.${RESET}\n"

########################################
# PUSH IMAGE TO ECR
########################################

echo -e "${YELLOW}Step 7: Pushing image to Amazon ECR...${RESET}"
info "Pushing image to Amazon ECR..."
docker push "${FULL_ECR_IMAGE}"
success "Image pushed to ECR successfully."
echo -e "${GREEN}✅ Image push completed.${RESET}\n"

########################################
# DONE
########################################

echo -e "${GREEN}✅ All steps completed successfully!${RESET}"
echo -e "       ${GREEN}${FULL_ECR_IMAGE}${RESET}"
echo -e "${GREEN}You can now use this image in your ECS task definitions.${RESET}"
echo -e "${GREEN}You can now safely run: terraform apply${RESET}"
```

### **2-ecs-agent.sh**

Used by Launch Template to:

- Configure ECS cluster name  
- Boot EC2 into ECS cluster mode  
- Set ECS agent configs  

```bash
#!/usr/bin/env bash
###############################################################################
# Purpose: Configure ECS Agent with proper ECS Cluster assignment
# Author: T.I.Q.S.
# Version: 2.0
#
# Description:
#   This script sets the ECS_CLUSTER value inside /etc/ecs/ecs.config.
#   Enhanced with colorized output, safety flags, validation, and structured
#   logging for clean DevOps visibility.
# 
###############################################################################

# Exit immediately if a command fails, variable is unset, or pipe fails
set -euo pipefail

########################################
# COLOR & HEADER SETUP
########################################

if [ -t 1 ]; then
  GREEN="\033[0;32m"
  YELLOW="\033[1;33m"
  RED="\033[0;31m"
  BLUE="\033[0;34m"
  CYAN="\033[0;36m"
  RESET="\033[0m"
else
  GREEN=""
  YELLOW=""
  RED=""
  BLUE=""
  CYAN=""
  RESET=""
fi

step_header() {
  echo -e "${CYAN}=========================================="
  echo -e "🔹 $1"
  echo -e "==========================================${RESET}\n"
}

########################################
# LOGGING HELPERS
########################################

info()    { echo -e "${BLUE}[INFO ]${RESET} $*"; }
success() { echo -e "${GREEN}[OK   ]${RESET} $*"; }
warn()    { echo -e "${YELLOW}[WARN ]${RESET} $*"; }
error()   { echo -e "${RED}[ERROR]${RESET} $*"; }

########################################
# STEP 1: VALIDATE EXPECTED VARIABLES
########################################

step_header "STEP 1: Validating ECS_CLUSTER Environment Variable"

if [[ -z "${ECS_CLUSTER:-}" ]]; then
  error "ECS_CLUSTER variable is not set. Ensure Terraform or user data renders it properly."
  exit 1
fi

info "Using ECS Cluster: ${ECS_CLUSTER}"

########################################
# STEP 2: ENSURE ECS CONFIG DIRECTORY EXISTS
########################################

step_header "STEP 2: Ensuring /etc/ecs Directory Exists"

CONFIG_DIR="/etc/ecs"
CONFIG_PATH="${CONFIG_DIR}/ecs.config"

info "Ensuring ECS directory exists at ${CONFIG_DIR}..."
mkdir -p "${CONFIG_DIR}"
success "Directory verified: ${CONFIG_DIR}"

########################################
# STEP 3: WRITE / UPDATE ECS CONFIG
########################################

step_header "STEP 3: Writing ECS Cluster Configuration to ${CONFIG_PATH}"

if [[ -f "${CONFIG_PATH}" ]]; then
  warn "Existing ECS config found. Removing any previous ECS_CLUSTER lines..."
  # Remove old ECS_CLUSTER lines to avoid duplicates
  sed -i.bak '/^ECS_CLUSTER=/d' "${CONFIG_PATH}" || true
fi

echo "ECS_CLUSTER=${ECS_CLUSTER}" >> "${CONFIG_PATH}"

success "ECS agent configured successfully!"
info "Final ${CONFIG_PATH} contents:"
echo "------------------------------------------"
cat "${CONFIG_PATH}" || true
echo "------------------------------------------"

echo -e "Written value: ${GREEN}ECS_CLUSTER=${ECS_CLUSTER}${RESET}\n"
echo "-------------------------------------------------------------------------------------"
echo -e "${GREEN}ECS Agent is now configured to join cluster: ${ECS_CLUSTER}${RESET}"
echo -e "${GREEN}You can verify this by checking the ECS agent logs or AWS Console.${RESET}"
```

### **3-teardown.sh**

Handles cleanup:

- Deletes ECR repo + images  
- Optional docker-compose cleanup  
- Ensures system is ready for Terraform destroy  

```bash
#!/usr/bin/env bash
###############################################################################
# Purpose: Tear down local Splunk docker-compose stack and cleanup ECR repo
# Author: T.I.Q.S.
# Version: 2.1
#
# Description:
#   This script:
#     - Optionally brings down the docker-compose stack (containers + volumes)
#     - Deletes the Splunk ECR repository (and all images in it)
#
#   Use this BEFORE running `terraform destroy` when using Option B
#   (ECR managed by scripts, not Terraform).
#
###############################################################################

# Exit immediately on error, unset vars, or failed pipes
set -euo pipefail

########################################
# COLOR & HEADER SETUP
########################################

if [ -t 1 ]; then
  RED="\033[0;31m"
  GREEN="\033[0;32m"
  YELLOW="\033[0;33m"
  BLUE="\033[0;34m"
  CYAN="\033[0;36m"
  RESET="\033[0m"
else
  RED=""
  GREEN=""
  YELLOW=""
  BLUE=""
  CYAN=""
  RESET=""
fi

step_header() {
  echo -e "${CYAN}=========================================="
  echo -e "🔹 $1"
  echo -e "==========================================${RESET}\n"
}

########################################
# DEFAULT CONFIGURATION
########################################

COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.yaml}"
SKIP_COMPOSE="${SKIP_COMPOSE:-false}"

# Region resolution: REGION -> AWS_REGION -> AWS_DEFAULT_REGION -> fallback
REGION="${REGION:-${AWS_REGION:-${AWS_DEFAULT_REGION:-us-east-1}}}"

# Default ECR repository for this project
REPOSITORY="${REPOSITORY:-tiqsclass6/splunk-ecs-to-ecr/splunk}"

########################################
# USAGE / HELP
########################################

usage() {
  cat <<EOF
Usage: $(basename "\$0") [options]

Options:
  --compose-file <path>    docker-compose file to use (default: ${COMPOSE_FILE})
  --skip-compose           Skip docker-compose teardown (only cleanup ECR)
  --region <aws-region>    AWS region for ECR (default: ${REGION})
  --repository <name>      ECR repository name (default: ${REPOSITORY})
  -h, --help               Show this help message and exit

Environment variables (optional):
  COMPOSE_FILE, SKIP_COMPOSE, REGION, AWS_REGION, AWS_DEFAULT_REGION, REPOSITORY

Examples:
  $(basename "\$0")
  $(basename "\$0") --skip-compose
  REGION=us-east-1 $(basename "\$0")
EOF
}

########################################
# LOGGING HELPERS
########################################

info()    { echo -e "${BLUE}[INFO ]${RESET} $*"; }
warn()    { echo -e "${YELLOW}[WARN ]${RESET} $*"; }
success() { echo -e "${GREEN}[OK   ]${RESET} $*"; }
error()   { echo -e "${RED}[ERROR]${RESET} $*" >&2; }

########################################
# ARGUMENT PARSING
########################################

while [[ $# -gt 0 ]]; do
  case "$1" in
    --compose-file)
      COMPOSE_FILE="$2"
      shift 2
      ;;
    --skip-compose)
      SKIP_COMPOSE="true"
      shift 1
      ;;
    --region)
      REGION="$2"
      shift 2
      ;;
    --repository)
      REPOSITORY="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo -e "${RED}[ERROR] Unknown option: $1${RESET}" >&2
      usage
      exit 1
      ;;
  esac
done

########################################
# STEP 1: PRE-FLIGHT CHECKS
########################################

step_header "STEP 1: Running Teardown Pre-Flight Checks"

# AWS CLI is required for ECR cleanup
command -v aws >/dev/null 2>&1 || { error "aws CLI is not installed or not in PATH."; exit 1; }

# Docker is only required if we're doing compose teardown AND file exists
if [[ "${SKIP_COMPOSE}" != "true" ]] && [[ -f "${COMPOSE_FILE}" ]]; then
  if ! command -v docker >/dev/null 2>&1; then
    warn "docker is not installed; skipping docker-compose teardown."
    SKIP_COMPOSE="true"
  fi
fi

success "Pre-flight checks complete."

###########################################################
# STEP 2: TEAR DOWN DOCKER-COMPOSE STACK (OPTIONAL)
##########################################################

step_header "STEP 2: Optional docker-compose Stack Teardown"

if [[ "${SKIP_COMPOSE}" == "true" ]]; then
  info "Skipping docker-compose teardown (SKIP_COMPOSE=true)."
else
  if [[ -f "${COMPOSE_FILE}" ]]; then
    info "Tearing down docker-compose stack using file: ${COMPOSE_FILE}"

    if command -v docker-compose >/dev/null 2>&1; then
      docker-compose -f "${COMPOSE_FILE}" down -v
    elif docker compose version >/dev/null 2>&1; then
      docker compose -f "${COMPOSE_FILE}" down -v
    else
      warn "Neither 'docker-compose' nor 'docker compose' is available. Skipping compose teardown."
    fi

    success "Docker stack torn down (containers and volumes removed)."
  else
    warn "Compose file '${COMPOSE_FILE}' not found. Skipping docker-compose teardown."
  fi
fi

########################################
# STEP 3: ECR REPOSITORY CLEANUP
########################################

step_header "STEP 3: Cleaning Up ECR Repository"

info "Preparing to delete ECR repository (and images)."
info "  Region:     ${REGION}"
info "  Repository: ${REPOSITORY}"

ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
ECR_URI="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"

info "AWS Account: ${ACCOUNT_ID}"
info "ECR URI:     ${ECR_URI}"

info "Checking if ECR repository '${REPOSITORY}' exists in region '${REGION}'..."

if aws ecr describe-repositories \
    --repository-names "${REPOSITORY}" \
    --region "${REGION}" >/dev/null 2>&1; then

  warn "ECR repository '${REPOSITORY}' found. Deleting with --force (including all images)..."
  aws ecr delete-repository \
    --repository-name "${REPOSITORY}" \
    --region "${REGION}" \
    --force >/dev/null 2>&1

  success "ECR repository '${REPOSITORY}' deleted successfully."
else
  warn "ECR repository '${REPOSITORY}' does not exist in ${REGION}. Skipping ECR cleanup."
fi

########################################
# STEP 4: DONE
########################################

step_header "✅ DONE: Teardown Script Complete"

success "Teardown complete."
echo -e "${GREEN}You can now safely run: terraform destroy${RESET}\n"
echo -e "${CYAN}Remember to also delete any local .env files or secrets if needed.${RESET}"
echo -e "${CYAN}Thank you for using the teardown script!${RESET}\n"
```

### **splunk-userdata.tpl**

Injected into the EC2 launch template.

```bash
#!/usr/bin/env bash

# Set ECS cluster name from Terraform
export ECS_CLUSTER="${ecs_cluster}"

# Run the ECS bootstrap script (inlined from 2-ecs-agent.sh)
${infra_script}
```

---

## 🚀 Deployment Workflow (Professional Overview)

### **1️⃣ Build & Push the Splunk Image**

This step prepares the Splunk image in Amazon ECR.

```bash
./scripts/1-docker-compose.sh
```

![docker-compose-pt1.jpg](/Screenshots/docker-compose-pt1.jpg)
![docker-compose-pt2.jpg](/Screenshots/docker-compose-pt2.jpg)

This script:

- Ensures the ECR repo exists (creates it if missing)
- Pulls or builds the Splunk image
- Tags and pushes it to ECR with colorized output

---

### **2️⃣ Provision AWS Infrastructure**

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

![terraform-init-validate.jpg](/Screenshots/terraform-init-validate.jpg)
![terraform-plan.jpg](/Screenshots/terraform-plan.jpg)

Terraform deploys:

- Networking  
- ALB  
- Security groups  
- IAM  
- ECS cluster  
- ASG  
- Task definition  
- Service  

Once the ECS tasks start, the ALB exposes Splunk UI at:

```plaintext
http://<alb_dns_name>
```

![terraform-apply.jpg](/Screenshots/terraform-apply.jpg)

---

### **3️⃣ Tear Down (Safe Workflow)**

```bash
./scripts/3-teardown.sh
terraform destroy
```

![teardown.jpg](/Screenshots/teardown.jpg)
![terraform-destroy.jpg](/Screenshots/terraform-destroy.jpg)

The teardown script:

- Deletes ECR repositories + images  
- Optionally destroys docker-compose assets  
- Prepares environment for a clean `terraform destroy`

---

## 📸 Screenshots (Show Your Work)

- **AWS Elastic Container Registry (ECR)**
![aws-ecr-pt1.jpg](/Screenshots/aws-ecr-pt1.jpg)
![aws-ecr-pt2.jpg](/Screenshots/aws-ecr-pt2.jpg)

- **AWS Elastic Container Service (ECS)**
![aws-ecs-cluster-pt1.jpg](/Screenshots/aws-ecs-cluster-pt1.jpg)
![aws-ecs-cluster-pt2.jpg](/Screenshots/aws-ecs-cluster-pt2.jpg)
![aws-ecs-cluster-pt3.jpg](/Screenshots/aws-ecs-cluster-pt3.jpg)
![aws-ecs-cluster-pt4.jpg](/Screenshots/aws-ecs-cluster-pt4.jpg)
![aws-ecs-cluster-pt5.jpg](/Screenshots/aws-ecs-cluster-pt5.jpg)
![aws-ecs-cluster-pt6.jpg](/Screenshots/aws-ecs-cluster-pt6.jpg)

- **AWS CloudWatch**
![cloudwatch-pt1.jpg](/Screenshots/cloudwatch-pt1.jpg)
![cloudwatch-pt2.jpg](/Screenshots/cloudwatch-pt2.jpg)

- **AWS EC2 Instances**
![ec2-instances.jpg](/Screenshots/ec2-instances.jpg)

---

## 🟠 Splunk Web U/I

![splunk-pt1.jpg](/Screenshots/splunk-pt1.jpg)
![splunk-pt2.jpg](/Screenshots/splunk-pt2.jpg)
![splunk-pt3.jpg](/Screenshots/splunk-pt3.jpg)
![splunk-pt4.jpg](/Screenshots/splunk-pt4.jpg)

---

## 🩺 Troubleshooting Guide

### 🔥 ALB Returns 503 (Service Unavailable)

Cause: No healthy ECS targets  
Fix:

- ECS tasks failing to start  
- Wrong container port  
- Health check mismatch  

---

### 🔥 ALB Returns 504 (Gateway Timeout)

Cause: ALB can reach instance but not container  
Fix:

- Allow ALB → ECS SG on port 8000  
- Splunk still initializing  
- Incorrect health check path  

---

### 🔥 CannotPullContainerError

Cause: Missing ECR image or IAM  
Fix:

- Re-run `1-docker-compose.sh`  
- Confirm image exists in ECR  
- Ensure execution role has `AmazonECSTaskExecutionRolePolicy`  

---

### 🔥 EC2 Not Joining ECS Cluster

Fix:
Ensure `ECS_CLUSTER="splunk"` exists in user data.

---

## ✍️ Authors & Acknowledgments

- **Author:** T.I.Q.S.
- **Group Leader:** John Sweeney

---
