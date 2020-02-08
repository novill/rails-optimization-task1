require 'rspec-benchmark'
require_relative 'work'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

seconds = 2.1
lines = '500000'

describe 'Check performance metrics' do
  it "works under #{seconds} seconds" do
    skip 'no data file' unless File.exists?("data#{lines}.txt")
    expect {
      work("data#{lines}.txt", true)
      GC.enable
      GC.start
      }.to perform_under(seconds * 1000).ms.warmup(1).sample(2)
  end
end
