TEMPLATES_DIR = 'http://github.com/80beans/beans_rails/raw/master/templates/'

class Rails::TemplateRunner
  def app_name
    File.basename(root)
  end
  
  def template_file(template, replace = {})
    replace   = {:app_name => app_name}.merge(replace)
    contents  = open(File.join(TEMPLATES_DIR, template)).read
    replace.keys.each { |key| contents.gsub!("{{#{key.to_s}}}", replace[key]) }
    file(template, contents)
  end
end

# removing unnecessary files

['README', 'doc/*', 'log/*', 'test', 'public/index.html', 'public/images/rails.png'].each { |file| run "rm -rf #{file}" }

# installing gems

['haml', 'will_paginate', 'paperclip'].each { |rubygem| gem rubygem }
rake "gems:install", :sudo => true

# generating rspec stuff

generate :rspec

# database config & gitignore

['config/database.yml', '.gitignore'].each { |file| template_file(file) }

# capistrano

if yes?('Add capistrano configuration?')
  template_file('Capfile')
  template_file('config/deploy', { :server => ask('What is the server name?') })
end

#git 

git :init
git :add => "."
git :commit => "-a -m 'Initial commit'"

if yes?("Push to remote git repository? (The repository #{app_name} must be configured in Gitosis)") then
  git :remote => "add origin git@git.80beans.net:#{app_name}.git"
  git :push   => 'origin master:refs/heads/master'
end
