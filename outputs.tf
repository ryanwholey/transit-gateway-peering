output main_instance {
  value = {
    private_ip = module.main.instance.private_ip
    public_ip  = module.main.instance.public_ip
  }
}

output playground_instance {
  value = {
    private_ip = module.playground.instance.private_ip
    public_ip  = module.playground.instance.public_ip
  }
}
