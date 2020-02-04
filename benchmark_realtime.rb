require 'benchmark'
require_relative 'work'

[100,1000,10000, 20000].each do |lines|
  work("data#{lines}.txt") # прогрев
  time = Benchmark.realtime { work("data#{lines}.txt") }
  puts "Finish #{lines} lines in #{time.round(3)}"
end