# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.network "forwarded_port", guest: 8983, host: 8983

  config.vm.synced_folder ".", "/vagrant", type: "rsync", rsync__exclude: [".git/", "spec/"]

  config.vm.synced_folder(
    File.join('/var/lib/jenkins/workspaces/search-solr-tools', File.expand_path(File.dirname(__FILE__)).split('/').last),
    '/opt/search-solr-tools',
    type: 'rsync'
  )

  config.vm.provision :nsidc_puppet
end
