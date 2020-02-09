# frozen_string_literal: true

puts 'STARTING'

require_relative './bootstrap'

FILE_EXTENSION_CONTENT_TYPES = {
  '.js' => 'application/javascript',
  '.css' => 'text/css',
  '.html' => 'text/html'
}

screens_mutex = Mutex.new
screens = []

def fetch_data
  puts 'fetching frames...'
  listings = Listings.fetch
  screens = Screens.create_screens(listings)

  puts "fetched #{listings.size} listings - created #{screens.size} frames"
  screens
end

frame_fetcher_thread = Thread.new do
  loop do
    screens_mutex.lock
    screens = fetch_data
    puts 'frames updated'
    screens_mutex.unlock
    sleep ENV['FETCH_DURATION'].to_i # fetch every so many seconds
  end
end

server = TCPServer.new('localhost', 2345)

def get_raw_request(socket)
  http_request = ""
  while (line = socket.gets) && (line != "\r\n")
    http_request += line
  end
  http_request
end

def get_route(raw_request)
  first_line = raw_request.lines.first
  first_line.match(/^(\S+) (\S+) (\S+)/)[2]
end

def send_response_contents(content_str, content_type, socket)
  socket.write <<~RESPONSE
    HTTP/1.1 200 OK
    Content-Type: #{content_type}; charset=utf-8
    Date: #{DateTime.now.rfc2822}
    Content-Length: #{content_str.size}

    #{content_str}
  RESPONSE
end

loop do
  connection = server.accept
  STDERR.puts "Incoming Request"

  Thread.start(connection) do |socket|
    raw_request = get_raw_request(socket)

    if Websockets.is_websocket_request(raw_request)
      websocket_key = Websockets.get_websocket_key(raw_request)
      Websockets.upgrade_connection(websocket_key, socket)

      # Start sending screens to client
      screen_index = 0
      loop do
        screens_mutex.lock
        screen_to_send = screens[screen_index]
        Websockets.send_frame(screen_to_send.to_json, socket)
        screens_mutex.unlock


        screen_index += 1
        screen_index = 0 if screen_index > screens.size
        sleep ENV['FRAME_DURATION'].to_i
      end
    else
      route = get_route(raw_request)
      STDERR.puts "ROUTE - #{route}"

      case route
      when '/'
        file = File.open('./client/client.html')
        STDERR.puts "FILE - #{file.path}"
        file_contents = file.read
        file.close

        send_response_contents(file_contents, 'text/html', socket)
      when /\/public\/\S+/
        file = File.open(".#{route}")
        file_extension = File.extname(file.path)
        content_type = FILE_EXTENSION_CONTENT_TYPES[file_extension]

        send_response_contents(file.read, content_type, socket)
      else
        STDERR.puts "TODO - Send 404"
      end
    end

    socket.close
  end
end

# frame_fetcher_thread.join

puts 'THE END'
