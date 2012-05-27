
# Public module containing Date, Error and Version types.
module PartialDate

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
      Bits.get_date(@bits)
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
        @bits = Bits.set_date(@bits, value)
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

      if value.is_a?(Integer) && (value <= 9999 && value > 0) 
        @bits = Bits.set_year(@bits, value)
      else
        raise PartialDateError, "Year must be an integer between 1 and 9999"
      end
    end

    # Public: Get the year from a partial date.
    def year
      Bits.get_year(@bits)
    end

    # Public: Set the month of a partial date.
    def month=(value)

      raise PartialDateError, "A year must be set before a month" if year == 0

      value = 0 if value.nil?

      if value.is_a?(String) 
        if value =~ /\A\d{1,2}\z/ 
          value = value.to_i
        else
          raise PartialDateError, "Month must be a valid one or two digit string or integer between 1 and 12"
        end
      end

      if value.is_a?(Integer) && (value <= 12 && value >= 0)
        @bits = Bits.set_month(@bits, value)
      else
        raise PartialDateError, "Month must an be integer between 1 and 12"
      end
    end

    # Public: Get the month from a partial date.
    def month
      Bits.get_month(@bits)
    end


    # Public: Set the day portion of a partial date. Day is optional so zero, 
    # nil and empty strings are allowed.
    def day=(value)

      raise PartialDateError, "A year and month must be set before a day" if year == 0 && month == 0

      value = 0 if value.nil?

      if value.is_a?(String) 
        if value =~ /\A\d{1,2}\z/
          value = value.to_i
        else
          raise PartialDateError, "Day must be a valid one or two digit string or integer between 1 and 31"
        end
      end

      if value.is_a?(Integer) && (value >= 0 && value <= 31)
        begin
          date = ::Date.civil(self.year, self.month, value) if value > 0
          @bits = Bits.set_day(@bits, value)
        rescue 
          raise PartialDateError, "Day must be a valid day for the given month"
        end
      else
        raise PartialDateError, "Day must be an integer between 1 and 31"
      end
    end

    # Public: Get the day from a partial date.
    def day
      Bits.get_day(@bits)
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
      if self.year > 0
        result = self.year.to_s 
        result = result + "-" + self.month.to_s if self.month > 0
        result = result + "-" + self.day.to_s if self.day > 0
        return result
      else
        return ""
      end
    end

    # Public: Spaceship operator for date comparisons.
    #
    # Returns -1, 1, or 0
    def <=>(other_date)
      self.value <=> other_date.value
    end
  end
end
