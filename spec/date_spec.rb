require 'spec_helper'
require 'partial-date'

describe PartialDate::Date do

  let(:date) { PartialDate::Date.new }

  it "should have a VERSION constant" do
    PartialDate.const_get('VERSION').should_not be_empty
  end

  it "should have a readable value attribute" do
    date.year = 2000
    date.value.should == 20000000
  end

  it "should allow construction from a block of integers" do
    new_date = PartialDate::Date.new {|d| d.year = 2010; d.month = 12; d.day = 1}
    new_date.value.should == 20101201
  end

  it "should allow construction from a block of strings" do
    new_date = PartialDate::Date.new {|d| d.year = "2010"; d.month = "12"; d.day = "1"}
    new_date.value.should == 20101201
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
    expect {new_date = PartialDate::Date.new {|d| d.value = 100000000}}.to raise_error(PartialDate::PartialDateError, "Date value must be an integer betwen 10000 and 99991231")
  end

  it "should return a string representation of date in the correct format" do
    new_date = PartialDate::Date.new {|d| d.year = 2012; d.month = 12; d.day = 31}
    new_date.to_s.should match(/\A\d{4}-\d{2}-\d{2}\z/)
  end

  it "should return a string representation of a partial date in the correct format" do
    new_date = PartialDate::Date.new {|d| d.year = 2012; d.month = 12}
    new_date.to_s.should match(/\A\d{4}-\d{2}\z/)
  end

  it "should return a string representation of a partial date in the correct format" do
    new_date = PartialDate::Date.new {|d| d.year = 2012}
    new_date.to_s.should match(/\A\d{4}\z/)
  end

  describe "Year" do
    it "should raise an error if year is set to nil" do
      expect {date.year = nil}.to raise_error(PartialDate::PartialDateError)
    end

    it "should raise an error if year is set to an invalid string" do
      expect {date.year = "ABCD" }.to raise_error(PartialDate::PartialDateError, "Year must be a valid four digit string or integer between 1 and 9999")
    end

    it "should raise an error if year is set to a five digit string" do
      expect {date.year = "10000" }.to raise_error(PartialDate::PartialDateError, "Year must be a valid four digit string or integer between 1 and 9999")
    end

    it "should raise an error if year is set to a value greater than 9999" do
      expect {date.year = 10000 }.to raise_error(PartialDate::PartialDateError, "Year must be an integer between 1 and 9999")
    end

    it "should raise an error if year is set to zero" do
      expect {date.year = 0 }.to raise_error(PartialDate::PartialDateError, "Year must be an integer between 1 and 9999")
    end

    it "should raise an error if year is set to a value less than zero" do
      expect {date.year = -1 }.to raise_error(PartialDate::PartialDateError, "Year must be an integer between 1 and 9999")
    end

    it "should return a year when a year is set" do
      date.year = 2050
      date.year.should == 2050
    end
  end

  describe "Month" do
    before(:each) { date.year = 2000 }

    it "should raise an error if a month is set before a year" do
      no_year = PartialDate::Date.new
      expect {no_year.month = 10}.to raise_error(PartialDate::PartialDateError, "A year must be set before a month")
    end

    it "should raise an error if month is set to an invalid string" do
      expect {date.month = "AB"}.to raise_error(PartialDate::PartialDateError, "Month must be a valid one or two digit string or integer between 1 and 12")
    end

    it "should raise an error if month is set to a value greater than 12" do
      expect {date.month = 13}.to raise_error(PartialDate::PartialDateError, "Month must an be integer between 1 and 12")
    end

    it "should raise an error if month is set to a value less than zero" do
      expect {date.month = -1}.to raise_error(PartialDate::PartialDateError, "Month must an be integer between 1 and 12")
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
      expect {no_month.day = 10}.to raise_error(PartialDate::PartialDateError, "A year and month must be set before a day")
    end

    it "should raise an error if day is set to an invalid string" do
      expect {date.day = "AB"}.to raise_error(PartialDate::PartialDateError, "Day must be a valid one or two digit string or integer between 1 and 31")
    end

    it "should raise an error if day is set to a value less than zero" do
      expect {date.day = -1}.to raise_error(PartialDate::PartialDateError, "Day must be an integer between 1 and 31")
    end

    it "should raise an error if day is set to a value greater than 31" do
      expect {date.day = 32}.to raise_error(PartialDate::PartialDateError, "Day must be an integer between 1 and 31")
    end

    it "should raise an error if the day is an invalid day for the given month" do
      expect {date.day = 31}.to raise_error(PartialDate::PartialDateError, "Day must be a valid day for the given month")
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
    it "should determine if one date is greater than another" do
        a = PartialDate::Date.new {|d| d.year = 2012; d.month = 12; d.day = 31}
        b = PartialDate::Date.new {|d| d.year = 2012; d.month = 12; d.day = 30}
        a.should be > b
    end

    it "should determine if one date is less than another" do
        a = PartialDate::Date.new {|d| d.year = 2012; d.month = 0; d.day = 0}
        b = PartialDate::Date.new {|d| d.year = 2012; d.month = 12; d.day = 30}
        a.should be < b
    end

    it "should determine if one date is equal to another" do
        a = PartialDate::Date.new {|d| d.year = 2012; d.month = 12; d.day = 30}
        b = PartialDate::Date.new {|d| d.year = 2012; d.month = 12; d.day = 30}
        a.should be == b
    end
  end

end
