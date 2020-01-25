# frozen_string_literal: true

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