#!/usr/bin/env rake
require "bundler/gem_tasks"

desc "update elasticsearch version" 
task :update, [:version] do |t, args|
  sh "rm -rf vendor/elasticsearch && mkdir vendor/elasticsearch"
  sh "wget http://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-#{args.version}.tar.gz"
  sh "tar zxvf elasticsearch-#{args.version}.tar.gz"
  sh "mv elasticsearch-#{args.version}/* vendor/elasticsearch"
  sh "rm -rf elasticsearch-#{args.version} elasticsearch-#{args.version}.tar.gz"
  sh "cp vendor/elasticsearch/bin/elasticsearch.in.sh lib/springboard/generators/templates"
  File.open("lib/springboard/version.rb", "w") do |f|
    f.write <<EOS
module Springboard
  VERSION = "#{args.version}"
end
EOS
  end
end

desc "Clean data from vendor/elasticsearch"
task :clean do
  sh "rm -rf log vendor/elasticsearch/logs vendor/elasticsearch/data"
end
