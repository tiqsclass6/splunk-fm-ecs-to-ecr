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
