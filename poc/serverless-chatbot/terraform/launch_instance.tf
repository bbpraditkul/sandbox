provider "aws" {
        access_key = "AKIAJRGA46O6ZABSLSMQ"
        secret_key = "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"
        region = "us-west-2"
}

resource "aws_instance" "test1" {
        ami = "ami-79873901"
        instance_type = "t2.micro"
        key_name = "bryanp-work"
        security_groups = ["bryanp-work"]
        tags {
         Name = "terraform-instance-test"
        }
}
#ami-79873901 --count 1 --instance-type t2.micro --key-name bryanp-work --security-group-ids sg-47831138
