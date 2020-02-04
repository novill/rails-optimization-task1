# RubyProf Flat report
# ruby 12-ruby-prof-flat.rb
# cat ruby_prof_reports/flat.txt
require 'ruby-prof'
require_relative 'work.rb'

RubyProf.measure_mode = RubyProf::WALL_TIME
work('data20000.txt', disable_gc: true)

result = RubyProf.profile do
  work('data20000.txt', disable_gc: true)
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open("ruby_prof_reports/flat.txt", "w+"))
