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