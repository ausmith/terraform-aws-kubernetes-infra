variable "vpc_cidr" {
  description = "CIDR range to be used in setting up the VPC."
}

variable "name" {
  description = "Name of the environment. Will be used to prefix resources as well."
}

variable "region" {
  description = "The AWS region this will be deployed, used mostly for naming."
}

variable "owner_tag" {
  description = "Optional input for an 'Owner' tag on resources."
  default     = ""
}

variable "env_tag" {
  description = "Optional input for an 'Environment' tag on resources."
  default     = ""
}

variable "az_list" {
  description = "List of availability zones where resources should live."
  default     = []
}

variable "public_subnet_cidrs" {
  description = "A list of CIDRs included in the 'vpc_cidr' range provided for the public subnets."
  default     = []
}

variable "private_subnet_cidrs" {
  description = "A list of CIDRs included in the 'vpc_cidr' range provided for the private subnets."
  default     = []
}

variable "ingress_ports" {
  description = "List of ports to open for node ingress."
  default     = []
}

variable "control_origins" {
  description = "List of IP CIDRs kube API requests will be sent from."
  default     = []
}

variable "toggle_ingress_nlb" {
  description = "Toggle on/off ingress NLB (uses count) accepts 1 or 0."
  default = 0
}
