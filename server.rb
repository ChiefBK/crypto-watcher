# frozen_string_literal: true

# GUIDE - https://www.honeybadger.io/blog/building-a-simple-websockets-server-from-scratch-in-ruby/
# WEBSOCKETS SPEC - https://tools.ietf.org/html/rfc6455#section-5

require 'socket'
require 'digest/sha1'

def create_frame(payload_str)
  fin = 0b10000000 # does not have continuation frame
  is_text_frame = 0b00000001 # payload is text
  first_byte = is_text_frame | fin

  if payload_str.size <= 125
    second_byte = payload_str.size
    output = [first_byte, second_byte, payload_str]
    frame = output.pack("CCA#{payload_str.size}")
  elsif payload_str.size <= 65_535
    second_byte = 0b01111110
    output = [first_byte, second_byte, payload_str.size, payload_str]
    frame = output.pack("CCnA#{payload_str.size}") # use 16 bit unsigned big endian byte order for length
  else
    second_byte = 0b01111111
    output = [first_byte, second_byte, payload_str.size, payload_str]
    frame = output.pack("CCS>A#{payload_str.size}") # use 64 bit unsigned big endian byte order for length
  end

  frame
end

server = TCPServer.new('localhost', 2345)

loop do

  # Wait for a connection
  socket = server.accept
  STDERR.puts "Incoming Request"
  STDERR.puts ""

  # Read the HTTP request. We know it's finished when we see a line with nothing but \r\n
  http_request = ""
  while (line = socket.gets) && (line != "\r\n")
    http_request += line
  end

  # Grab the security key from the headers. If one isn't present, close the connection.
  if (matches = http_request.match(/^Sec-WebSocket-Key: (\S+)/))
    websocket_key = matches[1]
    STDERR.puts "Websocket handshake detected with key: #{ websocket_key }"
  else
    STDERR.puts "Aborting non-websocket connection"
    socket.close
    next
  end


  response_key = Digest::SHA1.base64digest([websocket_key, "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"].join)
  STDERR.puts "Responding to handshake with key: #{ response_key }"

  socket.write <<-eos
HTTP/1.1 101 Switching Protocols
Upgrade: websocket
Connection: Upgrade
Sec-WebSocket-Accept: #{ response_key }

  eos

  STDERR.puts "Handshake completed. Starting to parse the websocket frame."

  big_frame = create_frame("test frame which is larger than 127 characters long this is one big one here folks ok lets just copy paste this then test frametest frametest frametest frametest frametest frametest frametest frame test frame which is larger than 127 characters long this is one big one here folks ok lets just copy paste this then test frametest frametest frametest frametest frametest frametest frametest frame")
  socket.write big_frame


  # first_byte = socket.getbyte
  #
  # STDERR.puts "got first byte"
  # fin = first_byte & 0b10000000
  # opcode = first_byte & 0b00001111
  #
  # raise "We don't support continuations" unless fin
  # raise "We only support opcode 1" unless opcode == 1
  #
  # second_byte = socket.getbyte
  # is_masked = second_byte & 0b10000000
  # payload_size = second_byte & 0b01111111
  #
  # raise "All incoming frames should be masked according to the websocket spec" unless is_masked
  # raise "We only support payloads < 126 bytes in length" unless payload_size < 126
  #
  # STDERR.puts "Payload size: #{ payload_size } bytes"
  #
  # mask = 4.times.map { socket.getbyte }
  # STDERR.puts "Got mask: #{ mask.inspect }"
  #
  # data = payload_size.times.map { socket.getbyte }
  # STDERR.puts "Got masked data: #{ data.inspect }"
  #
  # unmasked_data = data.each_with_index.map { |byte, i| byte ^ mask[i % 4] }
  # STDERR.puts "Unmasked the data: #{ unmasked_data.inspect }"
  #
  # STDERR.puts "Converted to a string: #{ unmasked_data.pack('C*').force_encoding('utf-8').inspect }"

  socket.close

end
