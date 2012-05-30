# partial-date

* See the [ChangeLog](https://github.com/58bits/partial-date/blob/master/ChangeLog.markdown) for details of this release.

* [Homepage](https://github.com/58bits/partial-date#readme)
* [Issues](https://github.com/58bits/partial-date/issues)
* [Documentation](http://rubydoc.info/gems/partial-date/frames)


## Description

A simple date class that can be used to store partial date values in a single column/attribute. An example use case would include an archive, or catalogue entry where the complete date is unknown. Year is optional and can be a negative value. Month and day are optional, but month must be set before day.

## Features

PartialDate::Date uses a 30 bit register as the backing store for date instances, and bit fiddling to get or set year, month and day values. As such it will perform well in a loop or collection of date objects.

Use `date.value` to get or set an Integer value that can be used to rehydrate a date object, or save the date value to a persistence store in a readable Integer form e.g. 20121201 for 2012 December 01. 

PartialDate::Date#to\_s has the following built-in formats:

    d.to_s           :default => "%Y-%m-%d"  
    d.to_s :short    :short => "%d %m %Y"    
    d.to_s :medium   :medium => "%d %b %Y"   
    d.to_s :long     :long => "%d %B %Y"     
    d_to_s :number   :number => "%Y%m%d"     

Custom formatters can be specified using the following:

    %Y - Year with century (can be negative, 4 digits at least)
                -0001, 0000, 1995, 2009, 14292, etc.
    %m - Month of the year, zero-padded (01..12)
    %B - The full month name ('January')
    %b - The abbreviated month name ('Jan')
    %d - Day of the month, zero-padded (01..31)
    %e - Day of the month, blank-padded ( 1..31)


## Examples

    require 'partial-date' 

    # Default initializer 
    date = PartialDate::Date.new
    # => 
    date.value
    # => 0

    # Initialize from a block of integers
    date = PartialDate::Date.new {|d| d.year = 2012; d.month = 01}
    # => 2012-01
    date.value
    # => 20120100

    # Initialize from a block of strings
    date = PartialDate::Date.new {|d| d.year = "2012"; d.month = "01"}
    # => 2012-01
    date.value
    # => 20120100
    date.to_s :medium
    # => Jan 2012

    # Initialize from the class load method - for rehydrating a date instance from a stored integer date value.
    date = PartialDate::Date.load 20121201
    # => 2012-12-01
    date.year
    # => 2012
    date.month
    # => 12
    date.day
    # => 1
    date.to_s :long
    # => 01 December 2012

## Install

    $ gem install partial-date

## TODO

 * PartialDate::Date#parse method for construction from strings.
 * I18n support.

## Copyright

Copyright (c) 2012 Anthony Bouch

See {file:LICENSE.txt} for details.
