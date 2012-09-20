require 'spec_helper'
require 'partial-date'

describe PartialDate::Date do

  let(:date) { PartialDate::Date.new }

  it "should have a VERSION constant" do
    PartialDate.const_get('VERSION').should_not be_empty
  end

  it "should return an empty string for an empty date" do
    date.to_s.should == ""
  end

  it "should have a readable value attribute" do
    date.year = 2000
    date.value.should == 20000000
  end

  it "should allow construction from a block of integers" do
    new_date = PartialDate::Date.new {|d| d.year = 2010; d.month = 11; d.day = 1}
    new_date.value.should == 20101101
  end

  it "should allow construction from a block of strings" do
    new_date = PartialDate::Date.new {|d| d.year = "2010"; d.month = "11"; d.day = "1"}
    new_date.value.should == 20101101
  end

  it "should allow construction from the class load method" do
    new_date = PartialDate::Date.load(20120000)
    new_date.year.should == 2012
    new_date.month.should == 0
    new_date.day.should == 0
  end

  it "should allow a date value in partial date format to be set in a date instance" do
    new_date = PartialDate::Date.new {|d| d.value = 20120000}
    new_date.year.should == 2012
    new_date.month.should == 0
    new_date.day.should == 0
    new_date.value.should == 20120000
  end

  it "should not allow an invalid date value to be set in a date instance" do
    expect {new_date = PartialDate::Date.new {|d| d.value = 10485761232 }}.to raise_error(PartialDate::PartialDateError, "Date value must be an integer betwen -10485761231 and 10485761231")
  end



  describe "Sign" do
    it "should be set to 1" do
      register = 0
      register = PartialDate::Date.set_sign(register, 1)
      PartialDate::Date.get_sign(register).should == 1
    end
    it "should be 1 if year is a negative value" do
      register = 0
      register = PartialDate::Date.set_year(register, -9999)
      PartialDate::Date.get_sign(register).should == 1
    end

    it "should be 0 if year is a positive value" do
      register = 0
      register = PartialDate::Date.set_year(register, 9999)
      PartialDate::Date.get_sign(register).should == 0
    end
  end


  describe "Year" do
    it "should raise an error if year is set to an invalid string" do
      expect {date.year = "ABCD" }.to raise_error(PartialDate::YearError, "Year must be a valid string or integer from -1048576 to 1048576")
    end

    it "should raise an error if year is set to a value greater than 1048576" do
      expect {date.year = 1048577 }.to raise_error(PartialDate::YearError, "Year must be an integer from -1048576 to 1048576")
    end

    it "should allow a negative year to be set from the block" do
      date = PartialDate::Date.new { |d| d.year = -1000 }
      date.year.should == -1000
    end

    it "should return a postive year when a positive year is set" do
      date.year = 2050
      date.year.should == 2050
    end

    it "should return a negative year when a negative year is set" do
      date.year = -9999
      date.year.should == -9999
    end

    it "should allow a valid string value" do
      date.year = "2010"
      date.year.should == 2010
    end

    it "should allow a negative value in a string" do
      date.year = "-2010"
      date.year.should == -2010
    end
  end

  describe "Month" do
    before(:each) { date.year = 2000 }

    it "should raise an error if month is set to an invalid string" do
      expect {date.month = "AB"}.to raise_error(PartialDate::MonthError, "Month must be a valid one or two digit string or integer between 0 and 12")
    end

    it "should raise an error if month is set to a value greater than 12" do
      expect {date.month = 13}.to raise_error(PartialDate::MonthError, "Month must an be integer between 0 and 12")
    end

    it "should raise an error if month is set to a value less than zero" do
      expect {date.month = -1}.to raise_error(PartialDate::MonthError, "Month must an be integer between 0 and 12")
    end

    it "should allow the month to be set to zero" do
      date.month = 0
      date.month.should == 0
    end

    it "should return zero if month is set to nil" do
      date.month = nil
      date.month.should == 0
    end

    it "should return a month when a month is set" do
      date.month = 10
      date.month.should == 10
    end
  end

  describe "Day" do
    before(:each) { date.year = 2000; date.month = 6 }

    it "should raise an error if a day is set before a year and month" do
      no_month = PartialDate::Date.new
      expect {no_month.day = 10}.to raise_error(PartialDate::DayError, "A month must be set before a day")
    end

    it "should raise an error if day is set to an invalid string" do
      expect {date.day = "AB"}.to raise_error(PartialDate::DayError, "Day must be a valid one or two digit string or integer between 0 and 31")
    end

    it "should raise an error if day is set to a value less than zero" do
      expect {date.day = -1}.to raise_error(PartialDate::DayError, "Day must be an integer between 0 and 31")
    end

    it "should raise an error if day is set to a value greater than 31" do
      expect {date.day = 32}.to raise_error(PartialDate::DayError, "Day must be an integer between 0 and 31")
    end

    it "should raise an error if the day is an invalid day for the given month" do
      expect {date.day = 31}.to raise_error(PartialDate::DayError, "Day must be a valid day for the given month")
    end

    it "should return zero when set to nil" do
      date.day = nil
      date.day.should == 0
    end

    it "should allow the day to be set to zero" do
      date.day = 0
      date.day.should == 0
    end

    it "should return a day when a day is set" do
      date.day = 10
      date.day.should == 10
    end
  end

  describe "Comparisons" do
    it "should determine if one date is greater than another based on year" do
        a = PartialDate::Date.new {|d| d.year = 2013; }
        b = PartialDate::Date.new {|d| d.year = 2012; }
        a.should be > b
    end

    it "should determine if one date is less than another based on year" do
        a = PartialDate::Date.new {|d| d.year = 2011; }
        b = PartialDate::Date.new {|d| d.year = 2012; }
        a.should be < b
    end

    it "should determine if one date is equal to another based on year" do
        a = PartialDate::Date.new {|d| d.year = 2012; }
        b = PartialDate::Date.new {|d| d.year = 2012; }
        a.should be == b
    end

    it "should determine if one date is greater than another based on month" do
        a = PartialDate::Date.new {|d| d.year = 2012; d.month = 11; }
        b = PartialDate::Date.new {|d| d.year = 2012; d.month = 10 }
        a.should be > b
    end

    it "should determine if one date is less than another based on month" do
        a = PartialDate::Date.new {|d| d.year = 2012; d.month = 9; }
        b = PartialDate::Date.new {|d| d.year = 2012; d.month = 10 }
        a.should be < b
    end

    it "should determine if one date is equal to another based on month" do
        a = PartialDate::Date.new {|d| d.year = 2012; d.month = 10; }
        b = PartialDate::Date.new {|d| d.year = 2012; d.month = 10 }
        a.should be == b
    end

    it "should determine if one date is greater than another based on day" do
        a = PartialDate::Date.new {|d| d.year = 2012; d.month = 12; d.day = 31}
        b = PartialDate::Date.new {|d| d.year = 2012; d.month = 12; d.day = 30}
        a.should be > b
    end

    it "should determine if one date is less than another based on day" do
        a = PartialDate::Date.new {|d| d.year = 2012; d.month = 12; d.day = 29}
        b = PartialDate::Date.new {|d| d.year = 2012; d.month = 12; d.day = 30}
        a.should be < b
    end

    it "should determine if one date is equal to another based on day" do
        a = PartialDate::Date.new {|d| d.year = 2012; d.month = 12; d.day = 30}
        b = PartialDate::Date.new {|d| d.year = 2012; d.month = 12; d.day = 30}
        a.should be == b
    end
  end

  describe "String formats" do

    it "should return a string representation of date in the correct format" do
      new_date = PartialDate::Date.new {|d| d.year = 2012; d.month = 12; d.day = 31}
      new_date.to_s.should match(/\A\d{4}-\d{2}-\d{2}\z/)
    end

    it "should have a minus sign in front of negative dates" do
        date = PartialDate::Date.new { |d| d.year = -1000; d.month = 12; d.day = 1}
        date.to_s.should start_with("-")
    end
  end
end
