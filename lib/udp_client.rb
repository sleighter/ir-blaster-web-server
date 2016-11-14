require 'socket'

class UDPClient
  def initialize(host, port)
    @config={}
    @config[:host] = host
    @config[:port] = port
  end

  # Message should be an array of integers representing the byte values to send
  def post(message)
    self.socket.send(message.pack("C*"), 0)
  end

  def socket
    @socket ||= build_socket
  end

  def build_socket
    s = UDPSocket.new()
    s.connect(@config[:host], @config[:port])
    return s
  end
end
