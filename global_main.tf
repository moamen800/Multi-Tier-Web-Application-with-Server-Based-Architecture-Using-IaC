####################################### edge Module #######################################
# module "edge_layer" {
#   source               = "./modules/edge_layer"
#   aws_region           = var.aws_region
#   web_app_alb_dns_name = module.web_app.web_app_alb_dns_name
#   web_app_alb_id       = module.web_app.web_app_alb_id
# }

####################################### Network Module #######################################
module "network" {
  source = "./modules/network"
}

####################################### Web Application Module #######################################
module "web_app" {
  source                = "./modules/web_app"
  vpc_id                = module.network.vpc_id
  vpc_cidr              = module.network.vpc_cidr
  public_subnet_web_ids = module.network.public_subnet_web_ids
  web_alb_sg_id         = module.security_groups.web_alb_sg_id
  web_sg_id             = module.security_groups.web_sg_id
  image_id              = "ami-0866a3c8686eaeeba"
}

####################################### Application Servers Module #######################################
module "application_servers" {
  source                = "./modules/application_servers"
  vpc_id                = module.network.vpc_id
  public_subnet_app_ids = module.network.public_subnet_app_ids
  app_alb_sg_id         = module.security_groups.app_alb_sg_id
  app_sg_id             = module.security_groups.app_sg_id
  image_id              = "ami-0866a3c8686eaeeba"
}

# module "database" {
#   source             = "./modules/database"
#   vpc_id             = module.network.vpc_id
#   private_subnet_ids = module.network.private_subnet_ids
#   db_sg_id           = module.security_groups.db_sg_id
# }

####################################### Security Groups Module #######################################
module "security_groups" {
  source = "./modules/security_groups"
  vpc_id = module.network.vpc_id
}
