####################################### Network Module #######################################
module "network" {
  source = "./modules/network"
}

####################################### Web Application Module #######################################
module "web_app" {
  source              = "./modules/web_app" 
  vpc_id              = module.network.vpc_id
  public_subnet_ids   = module.network.public_subnet_ids
  web_alb_sg_id       = module.security_groups.web_alb_sg_id
  web_sg_id           = module.security_groups.web_sg_id
  image_id            = data.aws_ami.latest_amazon_linux_2.id
  availability_zones  = data.aws_availability_zones.available.names
}

####################################### Application Servers Module #######################################
module "application_servers" {
  source              = "./modules/application_servers"
  vpc_id              = module.network.vpc_id
  private_subnet_ids  = module.network.private_subnet_ids
  app_alb_sg_id       = module.security_groups.app_alb_sg_id
  app_sg_id           = module.security_groups.app_sg_id
  image_id            = data.aws_ami.latest_amazon_linux_2.id
  availability_zones  = data.aws_availability_zones.available.names
}

####################################### Security Groups Module #######################################
module "security_groups" {
  source = "./modules/security_groups"
  vpc_id = module.network.vpc_id
}
