require 'spec_helper'
require 'partial/date'

describe Partial::Date do
  it "should have a VERSION constant" do
    subject.const_get('VERSION').should_not be_empty
  end
end
