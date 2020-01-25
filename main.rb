# frozen_string_literal: true

puts 'STARTING'

require_relative './bootstrap'
require 'httparty'
require 'json'

def fetch_listings
  response = HTTParty.get('https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest',
    headers: {
      'Accept' => 'application/json',
      'X-CMC_PRO_API_KEY' => ENV['CMC_PRO_API_KEY']
    },
    :query => {
      start: 1,
      limit: 10,
      convert: 'USD'
    }
  )

  response['data'].each_with_index.map { |obj, i| Listing.new(i+1, obj) }
end

def generate_frames(listing)
  frames = []
  frames_for_listing = [[:percent_change_1h, '1h'], [:percent_change_24h, '24h'], [:percent_change_7d, '7d']]

  frames_for_listing.each do |f|
    frames.push(Frame.new(listing, listing.send(f[0]), f[1]))
  end

  frames
end

def fetch_frames
  puts 'fetching frames...'
  new_frames = []
  listings = fetch_listings

  listings.each do |listing|
    frames_for_listing = generate_frames(listing)
    new_frames += frames_for_listing
  end

  puts "fetched #{listings.size} listings - created #{new_frames.size} frames"
  new_frames
end

def update_frames
  fetch_frames
end

frames_mutex = Mutex.new
frames = []

frame_fetcher_thread = Thread.new do
  loop do
    frames_mutex.lock
    frames = update_frames
    puts 'frames updated'
    frames_mutex.unlock
    sleep ENV['FETCH_DURATION'] # fetch every 5 minutes
  end
end

frame_display_thread = Thread.new do
  loop do
    frames_mutex.lock
    frames.each do |frame|
      puts frame
      sleep ENV['FRAME_DURATION']
    end
    frames_mutex.unlock
    sleep 1 # give other thread some time to lock mutex
  end
end

frame_fetcher_thread.join
frame_display_thread.join

puts 'THE END'


