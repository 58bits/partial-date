require 'spec_helper'
require 'partial-date'

describe PartialDate::Date do

  let(:date) { PartialDate::Date.new }

  describe "to string" do
    it "should be fast" do
      date.year = 2012; date.month = 12; date.day = 1
      puts date.to_s 
    end

    it "should not have a dash at the end if day is missing" do
      date.year = 2012; date.month = 12; date.day = 0
      puts date.to_s 
    end

    it "it should not have a trailing dash if month and day are missing" do
      date.year = 2012; date.month = 0; date.day = 0
      puts date.to_s 
    end

    it "it should not have a leading dash if year is missing" do
      date.year = 0; date.month = 12; date.day = 1
      puts date.to_s 
    end

    it "it should preserve the minus sign if year is negative" do
      date.year = -1000; date.month = 12; date.day = 1
      puts date.to_s 
    end
  end
end

