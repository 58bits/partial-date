#!/usr/bin/env ruby

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'), File.dirname(__FILE__))

require 'partial-date'
require 'date'


class PartialDateMemoryProfile
  def initialize(iterations)
    @tmp_dir = File.expand_path('../tmp', __FILE__)
    Dir.mkdir @tmp_dir unless Dir.exists? @tmp_dir

    @iterations = (iterations || 100000).to_i
    @profiles   = []
    @memory = []

    # profile('create_stdlib_date') do |d|
    #   @memory << Date.new(2012,12,1)
    # end

    profile('create_partial_date') do |d|
      @memory << PartialDate::Date.new { |d| d.year - 2012; d.month = 12; d.day = 1}
    end

    # profile('load_partial_date') do |d|
    #   PartialDate::Date.load(20121201)
    # end
  end

  def run
    puts "#{@iterations} Iterations"
    GC::Profiler.enable()
    @profiles.each do |name, block| 
      count = 1
      @iterations.times do 
        block.call 
        if count % 1000 == 0
          puts " GC Profile Report #{ count.to_s.rjust(5, '0') } for #{ name } and #{ @memory.length} objects." 
          puts GC::Profiler.report()
        end
        count += 1
      end
    end    
  end

  def profile(name, &block)
    @profiles.push([@tmp_dir + "/" + name, block])
  end
end

PartialDateMemoryProfile.new(ENV['iterations']).run
