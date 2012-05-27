module PartialDate

  class Bits

    # Key:
    #   The firt 5 bits are the day (max 31)
    #   The next 4 bits are the month (max 12)
    #   The topmost/leftmost 14 bits are the year (max 9999)

    DAY_MASK = 0b00000000000000000011111
    MONTH_MASK = 0b00000000000000111100000
    YEAR_MASK = 0b11111111111111000000000

    ZERO_YEAR_MASK = 0b00000000000000111111111
    ZERO_MONTH_MASK = 0b11111111111111000011111
    ZERO_DAY_MASK = 0b111111111111111111000000

    def self.get_date(register)
        (get_year(register) * 10000) + (get_month(register) * 100) + get_day(register)
    end

    def self.set_date(register, value)
        register = set_year(register, (value / 10000).abs)
        register = set_month(register, ((value - (value / 10000).abs * 10000) / 100).abs)
        register = set_day(register, value - (value / 100).abs * 100)
    end

    def self.get_year(register)
      (register & YEAR_MASK) >> 9
    end

    def self.set_year(register, value)
      register = (register & ZERO_YEAR_MASK) | (value << 9)
    end

    def self.get_month(register)
      (register & MONTH_MASK) >> 5
    end

    def self.set_month(register, value)
      register = (register & ZERO_MONTH_MASK) | (value << 5)
    end

    def self.get_day(register)
      register & DAY_MASK
    end

    def self.set_day(register, value)
      register = (register & ZERO_DAY_MASK) | value
    end
  end
end
