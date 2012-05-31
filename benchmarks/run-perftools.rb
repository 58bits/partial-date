#!/usr/bin/env ruby

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'), File.dirname(__FILE__))

require 'perftools'
require 'partial-date'
require 'date'

class PartialDateCPUProfile
  def initialize(iterations)
    @tmp_dir = File.expand_path('../tmp', __FILE__)
    Dir.mkdir @tmp_dir unless Dir.exists? @tmp_dir

    @iterations = (iterations || 100000).to_i
    @profiles   = []

    profile('create_stdlib_date') do |d|
      Date.new(2012,12,1)
    end

    profile('create_partial_date') do |d|
      PartialDate::Date.new { |d| d.year - 2012; d.month = 12; d.day = 1}
    end

    profile('load_partial_date') do |d|
      PartialDate::Date.load(20121201)
    end
  end

  def run
    puts "#{@iterations} Iterations"
    @profiles.each do |name, block| 
      PerfTools::CpuProfiler.start(name) do
        @iterations.times { block.call }
        #@iterations.to_i.times { block.call }
      end
      system "pprof.rb --gif #{name} > #{name}.gif"
    end    
  end

  def profile(name, &block)
    @profiles.push([@tmp_dir + "/" + name, block])
  end
end

PartialDateCPUProfile.new(ENV['iterations']).run
