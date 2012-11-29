require 'bundler/capistrano'

default_run_options[:pty] = true

set :application, "jxb"
set :repository,  "git@58.215.173.29:canvas.git"

set :user, fetch(:user, 'jxb')
set :deploy_to, fetch(:to, "/home/#{user}/apps/#{application}")

set :scm, :git
set :branch, fetch(:branch, "dev")
set :use_sudo, true
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :deploy_server, fetch(:server, '192.168.0.108')

role :web, deploy_server                          # Your HTTP server, Apache/etc
role :app, deploy_server                          # This may be the same as your `Web` server
role :db,  deploy_server, :primary => true # This is where Rails migrations will run
#role :db,  "localhost"

#set :rbenv_version, '1.8.7-p370'
set :rbenv_version, 'ree-1.8.7-2012.02'
set :default_environment, {
  #'RBENV_VERSION' => "#{rbenv_version}",
  'PATH' => "/home/#{user}/.rbenv/shims:/home/#{user}/.rbenv/bin:$PATH"
}

before 'deploy:setup'         , 'jxb:mkdir'
after 'deploy:setup'          , 'jxb:setup_config'
after 'deploy:assets:symlink' , 'jxb:assets:symlink'

namespace :jxb do
  desc 'make deploy dir'
  task :mkdir do
    run "#{try_sudo} mkdir -p #{deploy_to}"
    run "#{try_sudo} chown -R #{user}:#{user} #{deploy_to}"
  end

  desc 'setup all config files from example file, YOU SHOULD MODIFY THEM YOURSELF!'
  task :setup_config do
    run "#{try_sudo} chown -R #{user}:#{user} #{deploy_to}"
    run "mkdir -p #{shared_path}/config"

    %w(cache_store database delayed_jobs 
       domain external_migration file_store
       outgoing_mail redis security session_store).each do |conf|
      upload "config/#{conf}.yml", "#{shared_path}/config/#{conf}.yml"
    end
  end

  namespace :assets do
    desc 'symlink all config files'
    task :symlink do
      %w(cache_store database delayed_jobs 
         domain external_migration file_store
         outgoing_mail redis security session_store).each do |conf|
        run "ln -s #{shared_path}/config/#{conf}.yml #{release_path}/config/#{conf}.yml"
      end
    end
  end
end

# we don't rake assets:precompile
namespace :deploy do
  namespace :assets do
    desc "compile assets"
    task :precompile do
      run "cd #{release_path} && bundle exec rake canvas:compile_assets; true"
    end
  end
end

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

# rewrite bundle:instal because we don't use a Gemfile.lock
namespace :bundle do
  desc "install bundle"
  task :install do
    run "cd #{release_path} && bundle install --without test"
  end
end
