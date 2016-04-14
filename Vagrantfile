# -*- mode: ruby -*-
# vi: set ft=ruby :

require_relative './bootstrap'

Vagrant.configure("2") do |config|
###for linode provider
    config.vm.provider :linode do |provider, override|
      config.ssh.private_key_path = '~/.ssh/id_rsa'
      override.vm.box = 'linode'
      override.vm.box_url = "https://github.com/displague/vagrant-linode/raw/master/box/linode.box"
      provider.api_key = 'uGVMNzK03N1D601dRpecduLmoGDiAINiWy4qswMoiQJoxFfJn27GV5At4QYOfXgN'
      provider.distribution = 'Ubuntu 12.04 LTS'
      provider.datacenter = 'fremont'
      provider.plan = 'Linode 2048'
      provider.label = "graphite"
      override.vm.provision "shell", :path => File.join(File.dirname(__FILE__),"scripts/linode.sh")
    end

config.vm.box = "precise64"
  #for virtual box
   config.vm.provider :virtualbox do |provider, override|
        override.vm.box = "ubuntu/trusty64"
        override.vm.hostname = "graphite"
        override.vm.network :private_network, ip: "192.168.0.5"
        override.vm.provision "shell", :path => File.join(File.dirname(__FILE__),"scripts/graphite.sh")
        provider.customize ["modifyvm", :id, "--cpus", "2"]
        provider.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]
        provider.customize ["modifyvm", :id, "--memory", "1024"]
      end
end



