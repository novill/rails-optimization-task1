require 'rspec-benchmark'
require_relative 'work'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

seconds = 2
lines =300000

describe 'Check performance metrics' do
  it "works under #{seconds} seconds" do
    expect {
      work("data#{lines}.txt")
      }.to perform_under(seconds * 1000).ms.warmup(1).times.sample(3).times
  end
end
