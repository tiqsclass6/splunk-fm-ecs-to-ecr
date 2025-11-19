#!/usr/bin/env bash

# Set ECS cluster name from Terraform
export ECS_CLUSTER="${ecs_cluster}"

# Run the ECS bootstrap script (inlined from 2-ecs-agent.sh)
${infra_script}
