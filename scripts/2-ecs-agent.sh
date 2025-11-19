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