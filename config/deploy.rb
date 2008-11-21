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
  desc "Does nothing."
  task :start do
    # Do nothing...Passenger should be running already.
  end
  
  desc "Tell Passenger to restart."
  task :restart do
    restart_sphinx
    run "touch #{current_path}/tmp/restart.txt"
  end
  
  desc "Links in the Thinking Sphinx index."
  task :symlink_index do
    run "rm -fr #{release_path}/db/sphinx"
    run "ln -nfs #{shared_path}/db/sphinx #{release_path}/db/sphinx"
  end
  
  desc "Stop the sphinx server."
  task :stop_sphinx do
    run "cd #{current_path} && rake thinking_sphinx:stop RAILS_ENV=production"
  end
  
  desc "Start the sphinx server."
  task :start_sphinx do
    run "cd #{current_path} && rake thinking_sphinx:configure RAILS_ENV=production && rake thinking_sphinx:start RAILS_ENV=production"
  end
  
  desc "Restart the sphinx server"
  task :restart_sphinx do
    stop_sphinx
    start_sphinx
  end
  
  desc "Symlink shared configs and folders on each release."
  task :symlink_shared do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
end

before 'deploy:symlink', 'deploy:symlink_index'
after 'deploy:update_code', 'deploy:symlink_shared'