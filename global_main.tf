module "network" {
  source          = "./modules/network"
  vpc_name        = var.vpc_name
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}

module "security_groups" {
  source = "./modules/security_groups"
  vpc_id = module.network.vpc_id
}

module "edge_layer" {
  source                      = "./modules/edge_layer"
  aws_region                  = var.aws_region
  acm_certificate_arn         = var.acm_certificate_arn
  domain_name                 = var.domain_name
  record_name                 = var.record_name
  cloudfront_aliases          = var.cloudfront_aliases
  presentation_alb_dns_name   = module.presentation.presentation_alb_dns_name
  presentation_alb_id         = module.presentation.presentation_alb_id
  business_logic_alb_dns_name = module.business_logic.business_logic_alb_dns_name
  business_logic_alb_id       = module.business_logic.business_logic_alb_id
  business_logic_alb_zone_id  = module.business_logic.business_logic_alb_zone_id
}

module "presentation" {
  source                 = "./modules/presentation"
  image_id               = var.image_id
  instance_type          = var.instance_type
  key_name               = var.key_name
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
  instance_type            = var.instance_type
  key_name                 = var.key_name
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
  db_name             = var.db_name
  db_username         = var.db_username
  db_password         = var.db_password
  vpc_id              = module.network.vpc_id
  vpc_cidr            = module.network.vpc_cidr
  private_subnets_ids = module.network.private_subnets_ids
  DocumentDB_sg_id    = module.security_groups.DocumentDB_sg_id
  depends_on          = [module.network]
}

module "monitoring" {
  source             = "./modules/monitoring"
  image_id           = var.image_id
  key_name           = var.key_name
  instance_type      = var.instance_type
  public_subnet_ids  = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnets_ids
  Monitoring_sg_id   = module.security_groups.Monitoring_sg_id
  depends_on         = [module.presentation]
}