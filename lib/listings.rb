# frozen_string_literal: true

# Methods and Classes related to Listings
module Listings
  def self.fetch
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

    response['data'].each_with_index.map { |obj, i| Listing.new(i + 1, obj) }
  end

  # A class whith represents one listing from coinmarketcap
  class Listing
    attr_reader :id, :name, :symbol, :rank

    def initialize(rank, obj)
      @rank = rank
      @id = obj['id']
      @name = obj['name']
      @symbol = obj['symbol']
      @quote = obj['quote']
      @source_obj = obj
    end

    def price
      @price ||= @quote['USD']['price']
    end

    def volume_24_hours
      @volume_24_hours ||= @quote['USD']['volume_24h']
    end

    def percent_change_1h
      @percent_change_1h ||= @quote['USD']['percent_change_1h']
    end

    def percent_change_24h
      @percent_change_24h ||= @quote['USD']['percent_change_24h']
    end

    def percent_change_7d
      @percent_change_7d ||= @quote['USD']['percent_change_7d']
    end

    def market_cap
      @market_cap ||= @quote['USD']['market_cap']
    end

    def currency_code
      'USD'
    end
  end
end