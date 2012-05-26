require 'partial-date/version'
require 'partial-date/error'

# Public: A module for handling partial date storage. Partial dates are stored
# as an 8 digit integer with optional month and day values.
#
# Examples
#   
#   p_date = 20100501
#   # => 20100501
#
#   p_year = 2010
#   puts p_date
#   # => 20100000
module PartialDate

  # Public: Get the date in partial_date format.
  #
  # Examples
  #   myobject.p_year = "2010"
  #   myobject.p_date
  #   # => 20100000
  #
  # Returns an integer representation of a partial date.
  def p_date
    #puts "Partial date is now read as #{@p_date}"
    @p_date ||= 0
  end

  # Public: Sets the year portion of a partial date.
  #
  # value - The string or integer value for a year.
  #
  # Examples
  #   myobject.p_year = "2000"
  #   myobject.p_year = 2000
  #   myobject.p_date
  #   # => 20000000
  #
  # Returns nothing  
  def p_year=(value)

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
      @p_date = (self.p_date - self.p_year) * 10000 + (value * 10000) 
    else
      raise PartialDateError, "Year must be an integer between 1 and 9999"
    end
  end

  # Public: Get the year from a partial date.
  def p_year
    self.p_date > 9999 ? (self.p_date / 10000).abs : 0
  end

  # Public: Set the month of a partial date.
  def p_month=(value)
    value = 0 if value.nil?

    if value.is_a?(String) 
      if value =~ /\A\d{1,2}\z/ 
        value = value.to_i
      else
        raise PartialDateError, "Month must be a valid one or two digit string or integer between 1 and 12"
      end
    end

    if value.is_a?(Integer) && (value <= 12 && value >= 0)
      @p_date  = self.p_date - (self.p_month * 100) + (value * 100)
    else
        raise PartialDateError, "Month must be integer between 1 and 12"
    end
  end

  # Public: Get the month from a partial date.
  def p_month
    self.p_date > 99 ? ((self.p_date - (self.p_date / 10000).abs * 10000) / 100).abs : 0
  end


  # Public: Set the day portion of a partial date. Day is optional so zero, 
  # nil and empty strings are allowed.
  def p_day=(value)
    is_valid = true
    value = 0 if value.nil?

    if value.is_a?(String) 
      if value =~ /\A\d{1,2}\z/ || value.blank?
        value = value.to_i
      else
        is_valid = false
        @day_error = "must be a one or two digit number"
      end
    end

    unless is_valid && value.is_a?(Integer) && value < 32
      is_valid = false
      @day_error = "must be a valid day"
    end

    if is_valid
      @p_date  = (self.p_date - self.p_day + value)
    end
  end

  # Public: Get the day from a partial date.
  def p_day
    self.p_date > 0 ? self.p_date - (self.p_date / 100).abs * 100 : 0
  end
end
