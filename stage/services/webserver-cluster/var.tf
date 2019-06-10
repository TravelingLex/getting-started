variable "server_port" {
    description = "The port the server will use for HTTP requests"
    default = 8080
}
variable "web_image_id" {
    description = "Image ID for web servers"
    default = "ami-07b4156579ea1d7ba"
}