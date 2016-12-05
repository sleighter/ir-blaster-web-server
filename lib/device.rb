class Device

  class << self
    def all
      DB.db.keys(devices_db_key).to_json
    end

    def config(device_id)
      DB.db.get(device_config_db_key(device_id))
    end

    def discover
      ::BroadlinkRM::Device.discover.to_hash.tap{ |h|
        h[:mac] = h[:mac].map{ |byte| byte.to_s(16).rjust(2, "0") }.join(":")
        h[:device_id] = normalize_mac(h[:mac])
      }
    end

    def create!(params)
      mac = params[:mac]
      key = device_config_db_key(normalize_mac(mac))
      DB.db.set(key, params.to_json)
      new(mac)
    end

    def device_config_db_key(device_id)
      "device_#{device_id}"
    end

    def devices_db_key
      "device_*"
    end

    def normalize_mac(mac)
      if mac.is_a?(Array)
        mac.map{ |e| e.is_a?(Integer) ? e.to_s(16).rjust(2,"0") : e }.join("")
      elsif mac.is_a?(String)
        mac.gsub(":", "")
      else
        mac.to_s
      end
    end

    def mac_to_byte_array(mac)
      normalize_mac(mac).scan(/.{2}/).map{|byte| byte.to_i(16)}
    end
  end

  def initialize(device_id)
    @config = JSON.parse(DB.db.get(self.class.device_config_db_key(device_id)))
    @device_id, @mac, @host, @port = self.class.normalize_mac(@config['mac']), @config['mac'], @config['host'], @config['port']
    @broadlink_device = ::BroadlinkRM::Device.new(
      host: @config['host'],
      port: @config['port'],
      mac:  self.class.mac_to_byte_array(@config['mac']))
    @broadlink_device.auth
  end

  def commands
    DB.db.keys(device_commands_db_key)
  end

  def config
    @config
  end

  def learn(cmd_name, time_to_wait_seconds)
    if time_to_wait_seconds > 30
      raise "time_to_wait should not be larger than 30 seconds. We wouldn't want to lock up the device"
    end
    @broadlink_device.enter_learning
    sleep(time_to_wait_seconds % 31)
    cmd = @broadlink_device.check_data
    DB.db.set(device_command_db_key(cmd_name), cmd)
  end

  def send_command(cmd_name)
    command = JSON.parse(DB.db.get(device_command_db_key(cmd_name)))
    @broadlink_device.send_data(command)
  end

  def device_db_key
    self.class.device_config_db_key(@mac)
  end

  def device_commands_db_key
    "cmd_#{@device_id}_*"
  end

  def device_command_db_key(cmd_name)
    "cmd_#{@device_id}_#{cmd_name.downcase}"
  end
end
