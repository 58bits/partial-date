
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
      @data = [0,0,0,0]
      yield self if block_given?
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
      get_value(0)
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
        set_value(0, value)
      else
        raise PartialDateError, "Date value must be an integer betwen 10000 and 99991231"
      end
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
        set_value(1, value)
      else
        raise PartialDateError, "Year must be an integer between 1 and 9999"
      end
    end

    # Public: Get the year from a partial date.
    def year
      get_value(1)
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
        set_value(2, value)
      else
        raise PartialDateError, "Month must an be integer between 1 and 12"
      end
    end

    # Public: Get the month from a partial date.
    def month
      get_value(2)
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
          #@value  = (self.value - self.day + value)
          set_value(3, value)
        rescue 
          raise PartialDateError, "Day must be a valid day for the given month"
        end
      else
        raise PartialDateError, "Day must be an integer between 1 and 31"
      end
    end

    # Public: Get the day from a partial date.
    def day
      #self.value > 0 ? self.value - (self.value / 100).abs * 100 : 0
      get_value(3)
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


    private

    # Internal: Retreive a value from the array backing store.
    #
    # Returns an integer value for partial date, year, month or day.
    def get_value(element)
      @data[element]
    end

    # Internal: Set a value in the array backing store - either the
    # complete date value (from load or value accessors), or a year, 
    # month, or day value after which the partial date will be recomputed.
    #
    # Returns nothing
    def set_value(element, value)
      case element
      when 0
        @data[1] = (value / 10000).abs 
        @data[2] = ((value - (value / 10000).abs * 10000) / 100).abs
        @data[3] = value - (value / 100).abs * 100 
      when 1
        @data[0] = @data[0] - (self.year * 10000) + (value * 10000)
      when 2
        @data[0] = @data[0] - (self.month * 100) + (value * 100)
      when 3
        @data[0] = @data[0] - self.day + value
      end 

      # Important - update the old element value _after_ @data[0] 
      # has been recalculated above.
      @data[element] = value
    end
  end
end
