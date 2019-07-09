resource "aws_db_instance" "example" {
    engine = "mysql"
    identifier_prefix = "terraform-up-and-running"
    allocated_storage = 10
    instance_class = "${var.db_size}"  
    name = "${var.db_name}_database"
    skip_final_snapshot = true
    username = "admin"
    password = "${var.db_password}"
}
