

#[100,1000,10000,20000].each do |lines|
# [1000,2000,4000,8000, 16000].each do |lines|
[100000].each do |lines|
  puts 'warming'
  work("data#{lines}.txt") # прогрев
  time = Benchmark.realtime { work("data#{lines}.txt") }
  puts "Finish #{lines} lines in #{time.round(5)}"
end