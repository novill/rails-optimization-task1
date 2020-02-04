require 'rspec'
require 'rspec/core'
require 'rspec-benchmark'
require_relative 'work'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance 20k lines file' do
  it 'works under 1 ms' do
    expect {
      work('data20000.txt')
    }.to perform_under(15*1000).ms.warmup(1).times
  end
end