#!/usr/bin/env ruby

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'), File.dirname(__FILE__))

require 'partial-date'
require 'benchmark'

class PartialDateBenchmarks
  def initialize(iterations)
    @iterations = (iterations || 1000).to_i
    @benches    = []

    bench('(1) create empty date objects')  do |d|
      PartialDate::Date.new { |d| d.year = 2012; d.month = 12; d.day = 1 }
    end

    bench('(2) create populated date objects')  do |d| 
      PartialDate::Date.new { |d| d.year = 2012; d.month = 12; d.day = 1 }
    end

    bench('(3) create date objects from load method')  do |d| 
      PartialDate::Date.load 20121201
    end

    bench('(4) call default to_s') do |d|
      date = PartialDate::Date.new { |d| d.year = 2012; d.month = 12; d.day = 1 }
      date.to_s
    end

  end

  def run
    puts "#{@iterations} Iterations"
    Benchmark.bmbm do |x|
      @benches.each do |name, block|
        x.report name.to_s do
          @iterations.to_i.times { block.call }
        end
      end
    end
  end

  def bench(name, &block)
    @benches.push([name, block])
  end
end

PartialDateBenchmarks.new(ENV['iterations']).run
