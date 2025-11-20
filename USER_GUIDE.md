# USER GUIDE – Splunk on ECS (AWS Console–Only ClickOps Version)

> [!WARNING]
> This guide is still a work in progress. Not ready for primetime.

![AWS](https://img.shields.io/badge/AWS-Cloud-orange?logo=amazonaws)
![ECS](https://img.shields.io/badge/Amazon%20ECS-EC2%20Launch%20Type-blue?logo=amazonaws)
![ECR](https://img.shields.io/badge/Amazon%20ECR-Container%20Registry-red?logo=amazonaws)
![EC2](https://img.shields.io/badge/Amazon%20EC2-Compute-yellow?logo=amazonaws)
![VPC](https://img.shields.io/badge/AWS-VPC-green?logo=amazonaws)
![ClickOps](https://img.shields.io/badge/Deployment-ClickOps-9cf?logo=googlechrome)
![Splunk](https://img.shields.io/badge/Splunk-Enterprise-black?logo=splunk)

This guide walks you through deploying **Splunk Enterprise on Amazon ECS using ONLY the AWS Console**.  
No CLI. No Terraform. No local scripts. 100% ClickOps.

---

## Prerequisites

- AWS Console Access  
- Admin or PowerUser IAM permissions  
- Splunk Docker image available locally  
- Basic understanding of ECS, EC2, and ALB concepts  

---

## Create a `docker-compose.yaml` file

```yaml
    services:
      splunk:
        image: splunk/splunk:latest
        hostname: splunk-enterprise
        environment:
          SPLUNK_START_ARGS=--accept-license --no-prompt
          SPLUNK_PASSWORD=<your_pw_here>
          SPLUNK_LICENSE_URI=/run/secrets/splunk_license
        ports:
          - "8000:8000" # Splunk Web UI
          - "8088:8088" # HEC (HTTP Event Collector)
          - "8089:8089" # Management port
        volumes:
          - splunk_data:/opt/splunk/var
          - splunk_etc:/opt/splunk/etc
    volumes:
      splunk_data:
      splunk_etc:
```

---

## Start-up Docker Desktop

- **Initialize and Run  Docker Compose**

  ```bash
  docker login
  docker compose up -d
  ```

  ![docker-compose.jpg](/Screenshots/2-clickops/docker-compose.jpg)

---

## Create Private Respository (AWS)

- Log into AWS
- Go to Amazon ECR - Private Registry - Repositories
- Click **Create Repository**
![create-ecr-pt1.jpg](/Screenshots/2-clickops/create-ecr-pt1.jpg)
- Repository name: `tiqsclass6/splunk_fm_ecr_to_ecs`
- Image tag settings: **Mutable**
- Mutable tag exclusions: *leave blank*
![create-ecr-pt2.jpg](/Screenshots/2-clickops/create-ecr-pt2.jpg)
- Encryption settings: **AES-256**
- Click **Create**
![create-ecr-pt3.jpg](/Screenshots/2-clickops/create-ecr-pt3.jpg)
![create-ecr-pt4.jpg](/Screenshots/2-clickops/create-ecr-pt4.jpg)
- Click on `tiqsclass6/splunk_fm_ecr_to_ecs`
- Click **View push commands**
![create-ecr-pt5.jpg](/Screenshots/2-clickops/create-ecr-pt5.jpg)
- Click **Windows** tab at the top.
![create-ecr-pt6.jpg](/Screenshots/2-clickops/create-ecr-pt6.jpg)

> [!TIP}
> You do not need to execute step 2 because you ran docker compose.
> Also at the beginning of Step 3, remove your repository name and add `splunk/splunk`

- **View Push Commands**

  ```bash
  aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com

  docker tag splunk/splunk:latest <ACCOUNT_ID>.dkr.ecr.us-east-1-amazonaws.com/tiqsclass6/splunk_fm_ecr_to_ecs:latest

  docker push <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/tiqsclass6/splunk_fm_ecr_to_ecs:latest
  ```

  ![docker-push-commands-pt1.jpg](/Screenshots/2-clickops/docker-push-commands-pt1.jpg)
  ![docker-push-commands-pt2.jpg](/Screenshots/2-clickops/docker-push-commands-pt2.jpg)

---

## Create ECS Cluster (AWS)

- Click *Create cluster*
  ![create-cluster-pt1.jpg](/Screenshots/2-clickops/create-cluster-pt1.jpg)
- Cluster name: `splunk-ecs`
- Infrastructure:
  - Uncheck **AWS Fargate**
  - Check **Amazon EC2 instances**
![create-cluster-pt2.jpg](/Screenshots/2-clickops/create-cluster-pt2.jpg)

- Auto Scaling Group (ASG):
  - Create new ASG
  - Provisioning model: **On-demand**
  - Container instance Amazon Machine Image (AMI): **Amazon Linux 2023**
  - EC2 instance type: **c7i-flex.large**
  - EC2 instance role: **ec2-to-ecr**
  - Desired capacity:
    - **Minimum**: `1`
    - **Maximum**: `2`
- Network Settings for Amazon EC2 instances
  - Create new VPC
  - Resources to create: **VPC and more**
  - VPC name: `splunk`
  - IPv4 CIDR Block: `10.240.0.0/16`
  - IPv6 CIDR Block: **No IPv6 CIDR Block
- Number of Availability Zones (AZ's): `2`
  - Customize AZs: *Set your availability zones*
- Number of Public subnets: `2`
- Number of Private subnets: `2`
- Customize subnets CIDR blocks:
  - Public subnet #1: `10.240.1.0/24`
  - Public subnet #2: `10.240.2.0/24`
  - Private subnet #1: `10.240.11.0/24`
  - Private subnet #2: `10.240.12.0/24`
- NAT Gateway: **In 1 AZ**
- VPC Endpoints: **None*
- DNS options:
  - Enable DNS hostnames: *Checked*
  - Enable DNS resolution: *Checked*
- Create VPC
- Refresh your VPC section. Choose `splunk-vpc`
- Subnets: `Keep all four (4) subnets: Two Public and Two Private
- Security Group:
  - Create an Security Group
  - Security group name: `splunk-sg`
  - Security group description: `Splunk Security Group for ECS`
  - Inbound rules for security groups:
    - Type: **Custom TCP**
    - Protocol: **TCP**
    - Port range: `8000`
    - Source: **Custom**
    - `splunk-alb-sg`
- Auto-assign public IP: *Use subnet setting*
- Monitoring:
  - Container Insights: **Container Insights with enhanced observability**
  - ECS Exec encryption and logging: *leave blank*
  - Logging for ECS Exec: *Default*
- Click **Create**

---

## Create a Splunk Load Balancer Security Group

- Security Group name: `splunk-alb-sg`
- Description: `splunk-alb-sg`
- VPC: **splunk-vpc**
- Inbound Rules:
  - Type: HTTP
  - Protocol: TCP
  - Port range: `80`
  - Source: Anywhere IPv4
  - `0.0.0.0/0`
  - Description - optional: `HTTP`
- Click **Create security group**

---

## Create Task Definition

- Task definition family: `splunk-task-df`
- Infrastructure requirements:
  - Launch type: Amazon EC2 instances *Checked*
  - OS, Architecture, Network Mode: *Leave as default*
  - Task size: *Leave as default*
  - Take role: **ec2TaskExecutionRole**
  - Task execution role: **ec2TaskExecutionRole**
- Task placement: *Leave blank*
- Fault injection: *Leave blank*
- Container:
  - Name: `splunk-container`
  - Image URI: Browse files and choose **namespace/splunk_fm_ecr_to_ecs**
    - Click on **latest** image.
    - Select image by: Image digest
  - Private registry: *Leave unchecked*
  - Port mappings:
    - Container port: `8000` / Protocol: **TCP** / Port name: `splunk` / App protocol: **HTTP**
    - Container port: `8088` / Protocol: **TCP** / Port name: `splunk-hec` / App protocol: **HTTP**
    - Container port: `8089` / Protocol: **TCP** / Port name: `splunk-mgmt` / App protocol: **HTTP**
  - Environment variables:
    - Key: SPLUNK_START_ARGS / Value type: Value / Value: `--accept-license --no-prompt`
    - Key: SPLUNK_PASSWORD: / Value type: Value / Value: `tiqs_pwd_1`
    - Key: SPLUNK_GENERAL_TERMS / Value type: Value / Value: `--accept-sgt-current-at-splunk-com`
  - *Leave everything else as default*
  - Click **Create**

## Create ECS Service

- Click on `splunk-ecs-df` task definition click **Deploy** then select **Create service**.
- Service details:
  - Task definition family: *splunk-task-df*
  - Task definition revision: *1*
  - Service name: `splunk-ecs-svc`
- Environment:
  - Existing cluster: **splunk-ecs-df**
  - Compute options: **capacity provider strategy**
  - Capacity provider strategy: **Use cluster default**
  - Troubleshooting configuration (recommended): *leave as default*
- Deployment configuration:
  - Scheduling strategy: **Replica**
  - Desired tasks: 1
  - Availability Zone rebalancing: **Turn on Availability Zone rebalancing**
  - Health check grace period: 120
- Networking:
  - VPC: `splunk-vpc`
  - Subnets: **Use public subnets only!!!**
  - Security group: `splunk-sg`
- Load balancing:
  - Load balancer type: Application Load Balancer
  - Container: *leave as default*
  - Application Load Balancer: Create new load balancer
  - Load balancer name: `splunk-alb`
  - Listener: Create new listener
    - Port: 80
    - Protocol: HTTP
  - Target Group: Create new target group
    - Target group name: `splunk-alb-tg`
    - Protocol: HTTP
    - Port: 80
    - Deregistration delay: 300
    - Health check protocol: HTTP
    - Health check path: `/`
- Service auto scaling (optional):
  - Use service auto scaling: **Checked**
  - Minimum number of tasks: `1`
  - Maximum number of tasks: `2`
  - Scaling target type: Target tracking
  - Policy name: `splunk-asg-policy`
  - ECS service metric: **ECSServiceAverageCPUUtilization**
  - Target value: 60
  - Scale-out cooldown period: 300
  - Scale-in cooldown period: 300
- Click **Create**

---

## Go to EC2 - Load Balancers

- Click on your load balancer
- Copy the **DNS name** (will use this for your Splunk URL)

---

## Splunk Web UI

- Username: `admin`
- Password: `<insert_pwd_here>`

---

## Teardown

---

## Troubleshooting

### ❗ ALB 503 – Service Unavailable

- ECS task not running
- Target group shows **unhealthy**
- Fix: Ensure port 8000 mapping is correct

---

### ❗ ALB 504 – Gateway Timeout

- ALB → ECS SG rule missing
- Splunk container still initializing

---

### ❗ EC2 Instance Not Joining ECS Cluster

- User data incorrect  
- IAM role missing ECS permissions  

---

### ❗ Task Stuck in “PROVISIONING”

- ECR image pull failed  
- Incorrect repository URI  

---

## Author

**T.I.Q.S.**  
Cloud & DevOps Engineer  
GitHub: <https://github.com/tiqsclass6>  
Specializing in AWS, ECS, Terraform, and automation.

---

End of Guide.
