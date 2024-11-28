# Initialize the modules
module "network" {
  source = "./modules/network"
}

module "security_groups" {
  source = "./modules/security_groups"
  vpc_id = module.network.vpc_id
}

module "edge_layer" {
  source                    = "./modules/edge_layer"
  aws_region                = var.aws_region
  presentation_alb_dns_name = module.presentation.presentation_alb_dns_name
  presentation_alb_id       = module.presentation.presentation_alb_id
}

module "presentation" {
  source                 = "./modules/presentation"
  image_id               = var.image_id
  vpc_id                 = module.network.vpc_id
  vpc_cidr               = module.network.vpc_cidr
  public_subnet_ids      = module.network.public_subnet_ids
  presentation_alb_sg_id = module.security_groups.presentation_alb_sg_id
  presentation_sg_id     = module.security_groups.presentation_sg_id
  depends_on             = [module.business_logic]
}

module "business_logic" {
  source                   = "./modules/business_logic"
  image_id                 = var.image_id
  vpc_id                   = module.network.vpc_id
  public_subnet_ids        = module.network.public_subnet_ids
  private_subnets_ids      = module.network.private_subnets_ids
  business_logic_alb_sg_id = module.security_groups.business_logic_alb_sg_id
  business_logic_sg_id     = module.security_groups.business_logic_sg_id
  DocumentDB_sg_id         = module.security_groups.DocumentDB_sg_id
  depends_on               = [module.database]
}

module "database" {
  source              = "./modules/database"
  vpc_id              = module.network.vpc_id
  vpc_cidr            = module.network.vpc_cidr
  private_subnets_ids = module.network.private_subnets_ids
  DocumentDB_sg_id    = module.security_groups.DocumentDB_sg_id
  depends_on          = [module.network]
}