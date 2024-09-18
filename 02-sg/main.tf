module "db" {
  source = "git::https://github.com/NarendraNReddy1/terraform-aws-secruitygroup.git"
  project_name = var.project_name
  environment = var.environment
  sg_description = "SG for DB MySQL Instances"
  vpc_id=data.aws_ssm_parameter.vpc_id.value
  sg_name="db"
  common_tags = var.common_tags

}

module "backend" {
  source = "git::https://github.com/NarendraNReddy1/terraform-aws-secruitygroup.git"
  project_name = var.project_name
  environment = var.environment
  sg_description = "SG for backend Instances"
  vpc_id=data.aws_ssm_parameter.vpc_id.value
  sg_name="backend"
  common_tags = var.common_tags

}

module "app_alb" {
  source = "git::https://github.com/NarendraNReddy1/terraform-aws-secruitygroup.git"
  project_name = var.project_name
  environment = var.environment
  sg_description = "SG for app_ab Instances"
  vpc_id=data.aws_ssm_parameter.vpc_id.value
  sg_name="app_alb"
  common_tags = var.common_tags

}

module "frontend" {
  source = "git::https://github.com/NarendraNReddy1/terraform-aws-secruitygroup.git"
  project_name = var.project_name
  environment = var.environment
  sg_description = "SG for frontend Instances"
  vpc_id=data.aws_ssm_parameter.vpc_id.value
  sg_name="frontend"
  common_tags = var.common_tags

}

module "vpn" {
  source = "git::https://github.com/NarendraNReddy1/terraform-aws-secruitygroup.git"
  project_name = var.project_name
  environment = var.environment
  sg_description = "SG for vpn Instances"
  vpc_id=data.aws_ssm_parameter.vpc_id.value
  sg_name="vpn"
  common_tags = var.common_tags
  ingress_rules=var.vpn_sg_rules
}


module "bastion" {
  source = "git::https://github.com/NarendraNReddy1/terraform-aws-secruitygroup.git"
  project_name = var.project_name
  environment = var.environment
  sg_description = "SG for bastion Instances"
  vpc_id=data.aws_ssm_parameter.vpc_id.value
  sg_name="bastion"
  common_tags = var.common_tags

}

module "web_alb" {
  source = "git::https://github.com/NarendraNReddy1/terraform-aws-secruitygroup.git"
  project_name = var.project_name
  environment = var.environment
  sg_description = "SG for web_alb Instances"
  vpc_id=data.aws_ssm_parameter.vpc_id.value
  sg_name="web_alb"
  common_tags = var.common_tags

}


#### VPN RULES


##### RULES

# DB is accepting connections from backend
resource "aws_security_group_rule" "db_backend" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = module.backend.sg_id # source is where you are getting traffic from
  security_group_id = module.db.sg_id
}

resource "aws_security_group_rule" "db_bastion" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = module.bastion.sg_id # source is where you are getting traffic from
  security_group_id = module.db.sg_id
}

resource "aws_security_group_rule" "db_vpn" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id # source is where you are getting traffic from
  security_group_id = module.db.sg_id
}

resource "aws_security_group_rule" "backend_app_alb" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = module.app_alb.sg_id # source is where you are getting traffic from
  security_group_id = module.backend.sg_id
}

resource "aws_security_group_rule" "backend_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.bastion.sg_id # source is where you are getting traffic from
  security_group_id = module.backend.sg_id
}

resource "aws_security_group_rule" "backend_vpn_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id # source is where you are getting traffic from
  security_group_id = module.backend.sg_id
}

resource "aws_security_group_rule" "backend_vpn_http" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id # source is where you are getting traffic from
  security_group_id = module.backend.sg_id
}

resource "aws_security_group_rule" "app_alb_vpn" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id # source is where you are getting traffic from
  security_group_id = module.app_alb.sg_id
}

resource "aws_security_group_rule" "app_alb_bastion" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.bastion.sg_id # source is where you are getting traffic from
  security_group_id = module.app_alb.sg_id
}

resource "aws_security_group_rule" "app_alb_frontend" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.frontend.sg_id # source is where you are getting traffic from
  security_group_id = module.app_alb.sg_id
}

resource "aws_security_group_rule" "frontend_web_alb" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.web_alb.sg_id 
  security_group_id = module.frontend.sg_id
}

resource "aws_security_group_rule" "frontend_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.bastion.sg_id # source is where you are getting traffic from
  security_group_id = module.frontend.sg_id
}

resource "aws_security_group_rule" "frontend_vpn" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id # source is where you are getting traffic from
  security_group_id = module.frontend.sg_id
}

resource "aws_security_group_rule" "web_alb_public" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.web_alb.sg_id
}

resource "aws_security_group_rule" "web_alb_public_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.web_alb.sg_id
}

resource "aws_security_group_rule" "bastion_public" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.bastion.sg_id
}
