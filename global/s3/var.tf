variable "bucket_name" {
    description = "The name of the S3 bucket. Must be globally unique."
    type = "string"
    default = "terraforming-up-and-running-state"  
}
variable "table_name" {
    description = "The name of the DynamoDB table."
    type = "string"
    default = "terraform-state-lock"
}

