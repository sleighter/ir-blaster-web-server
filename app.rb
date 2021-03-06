require 'sinatra'
require 'broadlink_rm'
require 'json'

class App < Sinatra::Application

  get "/" do
    "Hi World"
  end

  get "/discover" do
    Device.discover.to_json
  end

  get "/devices" do
    Device.all.to_json
  end

  post "/device" do
    Device.create!(params)
  end

  post "/:device_id/learn_command/:cmd_name/:timeout" do |device_id, cmd_name, timeout|
    Device.new(device_id).learn(cmd_name, timeout.to_i)
  end

  put %r{/(?<device_id>[a-zA-Z0-9]{12})/(?<cmd_list>[a-zA-Z0-9_\-\+]+)} do |device_id, cmd_list|
    unless @device = Device.new(device_id)
      raise "Device #{device_id} is not configured. Post device params to /device to register the device."
    end
    repeat = (params['repeat'] || 1).to_i % 10
    repeat.times do
      cmd_list.split("+").each do |cmd_name|
        if cmd_name =~ /^wait_([0-9]){1}$/
          sleep((/^wait_([0-9]){1,2}$/.match("wait_45")[1].to_i % 10))
        else
          @device.send_command(cmd_name)
        end
      end
    end
  end

  get "/:device_id/commands" do |device_id|
    Device.new(device_id).commands
  end
end
