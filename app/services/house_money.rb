# frozen_string_literal: true

class HouseMoney
  def self.cents(value)
    text = value.to_s.strip
    raise ArgumentError, 'Enter a positive dollar amount with at most two decimal places' unless
      text.match?(/\A\d+(?:\.\d{1,2})?\z/)

    (BigDecimal(text) * 100).to_i
  end
end
