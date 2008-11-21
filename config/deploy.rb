set :application, 'books'

set :repository, 'git://github.com/SeiferSays/book-connection.git'
set :scm, :git
set :branch, 'master'

set :user, 'books'
set :deploy_to, '/home/books/book-connection'
set :deploy_via, :remote_cache
set :use_sudo, false
set :runner, nil

role :app, 'csx.calvin.edu'
role :web, 'csx.calvin.edu'
role :db,  'csx.calvin.edu', :primary => true

default_run_options[:pty] = true

namespace :deploy do
  desc "Tell Passenger and the Ferret server to restart."
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
    run "cd #{current_path} && ruby script/ferret_server -e production stop"
    run "cd #{current_path} && ruby script/ferret_server -e production start"
  end
  
  desc "Symlink shared configs and folders on each release."
  task :symlink_shared do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
end

after 'deploy:update_code', 'deploy:symlink_shared'