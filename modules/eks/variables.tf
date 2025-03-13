variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "environment" {
  description = "Environment tag for all resources"
  type        = string
  default     = "development"
}

variable "vpc_id" {
  description = "ID of the VPC where the EKS cluster will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of private subnet IDs for the EKS cluster and node groups"
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "At least 2 private subnets must be specified for high availability."
  }
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.27"
}

variable "instance_types" {
  description = "List of instance types for the EKS node group"
  type        = list(string)
  default     = ["t3.medium"]

  validation {
    condition     = length(var.instance_types) > 0
    error_message = "At least one instance type must be specified."
  }
}

variable "node_group_desired_size" {
  description = "Desired number of nodes in the EKS node group"
  type        = number
  default     = 3
}

variable "node_group_max_size" {
  description = "Maximum number of nodes in the EKS node group"
  type        = number
  default     = 5
}

variable "node_group_min_size" {
  description = "Minimum number of nodes in the EKS node group"
  type        = number
  default     = 1
}

variable "max_unavailable_percentage" {
  description = "Maximum percentage of nodes that can be unavailable during updates"
  type        = number
  default     = 33

  validation {
    condition     = var.max_unavailable_percentage > 0 && var.max_unavailable_percentage <= 100
    error_message = "max_unavailable_percentage must be between 1 and 100."
  }
}