require 'rake'
require 'rspec/core/rake_task'
require 'json'

desc "Run bumpversion"
task :bump, [:part] do |t, args|
  version_filename = 'metadata.json'
  version = JSON.load(File.new(version_filename))['version']

  cmd = "bumpversion --current-version #{version} #{args[:part]} #{version_filename}"
  exec cmd
end

desc "Run parser validation and puppet-lint"
task :lint do
  sh 'puppet parser validate ./manifests/'
  sh 'puppet-lint --no-80chars-check --no-autoloader_layout-check ./manifests'
end
