# frozen_string_literal: true

# For handling HTTP requests
module Requests

  # Models a HTTP request
  class Request
    def initialize(socket)
      @socket = socket
    end

    def raw_request
      @raw_request ||= parse_request
    end

    def route
      @route ||= parse_route
    end

    def is_websocket_request
      raw_request.match(/^Sec-WebSocket-Key: (\S+)/)
    end

    private

    def parse_request
      http_request = ''
      while (line = @socket.gets) && (line != "\r\n")
        http_request += line
      end
      http_request
    end

    def parse_route
      first_line = raw_request.lines.first
      first_line.match(/^(\S+) (\S+) (\S+)/)[2]
    end
  end
end
