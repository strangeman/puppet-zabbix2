require 'rake'

begin
  require 'puppet-lint/tasks/puppet-lint'
rescue LoadError
  require 'rubygems'
  retry
end

PuppetLint.configuration.ignore_paths = ["spec/**/*.pp", "pkg/**/*.pp"]
PuppetLint.configuration.send('disable_80chars')

desc "Run lint."
task :test => [:lint]

task :default => :test

desc "Run puppet in noop mode and check for syntax errors."
task :validate do
   Dir['manifests/**/*.pp'].each do |path|
     sh "puppet parser validate --noop #{path}"
   end
end