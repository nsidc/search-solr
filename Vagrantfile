# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.network "forwarded_port", guest: 8983, host: 8983

  config.vm.synced_folder ".", "/vagrant", type: "rsync", rsync__exclude: [".git/", "spec/"]
  config.vm.synced_folder ".", "/opt/search-solr", type: "rsync", rsync__exclude: [".git/", "spec/"]

  # On the CI machine, the search-solr-tools git project will be checked out once per each environment.
  # We want to grab the correct one for this env and rsync it.  We can do that because the current Vagrantfile
  # is in #{ path }/#{ environment }/Vagrantfile
  solr_tools_path = File.join(
    '/var/lib/jenkins/workspaces/search-solr-tools',
    File.expand_path(File.dirname(__FILE__)).split('/').last
  )

  puts "solr_tools_path==#{ solr_tools_path }"

  config.vm.synced_folder(
    solr_tools_path,
    '/opt/search-solr-tools',
    type: 'rsync'
  ) if File.exist?(solr_tools_path)

  config.vm.provision :nsidc_puppet
end
