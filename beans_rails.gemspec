# Generated by jeweler
# DO NOT EDIT THIS FILE
# Instead, edit Jeweler::Tasks in Rakefile, and run `rake gemspec`
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{beans_rails}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jeff Kreeftmeijer"]
  s.date = %q{2009-12-16}
  s.default_executable = %q{beans_rails}
  s.description = %q{the 80beans rails project template (and generator)}
  s.email = %q{jeff@80beans.com}
  s.executables = ["beans_rails"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.textile"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.textile",
     "Rakefile",
     "VERSION",
     "beans_rails.gemspec",
     "beans_rails.rb",
     "bin/beans_rails",
     "templates/.gitignore",
     "templates/Capfile",
     "templates/Gemfile",
     "templates/config/database.yml",
     "templates/config/deploy.rb",
     "templates/config/deploy/config/staging.yml",
     "templates/config/deploy/production.rb",
     "templates/config/deploy/staging.rb",
     "templates/config/deploy/templates/database.erb",
     "templates/config/deploy/templates/public_keys.txt",
     "templates/config/deploy/templates/staging_vhost.erb",
     "templates/config/preinitializer.rb",
     "templates/recipes/beans_server.rb"
  ]
  s.homepage = %q{http://github.com/80beans/beans_rails}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{the 80beans rails project template (and generator)}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
