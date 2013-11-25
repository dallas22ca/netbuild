namespace :faye do
  desc "Start Faye"
  task :start, :roles => :app do
    run "cd #{current_path}; thin start -C config/faye.yml"
  end

  desc "Stop Faye"
  task :stop, :roles => :app do
    run "cd #{current_path}; thin stop -C config/faye.yml"
  end

  desc "Restart Faye"
  task :restart, :roles => :app do
    run "cd #{current_path}; thin restart -C config/faye.yml"
  end
end

before 'deploy:start', 'faye:start'
before 'deploy:stop', 'faye:stop'
before 'deploy:restart', 'faye:restart'