require 'benchmark/ips'
require_relative 'work'

Benchmark.ips do |x|
  # The default is :stats => :sd, which doesn't have a configurable confidence
  # confidence is 95% by default, so it can be omitted
  x.config(
      stats: :bootstrap,
      confidence: 95,
      )
  x.report("data.txt analize") do
    work
  end

  x.report("data100.txt analize") do
    work('data100.txt')
  end

  x.report("data1000.txt analize") do
    work('data1000.txt')
  end

  x.report("data10000.txt analize") do
    work('data10000.txt')
  end

  x.report("data50000.txt analize") do
    work('data50000.txt')
  end

    # x.report("data100000.txt analize") do
  #   work('data100000.txt')
  # end
end



