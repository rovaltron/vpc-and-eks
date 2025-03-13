# AWS Infrastructure Terraform Modules

This repository contains Terraform modules for creating AWS infrastructure components.

## Getting Started

Follow these steps to set up and deploy the infrastructure:

1. Bootstrap Remote State Storage:
```bash
# Navigate to bootstrap directory
cd bootstrap

# Initialize and apply bootstrap configuration
terraform init
terraform apply
```
When prompted, provide:
- `state_bucket_name`: Globally unique name for your S3 bucket
- Other variables will use defaults unless specified

2. Configure Remote State Backend:
- Update `backend.tf` with your S3 bucket name:
```hcl
terraform {
  backend "s3" {
    bucket         = "YOUR_BUCKET_NAME"  # Replace with your bucket name
    key            = "terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}
```

3. Initialize Main Configuration:
```bash
# Return to root directory
cd ..

# Initialize with remote backend
terraform init
```

4. Deploy Infrastructure:
```bash
# Review the execution plan
terraform plan

# Apply the configuration
terraform apply
```

5. Access Your Infrastructure:
- Follow the "Connecting to EKS Cluster" section below to configure kubectl
- Use the Helm charts in `helm/webapp` to deploy applications

## Modules

### VPC Module

Creates an AWS VPC with the specified CIDR block and networking components.

#### Features

- Creates a VPC with specified CIDR block
- Creates 3 public and 3 private subnets across different AZs
- Creates and attaches an Internet Gateway for public subnets
- Creates NAT Gateway for private subnet internet access
- Configures separate route tables for public and private subnets
- Supports DNS hostnames and DNS support options
- Includes proper tagging for all resources

### EKS Module

Creates an Amazon EKS cluster with managed node groups in private subnets.

#### Features

- Creates an EKS cluster with specified Kubernetes version
- Sets up IAM roles and policies for the cluster and node groups
- Creates a managed node group with 3 instances in private subnets
- Configures security groups for cluster communication
- Includes proper tagging for all resources
- Supports blue-green deployment strategy for zero-downtime upgrades
- Uses launch templates for better node management
- Implements automatic version updates with controlled rollout

### EKS Cluster Version Upgrade Guide

This guide explains how to perform zero-downtime upgrades for both the EKS control plane and worker nodes.

#### Control Plane Upgrade

To upgrade the EKS control plane version:

1. Update the `kubernetes_version` variable in your Terraform configuration:

```hcl
module "eks" {
  source = "./modules/eks"

  kubernetes_version = "1.28"  # New version
  # ... other configuration ...
}
```

The upgrade process:
- Amazon EKS performs a rolling update of the control plane
- Control plane remains available during the upgrade
- The process typically takes 20-30 minutes
- No downtime for your applications

#### Worker Nodes Upgrade (Blue-Green Deployment)

Our EKS module supports zero-downtime worker node upgrades through launch templates and update configurations:

1. The module automatically manages launch template versions
2. Uses `update_config` with `max_unavailable_percentage` for controlled rollout
3. Implements blue-green deployment strategy:
   - Creates new nodes with updated configuration
   - Gradually drains old nodes
   - Maintains minimum available capacity during updates

Example configuration for node group updates:

```hcl
module "eks" {
  source = "./modules/eks"

  kubernetes_version     = "1.28"
  max_unavailable_percentage = 33  # Controls rolling update speed

  node_group_desired_size = 3
  node_group_min_size    = 1
  node_group_max_size    = 5
}
```

#### Best Practices for Zero-Downtime Upgrades

1. Control Plane:
   - Always upgrade one minor version at a time (e.g., 1.26 → 1.27 → 1.28)
   - Test upgrades in a staging environment first
   - Monitor cluster health during upgrade

2. Worker Nodes:
   - Use Pod Disruption Budgets (PDB) for critical applications
   - Maintain sufficient capacity for pod rescheduling
   - Consider increasing node group size temporarily during upgrades
   - Monitor node drain operations and pod evictions

3. General:
   - Review deprecated API versions before upgrading
   - Update cluster add-ons after control plane upgrade
   - Keep node group AMIs up to date
   - Plan maintenance windows for upgrades

### Connecting to EKS Cluster

To connect to your EKS cluster from your local computer:

1. Install prerequisites:
   - AWS CLI v2
   - kubectl
   - aws-iam-authenticator

2. Configure AWS CLI:
```bash
aws configure
```

3. Update kubeconfig:
```bash
aws eks update-kubeconfig --name <cluster-name> --region <region>
```

