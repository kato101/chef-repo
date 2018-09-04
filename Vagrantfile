Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-18.04"
  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.provider "virtualbox" do |vbox|
    vbox.name = "chef-asus-u18"
  end
  config.omnibus.chef_version = :latest
  config.vm.provision "chef_client" do |chef|
    chef.provisioning_path = "/etc/chef"
    chef.chef_server_url = "https://206.189.72.36/organizations/kato101"
    chef.validation_key_path = ".chef/kato101-validator.pem"
    chef.validation_client_name = "kato101-validator"
    chef.node_name = "chef-asus-u18"
  end
end