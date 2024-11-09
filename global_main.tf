module "network" {
  source = "./modules/network"
}

module "web_app" {
  source = "./modules/web_app"

}

module "application_servers" {
  source = "./modules/application_servers"

}

module "security_groups" {
  source = "./modules/security_groups"

}

