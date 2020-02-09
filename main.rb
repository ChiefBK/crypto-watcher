# frozen_string_literal: true

puts 'STARTING'

require_relative './bootstrap'



screens_mutex = Mutex.new # so 'screens' variable can't be written and read at the same time
screens = []

def fetch_data
  puts 'fetching frames...'
  listings = Listings.fetch

  # set global 'screens' variable
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

loop do
  connection = server.accept

  Thread.start(connection) do |socket|
    STDERR.puts "Handling request from: #{socket.addr(:hostname)[2]}"
    request = Requests::Request.new(socket)
    raw_request = request.raw_request

    if request.is_websocket_request
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
      route = request.route

      case route
      when '/'
        Responses.send_ok_response('./client/client.html', socket)
      when /\/public\/\S+/
        file_path = ".#{route}"
        Responses.send_ok_response(file_path, socket)
      else
        Responses.send_not_found_response(socket)
      end
    end

    socket.close
  end
end

frame_fetcher_thread.join

puts 'THE END'
