Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-18.04"
  config.omnibus.chef_version = :latest  
  config.vm.provision "chef_client" do |chef|
    chef.provisioning_path = "/etc/chef" 
    chef.chef_server_url = "https://206.189.72.36/organizations/kato101" 
    chef.validation_key_path = "kato101-validator.pem"
    chef.validation_client_name = "kato101-validator" 
    chef.node_name = "chef-node-1" 
  end
end