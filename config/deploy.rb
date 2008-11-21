set :application, 'books'

set :repository, 'git://github.com/SeiferSays/book-connection.git'
set :scm, :git
set :branch, 'master'

set :user, 'books'
set :deploy_to, '/home/books/book-connection'
set :deploy_via, :remote_cache
set :use_sudo, false

role :app, 'csx.calvin.edu'
role :web, 'csx.calvin.edu'
role :db,  'csx.calvin.edu', :primary => true

default_run_options[:pty] = true

namespace :deploy do
  desc "Starts up the Ferret server."
  task :start do
    run "cd #{current_path} && ruby script/ferret_server -e production start"
  end
  
  desc "Tell Passenger and the Ferret server to restart."
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
  
  desc "Links in the Ferret server index."
  task :symlink_index do
    run "ln -fs #{shared_path}/index #{release_path}/index"
  end
  
  desc "Symlink shared configs and folders on each release."
  task :symlink_shared do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
end

before 'deploy:symlink', 'deploy:symlink_index'
after 'deploy:update_code', 'deploy:symlink_shared'