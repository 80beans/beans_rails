Capistrano::Configuration.instance(:must_exist).load do
  namespace :beans do
 
    desc "Configures staging server"
    task :configure, :roles => :app do
      working_directory = current_path
      
      @service_name = application
      @server_info = YAML.load(File.read(File.join(File.dirname(__FILE__), 'config', "#{rails_env}.yml")))
      @application_name = "#{application}_#{rails_env}"
      @home_path = "/home/#{@application_name}"
      original_ssh_username = ssh_options[:username]
      ssh_options[:username] = Capistrano::CLI.ui.ask("Username that has sudo rights: ")
      
      create_user
      create_htpasswd
      create_vhost
      create_database
    end
    
    desc "Generates SSH key for Git Repository"
    task :generate_ssh_key, :roles => :web do
      run "ssh-keygen -q -f #{@home_path}/.ssh/id_rsa -P '' -t dsa"
      show_ssh_key
    end
    
    desc "Displays SSH Key for application"
    task :show_ssh_key, :roles => :web do
      key = capture "ssh-keygen -y -f #{@home_path}/.ssh/id_rsa"
      puts "===== SSH KEY =====\n"
      puts key
      puts "==================="
    end
    
    desc "Creates the user for the application"
    task :create_user, :roles => :web do
      
      sudo "useradd -d #{@home_path} -m -G www-data #{@application_name}"
      
      public_keys = File.read(File.join(File.dirname(__FILE__), 'templates', "public_keys.txt"))
      
      put public_keys, "#{application}-public_keys.txt"
      sudo "mkdir #{@home_path}/.ssh"
      sudo "cp #{application}-public_keys.txt #{@home_path}/.ssh/authorized_keys"
      sudo "chown -R #{@application_name}:#{@application_name} #{@home_path}/.ssh"
      sudo "rm -rf #{application}-public_keys.txt"
    end
    
    desc "Creates htpasswd user"
    task :create_htpasswd, :roles => :web do
      htpasswd_user = Capistrano::CLI.ui.ask("httpasswd user: ")
      htpasswd_pass = Capistrano::CLI.ui.ask("httpasswd pass: ")
      httpasswd_file = "#{@home_path}/.htpasswd"
      
      sudo "htpasswd -cb #{httpasswd_file} #{htpasswd_user} #{htpasswd_pass}"
    end
 
    desc "Creates an Apache virtual host configuration file"
    task :create_vhost, :roles => :web do
      server_name = @server_info['apache']['base_hostname'] ? "#{application}.#{@server_info['apache']['base_hostname']}" :  Capistrano::CLI.ui.ask("Server hostname: ")
      public_path = "#{current_path}/public"
      application_name = @application_name
      
      template = File.read(File.join(File.dirname(__FILE__), 'templates', "#{rails_env}_vhost.erb"))
      buffer = ERB.new(template).result(binding)
 
      put buffer, "#{application}-apache-vhost.conf"
      sudo "cp #{application}-apache-vhost.conf #{@server_info['apache']['vhost_dir']}/#{application}.conf"
      sudo "rm -rf #{application}-apache-vhost.conf"
      restart_apache
    end
 
    desc "Restart apache"
    task :restart_apache, :roles => :web do
      sudo "/etc/init.d/apache2 restart"
    end
  
    desc "Create database"
    task :create_database, :roles => :db do
      db_name = "#{application}_#{rails_env}"
      
      db_user = application.length < 16 ? application : Capistrano::CLI.ui.ask("Mysql username to long! Mysql username for application: ")
      db_pass = Capistrano::CLI.ui.ask("Mysql password for application user #{db_user}: ")
      
      mysql_user = @server_info['mysql']['user'] ? @server_info['mysql']['user'] :  Capistrano::CLI.ui.ask("Mysql username for db creation: ")
      mysql_pass = @server_info['mysql']['pass'] ? @server_info['mysql']['pass'] :  Capistrano::CLI.ui.ask("Mysql password for #{mysql_user}: ")
      
      
      template = File.read(File.join(File.dirname(__FILE__), 'templates', "database.erb"))
      buffer = ERB.new(template).result(binding)
      
      put buffer, "#{application}-database.sql"
      sudo "mysql -u#{mysql_user} -p#{mysql_pass} < #{application}-database.sql"
      sudo "rm -rf #{application}-database.conf"
    end
  end 
end