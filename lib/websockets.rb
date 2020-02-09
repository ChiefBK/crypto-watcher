module Websockets
  class << self
    def get_websocket_key(raw_http_request)
      if (matches = raw_http_request.match(/^Sec-WebSocket-Key: (\S+)/))
        websocket_key = matches[1]
        websocket_key
      else
        nil
      end
    end

    def upgrade_connection(websocket_key, socket)
      response_key = Digest::SHA1.base64digest([websocket_key, "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"].join)
      STDERR.puts "Responding to handshake with key: #{ response_key }"

      socket.write <<~RESPONSE
        HTTP/1.1 101 Switching Protocols
        Upgrade: websocket
        Connection: Upgrade
        Sec-WebSocket-Accept: #{ response_key }

      RESPONSE
    end

    def send_frame(payload_str, socket)
      socket.write create_frame(payload_str)
    end

    private

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
  end
end
