worker_processes 3
preload_app true
timeout 30

# setting the below code because of the preload_app true setting above:
# http://unicorn.bogomips.org/Unicorn/Configurator.html#preload_app-method

@delayed_job_pid = nil

before_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
    Rails.logger.info('Disconnected from ActiveRecord')
    # start the delayed_job worker queue in Unicorn, use " -n 2 " to start 2 workers
    @delayed_job_pid ||= spawn("bundle exec rake jobs:work")
  end
end

after_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
    Rails.logger.info('Connected to ActiveRecord')
  end
end