threads Integer(ENV['PUMA_THREADS']  || 8), Integer(ENV['PUMA_THREADS'] || 8)

workers Integer(ENV['PUMA_WORKERS'] || 3)

rackup DefaultRackup
port = ENV['PORT'] || 5000
backlog = Integer(ENV['PUMA_BACKLOG'] || 20)
environment ENV['RACK_ENV'] || 'development'

bind "tcp://0.0.0.0:#{port}?backlog=#{backlog}"

activate_control_app
