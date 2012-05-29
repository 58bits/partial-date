module PartialDate
  class PartialDateError < StandardError
  end

  class YearError < PartialDateError 
  end

  class MonthError < PartialDateError 
  end

  class DayError < PartialDateError 
  end
end
