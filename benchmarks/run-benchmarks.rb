#!/usr/bin/env ruby

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'), File.dirname(__FILE__))

require 'partial-date'
require 'benchmark'
require 'date'

class PartialDateBenchmarks
  def initialize(iterations)
    @iterations = (iterations || 1000).to_i
    @benches    = []

    bench('(1a) create empty stdlib date objects')  do |d|
      Date.new
    end

    bench('(1b) create empty partial-date objects')  do |d|
      PartialDate::Date.new
    end

    bench('(2a) create populated stdlib date objects')  do |d| 
      Date.new(2012,12,1)
    end

    bench('(2b) create populated partial-date objects from block')  do |d| 
      PartialDate::Date.new { |d| d.year = 2012; d.month = 12; d.day = 1 }
    end

    bench('(3) create partial-date objects from load method')  do |d| 
      PartialDate::Date.load 20121201
    end

    bench('(4a) call stdlib date strftime') do |d|
      d = Date.new(2012,12,1)
      d.strftime('%Y-%m-%d')
    end

    bench('(4b) call partial-date default to_s') do |d|
      d = PartialDate::Date.new { |d| d.year = 2012; d.month = 12; d.day = 1 }
      d.to_s
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
