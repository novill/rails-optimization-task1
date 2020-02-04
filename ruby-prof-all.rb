# RubyProf Flat report
# ruby 12-ruby-prof-flat.rb
# cat ruby_prof_reports/flat.txt
#
require 'ruby-prof'
require_relative 'work.rb'

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  work('data20000.txt', disable_gc: true)
end

puts 'Report'
puts 'flat'
printer = RubyProf::FlatPrinter.new(result)

my_file = File.open("ruby_prof_reports/flat.txt", "w+")
printer.print(my_file)
my_file.close

puts 'graph'
printer2 = RubyProf::GraphHtmlPrinter.new(result)
printer2.print(File.open("ruby_prof_reports/graph.html", "w+"))

puts 'callstack'
printer3 = RubyProf::CallStackPrinter.new(result)
printer3.print(File.open('ruby_prof_reports/callstack.html', 'w+'))

puts 'calltree'
printer4 = RubyProf::CallTreePrinter.new(result)
printer4.print(:path => "ruby_prof_reports", :profile => 'callgrind')

