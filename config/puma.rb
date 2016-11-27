threads Integer(ENV['PUMA_THREADS']  || 1), Integer(ENV['PUMA_THREADS'] || 8)

workers Integer(ENV['PUMA_WORKERS'] || 1)

app_dir = File.expand_path("../..", __FILE__)
shared_dir = "#{app_dir}/shared"

rackup DefaultRackup
rack_env = ENV['RACK_ENV'] || 'development'
environment rack_env

if rack_env == 'development'
  port = ENV['PORT'] || 5000
  backlog = Integer(ENV['PUMA_BACKLOG'] || 20)
  bind "tcp://0.0.0.0:#{port}?backlog=#{backlog}"
else
  bind "unix://#{shared_dir}/sockets/puma.sock"
end

pidfile "#{shared_dir}/pids/puma.pid"
state_path "#{shared_dir}/pids/puma.state"

activate_control_app
