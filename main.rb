# frozen_string_literal: true

puts 'STARTING'

require_relative './bootstrap'

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

loop do

  socket = server.accept
  STDERR.puts "Incoming Request"

  Thread.new do
    Websockets.accept_and_upgrade_connection(socket)

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
  end
end

frame_fetcher_thread.join

puts 'THE END'
