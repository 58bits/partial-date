require 'spec_helper'
require 'partial-date'

describe PartialDate do

  let(:host) { Object.new.extend(PartialDate) }

  it "should have a VERSION constant" do
    subject.const_get('VERSION').should_not be_empty
  end


  it "should have a readable p_date attribute" do
    host.p_year = 2000
    host.p_date.should eql(20000000)
  end

  describe "Year" do
    it "should raise an error if year is set to nil" do
      expect {host.p_year = nil}.to raise_error(PartialDateError)
    end

    it "should raise an error if year is set to a five digit string" do
      expect {host.p_year = "10000" }.to raise_error(PartialDateError, "Year must be a valid four digit string or integer between 1 and 9999")
    end

    it "should raise an error if year is set to a value greater than 9999" do
      expect {host.p_year = 10000 }.to raise_error(PartialDateError, "Year must be an integer between 1 and 9999")
    end

    it "should raise an error if year is set to zero" do
      expect {host.p_year = 0 }.to raise_error(PartialDateError, "Year must be an integer between 1 and 9999")
    end

    it "should raise an error if year is set to a value less than zero" do
      expect {host.p_year = -2 }.to raise_error(PartialDateError, "Year must be an integer between 1 and 9999")
    end

    it "should return a year when a year is set" do
      host.p_year = 2050
      host.p_year.should eql(2050)
    end
  end

  describe "Month" do
    it "should return zero if month is set to nil" do
      host.p_month = nil
      host.p_month.should eql(0)
    end
  
    it "should raise an error if month is set to a value greater than 12" do
      expect {host.p_month = 13}.to raise_error(PartialDateError, "Month must be integer between 1 and 12")
    end

    it "should return a month when a month is set" do
      host.p_month = 10
      host.p_month.should eql(10)
    end
  end

  describe "Day" do
    it "should return a day when a day is set" do
      host.p_day = 10
      host.p_day.should eql(10)
    end
  end
end
