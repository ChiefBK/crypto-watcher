# frozen_string_literal: true

# A class which represents what is shown on the LED display
class Frame
  attr_reader :symbol

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