# USER GUIDE – Splunk on ECS (AWS Console–Only ClickOps Version)

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

## Step 1 – Create the VPC

1. Go to **VPC → Your VPCs → Create VPC**
2. Choose **VPC Only**
3. Name: `splunk-ecs-vpc`
4. CIDR: `10.240.0.0/16`
5. Enable DNS hostnames & resolution  
6. Click **Create**

---

## Step 2 – Create Subnets

Create **three public** and **three private** subnets.

| Name | AZ | CIDR | Public? |
|------|----|-------|---------|
| public-a | us-east-1a | 10.240.1.0/24 | Yes |
| public-b | us-east-1b | 10.240.2.0/24 | Yes |
| public-c | us-east-1c | 10.240.3.0/24 | Yes |
| private-a | us-east-1a | 10.240.11.0/24 | No |
| private-b | us-east-1b | 10.240.12.0/24 | No |
| private-c | us-east-1c | 10.240.13.0/24 | No |

For public subnets:  
**Actions → Edit subnet settings → Enable Auto-assign public IPv4**

---

## Step 3 – Create Gateways

### Internet Gateway

1. VPC → Internet Gateways → Create
2. Name: `splunk-igw`
3. Attach to VPC

### NAT Gateway

1. VPC → NAT Gateway → Create
2. Subnet: public-a
3. EIP: Allocate new
4. Name: `splunk-nat`

### Elastic IP

1. VPC → Elastic IPs → Allocate new
2. Name: `splunk-eip`
3. Public

---

## Step 4 – Create Route Tables

### Public Route Table

- Name: `splunk-public-rtb`
- Associate: public-a, public-b
- Add route:  
  `0.0.0.0/0 → Internet Gateway`

### Private Route Table

- Name: `splunk-private-rtb`
- Associate: private-a, private-b
- Add route:  
  `0.0.0.0/0 → NAT Gateway`

---

## Step 5 – Create Security Groups

## ALB Security Group

Name: `splunk-alb-sg`  
Inbound:

- HTTP 80 from anywhere (0.0.0.0/0)

## ECS Instance Security Group

Name: `splunk-ecs-sg`  
Inbound:

- TCP 8000 from **splunk-alb-sg**

Outbound: allow all.

---

## Step 6 – Create Application Load Balancer

Navigate: **EC2 → Load Balancers → Create Load Balancer**

- Type: **Application Load Balancer**
- Name: `splunk-alb`
- Internet-facing
- Subnets: public-a, public-b, public-c
- Security group: `splunk-alb-sg`

### Target Group

- Name: `splunk-tg`
- Target type: instance
- Protocol: HTTP
- Port: 8000
- Health check path: `/`

---

## Step 7 – Create Launch Template

### **EC2 → Launch Templates → Create template**

- Name: `splunk-ecs-lt`
- AMI: **Amazon Linux 2023 ECS-Optimized**
- Instance: m6.xlarge
- Security group: `splunk-ecs-sg`
- IAM Role: **EC2 Container Service role**
- User data:

```bash
#!/bin/bash
echo "ECS_CLUSTER=splunk-cluster" >> /etc/ecs/ecs.config
```

---

## Step 8 – Create Auto Scaling Group

Navigate: **EC2 → Auto Scaling Groups → Create**

- Name: `splunk-asg`
- Launch Template: `splunk-ecs-lt`
- Network: splunk-ecs-vpc
- Subnets: private-a, private-b
- Desired/min/max: 1/1/1
- Attach to target group: `splunk-tg`

---

## Step 9 – Create ECS Cluster

Navigate: **ECS → Clusters → Create**

- Name: `splunk-cluster`
- Infrastructure: **EC2 Linux + Networking**

---

## Step 10 – Upload Splunk Image to ECR

Navigate: **ECR → Create repository**

Name:

```plaintext
tiqsclass6/splunk-ecs-to-ecr/splunk
```

Upload image via:

- **Upload image** button  
or  
- Use the built-in "push commands" panel

---

## Step 11 – Create Task Definition

Navigate: **ECS → Task Definitions → Create**

- Launch type: EC2
- Name: `splunk-task`
- Execution role: Create new
- Add container:
  - Name: `splunk`
  - Image:  
    `ACCOUNT_ID.dkr.ecr.REGION.amazonaws.com/tiqsclass6/splunk-ecs-to-ecr/splunk:latest`
  - Port: 8000
  - Memory: 4096
  - CPU: 1024

---

## Step 12 – Create ECS Service

Navigate: **ECS → Cluster → Services → Create service**

- Launch type: EC2
- Task definition: `splunk-task`
- Desired count: 1
- Load balancer: Application Load Balancer
- Target group: `splunk-tg`

Wait for:

- Running tasks = 1  
- Status = STEADY  

---

## Step 13 – Validate Deployment

Open ALB DNS:

```plaintext
http://<alb-dns-name>
```

Expected:

- Splunk UI loads (may take 2–4 minutes on first boot)

---

## Step 14 – Teardown

Delete in this order:

1. ECS Service  
2. ECS Cluster  
3. Auto Scaling Group  
4. Launch Template  
5. EC2 Instances  
6. Load Balancer  
7. Target Group  
8. ECR Repository  
9. Security Groups  
10. NAT Gateway  
11. Internet Gateway  
12. Route Tables  
13. Subnets  
14. VPC  

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
