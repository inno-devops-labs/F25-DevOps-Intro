# frozen_string_literal: true

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-24.04"
  config.vm.hostname = "quicknotes-lab5"

  # The VM still uses Vagrant's default NAT adapter. Only the forwarded host
  # socket is exposed, and only on loopback.
  config.vm.network "forwarded_port",
                    guest: 8080,
                    host: 18080,
                    host_ip: "127.0.0.1",
                    auto_correct: false

  config.vm.synced_folder "./app",
                          "/opt/quicknotes-src",
                          type: "virtualbox",
                          mount_options: ["dmode=755", "fmode=644"]

  config.vm.provider "virtualbox" do |vb|
    vb.name = "quicknotes-lab5"
    vb.cpus = 2
    vb.memory = 1024
  end

  config.vm.provision "shell", path: "vagrant/provision.sh"
end
