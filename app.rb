require 'sinatra'
require 'broadlink_rm'
require 'json'

class App < Sinatra::Application

  get "/" do
    "Hi World"
  end

  get "/discover" do
    ::BroadlinkRM::Device.discover.to_hash.tap{|h| h[:mac] = h[:mac].map{|byte| byte.to_s(16)}.join(":")}.to_json
  end

  get "/devices" do
    DB.db.keys("device_*").to_json
  end

  post "/device" do
    DB.db.set(device_db_key(params['mac']), params.to_json)
  end

  post "/:device/learn_command/:cmd_name/:timeout" do |device, cmd_name, timeout|
    device_config = JSON.parse(DB.db.get(device_db_key(device)))
    mac = device_config['mac'].split(":").map{|byte| byte.to_i(16)}
    device = ::BroadlinkRM::Device.new(host: device_config['host'], port: device_config['port'], mac: mac)
    device.auth
    device.enter_learning
    sleep(timeout.to_i % 31)
    cmd = device.check_data
    DB.db.set(cmd_name, cmd)
  end

  get "/:device/:cmd_name" do |device,cmd_name|
    command = JSON.parse(DB.db.get(cmd_name))
    device_config = JSON.parse(DB.db.get(device_db_key(device)))
    mac = device_config['mac'].split(":").map{|byte| byte.to_i(16)}
    d = ::BroadlinkRM::Device.new(host: device_config['host'], port: device_config['port'], mac: mac)
    d.auth
    d.send_data(command)
  end

  def device_db_key(mac)
    "device_#{mac.gsub(':', "").downcase}"
  end
end
