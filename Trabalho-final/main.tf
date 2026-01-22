module "app_server" {
  source          = "./modules/count"
  instances_count = 2  # Aqui você passa o valor
}