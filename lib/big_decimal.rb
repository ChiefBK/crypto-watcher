class BigDecimal
  def significand_str
    to_s.split('e')[0]
  end

  def dec_str
    to_s('F')
  end
end