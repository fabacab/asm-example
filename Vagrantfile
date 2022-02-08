Vagrant.configure("2") do |config|
  config.vm.box = "debian/stretch64"
  config.vm.provision "shell", inline: <<~EOF
      apt update
      apt install --yes vim \
          nasm gcc gdb
  EOF
end
