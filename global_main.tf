module "network" {
  source = "./modules/network"
}

module "web_app" {
  source            = "./modules/web_app"
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  web_alb_sg_id     = module.security_groups.web_alb_sg_id
  web_sg_id         = module.security_groups.web_sg_id

}

module "application_servers" {
  source = "./modules/application_servers"

}

module "security_groups" {
  source = "./modules/security_groups"
  vpc_id = module.network.vpc_id
}

