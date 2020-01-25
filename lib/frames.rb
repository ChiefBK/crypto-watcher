# frozen_string_literal: true

# Methods and Classes related to Frames
module Frames
  # A class which represents what is shown on the LED display
  class Frame
    def initialize(listing, net_percentage, duration)
      @rank = listing.rank
      @symbol = listing.symbol
      @price = listing.price
      @currency_code = listing.currency_code
      @net_percentage = net_percentage
      @duration = duration
    end

    def price
      @price.to_s[0...8]
    end

    def percentage
      @net_percentage.to_s[0...4]
    end

    def duration
      @duration.to_s
    end

    def rank
      @rank.to_s.ljust(4)
    end

    def symbol
      @symbol.to_s.ljust(4)
    end

    def currency_code
      @currency_code.to_s.ljust(price.size)
    end

    def to_s
      "#{rank} #{price} #{percentage}\n"\
    "#{symbol} #{currency_code} #{@duration}\n"
    end
  end

  class << self
    def create_frames(listings)
      new_frames = []

      listings.each do |listing|
        frames_for_listing = generate_frames_for_listing(listing)
        new_frames += frames_for_listing
      end

      new_frames
    end

    private

    def generate_frames_for_listing(listing)
      frames = []
      frames_for_listing = [[:percent_change_1h, '1h'], [:percent_change_24h, '24h'], [:percent_change_7d, '7d']]

      frames_for_listing.each do |f|
        frames.push(Frame.new(listing, listing.send(f[0]), f[1]))
      end

      frames
    end
  end


end