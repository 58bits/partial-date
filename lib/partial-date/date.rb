
# Public module containing Date, Error and Version types.
module PartialDate
  
  # Key:
  #   The first 5 bits are the day (max 31)
  #   The next 4 bits are the month (max 12)
  #   The next 14 bits are the year (max 9999)
  #   The most significant bit (MSB) is a 1 bit sign bit (for negative years).

  DAY_MASK    = 0b000000000000000000011111
  MONTH_MASK  = 0b000000000000000111100000
  YEAR_MASK   = 0b011111111111111000000000
  SIGN_MASK   = 0b100000000000000000000000

  ZERO_SIGN_MASK  = 0b011111111111111111111111
  ZERO_YEAR_MASK  = 0b100000000000000111111111
  ZERO_MONTH_MASK = 0b111111111111111000011111
  ZERO_DAY_MASK   = 0b111111111111111111000000

  SIGN_SHIFT = 23
  YEAR_SHIFT = 9
  MONTH_SHIFT = 5

  
  # Public: A class for handling partial date storage. Partial dates are stored
  # as an 8 digit integer with optional month and day values.
  #
  # Examples
  #   
  #   date = PartialDate::Date.new
  #   date.year = 2012
  #   date.month = 12
  #   date.day = 1
  #
  #   date = PartialDate::Date.new {|d| d.year = 2012; d.month = 12; d.day = 1}
  #
  #   date = PartialDate::Date.new {|d| d.year = 2012 }
  #
  class Date
    include Comparable

    # Public: Readonly accessor for the raw bit integer date value.
    # This allows us to perform our <=> comparions against this 
    # value instead of comparing year, month and day, or date.value
    # which requires multiplication to calculate.
    #
    # Returns the single Integer backing store with 'bits' flipped 
    # for year, month and day.
    attr_reader :bits

    # Public: Create a new partial date class from a block of integers
    # or strings.
    #
    # Examples
    #
    #   # From integers
    #   date = PartialDate::Date.new {|d| d.year = 2012; d.month = 12; d.day = 1}
    #   date.value
    #   # => 20121201
    #
    #   # From strings
    #   date = PartialDate::Date.new {|d| d.year = "2012"; d.month = "12"; d.day = "1"}
    #   date.value
    #   # => 20121201
    #
    # Returns a date object.
    def initialize
      @bits = 0
      yield self if block_given?
    end

    # Public: Loads an 8 digit date value into a date object. Can be used 
    # when rehydrating a date object from a persisted partial date value.
    #
    # value - an 8 digit value in partial date format.
    #
    # Examples
    #
    #   date = PartialDate::Date.load 201212201
    #   date.value
    #   # => 20120000
    #   date.year
    #   # => 2012
    #   date.month
    #   # => 12
    #   date.day
    #   # => 0
    #
    # Returns date object
    def self.load(value)
      PartialDate::Date.new {|d| d.value = value}
    end


    # Public: Get the integer date value in partial date format.
    #
    # Examples
    #
    #   date.year = "2012"
    #   date.value
    #   # => 20120000
    #
    # Returns an integer representation of a partial date.
    def value
      self.class.get_date(@bits)
    end

    # Public: Set a date value using an interger in partial date format.
    #
    # Examples
    #
    #   date.value = 20121200
    #
    # Returns nothing  
    def value=(value)
      if value.is_a?(Integer) && (value >= 10000 && value <= 99991231)
        @bits = self.class.set_date(@bits, value)
      else
        raise PartialDateError, "Date value must be an integer betwen 10000 and 99991231"
      end
    end


    # Public: Sets the year portion of a partial date.
    #
    # value - The string or integer value for a year.
    #
    # Examples
    #   date.year = "2000"
    #   date.value
    #   # => 20000000
    #
    # Returns nothing  
    def year=(value)

      if value.nil?
        raise PartialDateError, "Year cannot be nil"
      end

      if value.is_a?(String) 
        if value =~ /\A\d{4}\z/
          value = value.to_i
        else
          raise PartialDateError, "Year must be a valid four digit string or integer between 1 and 9999"
        end
      end

      if value.is_a?(Integer) && (value <= 9999) 
        @bits = self.class.set_year(@bits, value)
      else
        raise PartialDateError, "Year must be an integer less than 9999"
      end
    end

    # Public: Get the year from a partial date.
    def year
      self.class.get_year(@bits)
    end

    # Public: Set the month of a partial date.
    def month=(value)

      raise PartialDateError, "A year must be set before a month" if year == 0

      value = 0 if value.nil?

      if value.is_a?(String) 
        if value =~ /\A\d{1,2}\z/ 
          value = value.to_i
        else
          raise PartialDateError, "Month must be a valid one or two digit string or integer between 0 and 12"
        end
      end

      if value.is_a?(Integer) && (value <= 12 && value >= 0)
        @bits = self.class.set_month(@bits, value)
        @bits = self.class.set_day(@bits, 0) if value == 0
      else
        raise PartialDateError, "Month must an be integer between 0 and 12"
      end
    end

    # Public: Get the month from a partial date.
    def month
      self.class.get_month(@bits)
    end


    # Public: Set the day portion of a partial date. Day is optional so zero, 
    # nil and empty strings are allowed.
    def day=(value)

      raise PartialDateError, "A month must be set before a day" if month == 0

      value = 0 if value.nil?

      if value.is_a?(String) 
        if value =~ /\A\d{1,2}\z/
          value = value.to_i
        else
          raise PartialDateError, "Day must be a valid one or two digit string or integer between 0 and 31"
        end
      end

      if value.is_a?(Integer) && (value >= 0 && value <= 31)
        begin
          date = ::Date.civil(self.year, self.month, value) if value > 0
          @bits = self.class.set_day(@bits, value)
        rescue 
          raise PartialDateError, "Day must be a valid day for the given month"
        end
      else
        raise PartialDateError, "Day must be an integer between 0 and 31"
      end
    end

    # Public: Get the day from a partial date.
    def day
      self.class.get_day(@bits)
    end

    # Public: Returns a formatted string representation of the partial date.
    #
    # Examples
    #   
    #   date = PartialDate::Date.new {|d| d.year = 2012, d.month = 12, d.day = 31}
    #   date.to_s
    #   # => "2012-12-31"
    #
    # Returns string representation of date.
    def to_s
      if year > 0
        result = year.to_s.rjust(4, '0') 
        result = result + "-" + month.to_s.rjust(2, '0') if month > 0
        result = result + "-" + day.to_s.rjust(2, '0') if day > 0
        return result
      else
        return ""
      end
    end

    # Public: Spaceship operator for date comparisons. Comparisons are
    # made using the bit containing backing store. However the sign bit 
    # is in MSB - so we need to left shift both values by 1 first.
    #
    # Returns -1, 1, or 0
    def <=>(other_date)
        (@bits << 1) <=> (other_date.bits << 1)
    end


    def self.get_date(register)
        date = (get_year(register) * 10000).abs + (get_month(register) * 100) + get_day(register) 
        if get_sign(register) == 1
          date * -1
        else
          date
        end
    end

    def self.set_date(register, value)
        register = set_sign(register, 1) if value < 0
        register = set_year(register, (value.abs / 10000).abs)
        register = set_month(register, ((value - (value / 10000).abs * 10000) / 100).abs)
        register = set_day(register, value - (value / 100).abs * 100)
    end

    def self.get_sign(register)
      (register & SIGN_MASK) >> SIGN_SHIFT
    end

    def self.set_sign(register, value)
      register = (register & ZERO_SIGN_MASK) | (value << SIGN_SHIFT)
    end

    def self.get_year(register)
      year = (register & YEAR_MASK) >> YEAR_SHIFT
      if get_sign(register) == 1 
        year * -1
      else
        year
      end
    end

    def self.set_year(register, value)
      register = set_sign(register, 1) if value < 0
      register = (register & ZERO_YEAR_MASK) | (value.abs << YEAR_SHIFT)
    end

    def self.get_month(register)
      (register & MONTH_MASK) >> MONTH_SHIFT
    end

    def self.set_month(register, value)
      register = (register & ZERO_MONTH_MASK) | (value << MONTH_SHIFT)
    end

    def self.get_day(register)
      register & DAY_MASK
    end

    def self.set_day(register, value)
      register = (register & ZERO_DAY_MASK) | value
    end

  end
end
