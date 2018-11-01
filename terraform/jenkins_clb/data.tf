# Use this to get the AWS Account Id
# ${data.aws_caller_identity.current.account_id}
data "aws_caller_identity" "current" {}

/*
output "account_id" {
  value = "${data.aws_caller_identity.current.account_id}"
}

output "caller_arn" {
  value = "${data.aws_caller_identity.current.arn}"
}

output "caller_user" {
  value = "${data.aws_caller_identity.current.user_id}"
}

# "${data.aws_region.current.name}"
data "aws_region" "current" {
  current = true
}*/

# Query myorg VPC

# Get our myorg-default vpc
data "aws_vpc" "myorg" {
  tags {
    #Name = "myorg-private"
    #Name = "myorg-default"
    Name = "${var.vpc_name}"

  }
}

# private subnets
data "aws_subnet" "private_subnet_0" {
  vpc_id = "${data.aws_vpc.myorg.id}"
  filter {
    name="tag:Name"
    #values=["Private0*"]
    values = ["Private*${var.aws_region}${var.availibity_zone_suffix}*"]
  }
}

data "aws_subnet" "private_subnet_1" {
  vpc_id = "${data.aws_vpc.myorg.id}"
  filter {
    name="tag:Name"
    values=["Private1*"]
  }
}

data "aws_subnet" "private_subnet_2" {
  vpc_id = "${data.aws_vpc.myorg.id}"
  filter {
    name="tag:Name"
    values=["Private2*"]
  }
}

# public subnets
data "aws_subnet" "public_subnet_0" {
  vpc_id = "${data.aws_vpc.myorg.id}"
  filter {
    name="tag:Name"
    values=["Public0*"]
  }
}

data "aws_subnet" "public_subnet_1" {
  vpc_id = "${data.aws_vpc.myorg.id}"
  filter {
    name="tag:Name"
    values=["Public1*"]
  }
}

data "aws_subnet" "public_subnet_2" {
  vpc_id = "${data.aws_vpc.myorg.id}"
  filter {
    name="tag:Name"
    values=["Public2*"]
  }
}

data "aws_availability_zones" "all" {}

# Template for initial configuration bash script
#user_data = "${data.template_file.init.rendered}"
data "template_file" "init" {
  template = "${file("${path.module}/userdata")}"

  vars {

    region = "${var.aws_region}"
    ebs_volume_id = "${aws_ebs_volume.ebs_jenkins.id}"

  }
}


//data "aws_route53_zone" "hosted_zone" {
//  name         = "${var.route53_zone_base}"
//  private_zone = "${var.is_hosted_zone_private}"
//  provider = "aws"
//}

data "aws_acm_certificate" "jenkins_acm" {
  domain   = "*.${var.environment_prefix}.${var.route53_zone_base}"
  types = ["AMAZON_ISSUED"]
  statuses = ["ISSUED"]
  most_recent = true
}