4. Verify connection:
```bash
kubectl get nodes
```

### AWS Auth ConfigMap and RBAC

The EKS module automatically creates an aws-auth ConfigMap. To add additional users/roles:

1. Get the current aws-auth ConfigMap:
```bash
kubectl get configmap aws-auth -n kube-system -o yaml
```

2. Edit the ConfigMap to add users/roles:
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: arn:aws:iam::ACCOUNT_ID:role/NodeInstanceRole
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
    # Add additional roles here
    - rolearn: arn:aws:iam::ACCOUNT_ID:role/DevTeamRole
      username: dev-team
      groups:
        - development
  mapUsers: |
    # Add IAM users here
    - userarn: arn:aws:iam::ACCOUNT_ID:user/developer
      username: developer
      groups:
        - development
```

3. Apply the updated ConfigMap:
```bash
kubectl apply -f aws-auth-configmap.yaml
```

### Node Group Instance Types

The EKS module supports various EC2 instance types for worker nodes. Configure them using the `instance_types` variable:

```hcl
module "eks" {
  source = "./modules/eks"

  instance_types = ["t3.medium", "t3.large"]  # List of allowed instance types
  # ... other configuration ...
}
```

Recommended instance types by workload:

1. General Purpose (balanced CPU/memory):
   - t3.medium: 2 vCPU, 4 GiB memory
   - t3.large: 2 vCPU, 8 GiB memory
   - t3.xlarge: 4 vCPU, 16 GiB memory

2. Compute Optimized (CPU-intensive workloads):
   - c5.large: 2 vCPU, 4 GiB memory
   - c5.xlarge: 4 vCPU, 8 GiB memory

3. Memory Optimized (memory-intensive workloads):
   - r5.large: 2 vCPU, 16 GiB memory
   - r5.xlarge: 4 vCPU, 32 GiB memory

Best practices for instance selection:
- Use at least 2 vCPU and 4 GiB memory for worker nodes
- Consider using spot instances for non-critical workloads
- Mix instance types for better availability and cost optimization
- Ensure instance types are available in your region


## Requirements

- Terraform >= 1.0.0
- AWS Provider >= 4.0.0

## VPC Module Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vpc_cidr | The CIDR block for the VPC | string | `"10.100.0.0/16"` | no |
| vpc_name | Name tag for the VPC | string | `"main"` | no |
| environment | Environment tag for the VPC | string | `"development"` | no |
| enable_dns_hostnames | Should be true to enable DNS hostnames in the VPC | bool | `true` | no |
| enable_dns_support | Should be true to enable DNS support in the VPC | bool | `true` | no |
| availability_zones | List of availability zones for subnet creation | list(string) | `["us-west-2a", "us-west-2b", "us-west-2c"]` | no |

## EKS Module Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_name | Name of the EKS cluster | string | - | yes |
| vpc_id | ID of the VPC where the EKS cluster will be created | string | - | yes |
| subnet_ids | List of subnet IDs for the EKS cluster and node groups | list(string) | - | yes |
| environment | Environment tag for all resources | string | `"development"` | no |
| kubernetes_version | Kubernetes version for the EKS cluster | string | `"1.27"` | no |
| instance_types | List of instance types for the EKS node group | list(string) | `["t3.medium"]` | no |
| node_group_desired_size | Desired number of nodes in the EKS node group | number | `3` | no |
| node_group_max_size | Maximum number of nodes in the EKS node group | number | `5` | no |
| node_group_min_size | Minimum number of nodes in the EKS node group | number | `1` | no |
| max_unavailable_percentage | Maximum percentage of nodes that can be unavailable during updates | number | `33` | no |

## VPC Module Outputs

| Name | Description |
|------|-------------|
| vpc_id | The ID of the VPC |
| vpc_arn | The ARN of the VPC |
| vpc_cidr_block | The CIDR block of the VPC |
| default_security_group_id | The ID of the default security group |
| default_route_table_id | The ID of the default route table |
| internet_gateway_id | The ID of the Internet Gateway |

## EKS Module Outputs

| Name | Description |
|------|-------------|
| cluster_id | The ID of the EKS cluster |
| cluster_arn | The ARN of the EKS cluster |
| cluster_endpoint | The endpoint for the EKS cluster API server |
| cluster_security_group_id | The security group ID attached to the EKS cluster |
| node_group_id | The ID of the EKS node group |
| node_group_arn | The ARN of the EKS node group |
| node_group_status | Status of the EKS node group |