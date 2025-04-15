variable "private_subnet_ids" {
  description = "List of private subnet IDs for EKS"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
}

variable "cluster_name" {
  description = "Cluster Name"
  type        = string
}

variable "eks_cluster_sg" { 
  description = "Security group EKS"
  type = string
}