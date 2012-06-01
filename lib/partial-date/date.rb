
# Public module containing Date, Error and Version types.
module PartialDate
  
  # Key:
  #   The first 5 bits are the day (max 31)
  #   The next 4 bits are the month (max 12)
  #   The next 20 bits are the year (max 1048576)
  #   The most significant bit (MSB) is a 1 bit sign bit (for negative years).

  DAY_MASK    = 0b000000000000000000000000011111
  MONTH_MASK  = 0b000000000000000000000111100000
  YEAR_MASK   = 0b011111111111111111111000000000
  SIGN_MASK   = 0b100000000000000000000000000000

  ZERO_SIGN_MASK  = 0b011111111111111111111111111111
  ZERO_YEAR_MASK  = 0b100000000000000000000111111111
  ZERO_MONTH_MASK = 0b111111111111111111111000011111
  ZERO_DAY_MASK   = 0b111111111111111111111111000000

  SIGN_SHIFT = 29
  YEAR_SHIFT = 9
  MONTH_SHIFT = 5

  REMOVALS = /[\/\,\-\s]/

  # TODO: Implement i18n support detecting whether a load path has been set or not
  # and if not - setting it here to a default set of translations that match
  # the generally available tranlsations for localizing dates.
  #
  # https://github.com/svenfuchs/i18n/blob/master/lib/i18n/backend/base.rb
  # format = format.to_s.gsub(/%[aAbBp]/) do |match|
  #   case match
  #   when '%a' then I18n.t(:"date.abbr_day_names",                  :locale => locale, :format => format)[object.wday]
  #   when '%A' then I18n.t(:"date.day_names",                       :locale => locale, :format => format)[object.wday]
  #   when '%b' then I18n.t(:"date.abbr_month_names",                :locale => locale, :format => format)[object.mon]
  #   when '%B' then I18n.t(:"date.month_names",                     :locale => locale, :format => format)[object.mon]
  #   when '%p' then I18n.t(:"time.#{object.hour < 12 ? :am : :pm}", :locale => locale, :format => format) if object.respond_to? :hour
  #   end
  # end

  FORMATS = { :default => "%Y-%m-%d", :short => "%d %m %Y", :medium => "%d %b %Y", :long => "%d %B %Y", :number => "%Y%m%d",  }
  FORMAT_METHODS = { 
                      "%Y" => lambda { |d| (d.year != 0) ? d.year.to_s.rjust(4, '0') : ""},  
                      "%m" => lambda { |d| (d.month != 0) ? d.month.to_s.rjust(2, '0') : "" },
                      "%b" => lambda { |d| (d.month != 0) ? ABBR_MONTH_NAMES[d.month - 1] : "" },
                      "%B" => lambda { |d| (d.month != 0) ? MONTH_NAMES[d.month - 1] : "" },
                      "%d" => lambda { |d| (d.day != 0) ? d.day.to_s.rjust(2, '0') : "" },
                      "%e" => lambda { |d| (d.day != 0) ? d.day.to_s : "" }
                    }

                          
  MONTH_NAMES = %w[January, February, March, April, May, June, July, August, September, October, November, December]
  ABBR_MONTH_NAMES = %w[Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec]
  
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
      if value.is_a?(Integer) && (value >= -10485761231 && value <= 10485761231)
        @bits = self.class.set_date(@bits, value)
      else
         raise PartialDateError, "Date value must be an integer betwen -10485761231 and 10485761231"
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
      value = 0 if value.nil?

      if value.is_a?(String) 
        if value =~ /\A\-?\d{1,7}\z/
          value = value.to_i
        else
          raise YearError, "Year must be a valid string or integer from -1048576 to 1048576"
        end
      end

      if value.is_a?(Integer) && (value >= -1048576 && value <= 1048576) 
        @bits = self.class.set_year(@bits, value)
      else
        raise YearError, "Year must be an integer from -1048576 to 1048576"
      end
    end

    # Public: Get the year from a partial date.
    def year
      self.class.get_year(@bits)
    end

    # Public: Set the month of a partial date.
    def month=(value)
      value = 0 if value.nil?

      if value.is_a?(String) 
        if value =~ /\A\d{1,2}\z/ 
          value = value.to_i
        else
          raise MonthError, "Month must be a valid one or two digit string or integer between 0 and 12"
        end
      end

      if value.is_a?(Integer) && (value >= 0 && value <= 12)
        @bits = self.class.set_month(@bits, value)
        @bits = self.class.set_day(@bits, 0) if value == 0
      else
        raise MonthError, "Month must an be integer between 0 and 12"
      end
    end

    # Public: Get the month from a partial date.
    def month
      self.class.get_month(@bits)
    end


    # Public: Set the day portion of a partial date. Day is optional so zero, 
    # nil and empty strings are allowed.
    def day=(value)
      value = 0 if value.nil?

      raise DayError, "A month must be set before a day" if month == 0 && value !=0

      if value.is_a?(String) 
        if value =~ /\A\d{1,2}\z/
          value = value.to_i
        else
          raise DayError, "Day must be a valid one or two digit string or integer between 0 and 31"
        end
      end

      if value.is_a?(Integer) && (value >= 0 && value <= 31)
        begin
          date = ::Date.civil(self.year, self.month, value) if value > 0
          @bits = self.class.set_day(@bits, value)
        rescue 
          raise DayError, "Day must be a valid day for the given month"
        end
      else
        raise DayError, "Day must be an integer between 0 and 31"
      end
    end

    # Public: Get the day from a partial date.
    def day
      self.class.get_day(@bits)
    end

    # Public: Returns a formatted string representation of date. 
    # A subset of date formatters have been implemented including:
    # %Y - Year with century (can be negative, and will be padded 
    # to 4 digits at least)
    #             -0001, 0000, 1995, 2009, 14292, etc.
    # %m - Month of the year, zero-padded (01..12)
    # %B - The full month name ('January')
    # %b - The abbreviated month name ('Jan')
    # %d - Day of the month, zero-padded (01..31)
    # %e - Day of the month, blank-padded ( 1..31)
    # 
    # Examples
    #   
    #   date = PartialDate::Date.new {|d| d.year = 2012, d.month = 12, d.day = 31}
    #   date.to_s
    #   # => "2012-12-31"
    #
    # Returns string representation of date.
    def to_s(format = :default)
      format = FORMATS[format] if format.is_a?(Symbol)
      s = format.dup
      n = b = 0
      a = 1
      while n < s.length
        if s[n] == "%" && FORMAT_METHODS.include?(s[n..n+1])
          t = FORMAT_METHODS[s[n..n+1]].call( self ) 
          if t.length == 0  
            if n >= 0 && n < s.length - 2
              a = a + 1 if s[n+2] =~ REMOVALS
            else
              b = n - 1 if s[n-1] =~ REMOVALS
            end
          end
          s.slice!(b..n+a)
          s.insert(b, t)
          n = b = b + t.length 
          a = 1 
        else
          n = b += 1
        end
      end
      s
    end

    # Here for the moment for benchmark comparisons
    def old_to_s(format = :default)
      format = FORMATS[format] if format.is_a?(Symbol)

      result = format.dup
      FORMAT_METHODS.each_pair do |key, value|
        result.gsub!( key, value.call( self )) if result.include? key
      end

      # Remove any leading "/-," chars.
      # Remove double white spaces.
      # Remove any duplicate "/-," chars and replace with the single char.
      # Remove any trailing "/-," chars.
      # Anything else - you're on your own ;-)
      lead_trim = (year != 0 && format.lstrip.start_with?("%Y")) ? /\A[\/\,\s]+/ : /\A[\/\,\-\s]+/ 
        result = result.gsub(lead_trim, '').gsub(/\s\s/, ' ').gsub(/[\/\-\,]([\/\-\,])/, '\1').gsub(/[\/\,\-\s]+\z/, '')
    end

    # Public: Spaceship operator for date comparisons. Comparisons 
    # are made by cascading down from year, to month to day. This
    # should be faster than passing to self.value <=> other_date.value
    # since the integer value attribute requires multiplication to
    # calculate.
    #
    # Returns -1, 1, or 0
    def <=>(other_date)
      if self.year < other_date.year
        return -1
      elsif self.year > other_date.year
        return 1
      else
        if self.month < other_date.month
          return -1
        elsif
          self.month > other_date.month
          return 1
        else
          if self.day < other_date.day
            return -1
          elsif
            self.day > other_date.day
            return 1
          else
            return 0
          end
        end
      end
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
      register = (value < 0) ? set_sign(register, 1) : set_sign(register, 0)
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
      register = (value < 0) ? set_sign(register, 1) : set_sign(register, 0)
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
