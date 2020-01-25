# frozen_string_literal: true

puts 'STARTING'

require_relative './bootstrap'

frames_mutex = Mutex.new
frames = []

def fetch_data
  puts 'fetching frames...'
  listings = Listings.fetch
  frames = Frames.create_frames(listings)

  puts "fetched #{listings.size} listings - created #{frames.size} frames"
  frames
end

frame_fetcher_thread = Thread.new do
  loop do
    frames_mutex.lock
    frames = fetch_data
    puts 'frames updated'
    frames_mutex.unlock
    sleep ENV['FETCH_DURATION'].to_i # fetch every 5 minutes
  end
end

frame_display_thread = Thread.new do
  loop do
    frames_mutex.lock
    frames.each do |frame|
      puts frame
      sleep ENV['FRAME_DURATION'].to_i
    end
    frames_mutex.unlock
    sleep 1 # give other thread some time to lock mutex
  end
end

frame_fetcher_thread.join
frame_display_thread.join

puts 'THE END'


