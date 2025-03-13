variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.100.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "Must be a valid IPv4 CIDR block."
  }
}

variable "vpc_name" {
  description = "Name tag for the VPC"
  type        = string
  default     = "main"
}

variable "environment" {
  description = "Environment tag for the VPC"
  type        = string
  default     = "development"
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "availability_zones" {
  description = "List of availability zones for subnet creation"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]

  validation {
    condition     = length(var.availability_zones) >= 3
    error_message = "At least 3 availability zones must be specified."
  }
}