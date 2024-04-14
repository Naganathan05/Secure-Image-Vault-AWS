variable "region" {
  description = "Denotes the region where resources are created"
  type = string
}

variable "table_name" {
  description = "Name of the DynamoDB Table"
  type = string
}

variable "hash_key" {
  description = "Primary Key of the DynamoDB Table"
  type = string
}

variable "api_name" {
  description = "API Name"
  type = string
}