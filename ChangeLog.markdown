### 1.2.3 / 2016-01-12
* Added final commas to MONTH_NAMES and ABBR_MONTH_NAMES

### 1.2.2 / 2013-01-27
* Added aditional guards against empty strings for year, month, day.

### 1.2.1 / 2012-10-05
* Bugfix: Merged pull request and bugfix for zero day mask. Thank you Alexander Gräfe. https://github.com/rickenharp

### 1.2.0 / 2012-06-03

* Documentation and comment clean-up
* Implemented guard on to_s for unknown % tokens.

### 1.1.10 / 2012-06-01

* Implemented faster Date#.to_s method.

### 1.1.9 / 2012-05-31

* BugFix: to_s will preserve minus sign for negative year when formatter starts with %Y
* BugFix: <=> correct for negative dates.

### 1.1.8 / 2012-05-30

* Implemented to_s formatters.

### 1.1.7 / 2012-05-30

* BugFix: Another logical error in to_s - fixed (formatters next).

### 1.1.6 / 2012-05-30

* Bugfix: Checked that sign is switched off when a postive year is set after a negative year.
* Bugfix: Fixed to_s again (before formatters are implemented).

### 1.1.5 / 2012-05-30

* Allow negative years and year range from -1048576 to 1048576 (20 bits).
* Implemented negative year with signing mask.
* Year is no longer mandatory
* Created more specific error classes
* Implemented readonly attribute Date#bits to allow public access to the bit store for comparison in <=>.
* Moved bits.rb back into date.rb


### 1.1.4 / 2012-05-29

* Changed error messages for month and day to 0 - 12 and 0 - 31 respectively (since zero values are allowed).
* Changed day validation logic to only check for the presence of month (not year and month - since a year has to be set before a month and is checked there).

### 1.1.3 / 2012-05-28

* Bugfix: Fixed ZERO_DAY_MASK - which contained an extra bit, and was zeroing month when a day was set.
* Check that day is set to zero if month is.
* Added padding to string format for date.

### 1.1.2 / 2012-05-27

* Fixed syntax error in example code from README.

### 1.1.1 / 2012-05-27

* Updated tests and documentation.

### 1.1.0 / 2012-05-27

* Implemented a 23 bit store as backing store for date,
reducing the storage requirements and increasing performance
of date objects.

### 1.0.0 / 2012-05-27

* Refactored to use array backing store for element and computed date
values for better performance.
* Implemented Comparable

### 0.1.0 / 2012-05-26

* Initial release:
