# frozen_string_literal: true

# https://www.codeotaku.com/journal/2018-11/fibers-are-the-right-solution/index
# https://github.com/ruby/ruby/pull/1870
# https://www.igvita.com/2009/05/13/fibers-cooperative-scheduling-in-ruby/
# https://github.com/socketry/lightio
# https://github.com/socketry/async
# https://github.com/eventmachine/eventmachine
# https://bugs.ruby-lang.org/issues/14736
# https://github.com/ruby/ruby/pull/1870

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'

  gem 'lightio'
  gem 'thwait'
  gem 'e2mmap'
end

require 'lightio'

LightIO::Monkey.patch_all!

require 'net/http'
require 'benchmark'

Benchmark.bm do |x|
  x.report('sync') do
    puts Net::HTTP.get(URI('http://checkip.amazonaws.com/'))
    puts Net::HTTP.get(URI('https://wtfismyip.com/text'))
  end

  x.report('async fibers') do
    amazonaws = Fiber.new do
      puts Net::HTTP.get(URI('http://checkip.amazonaws.com/'))
      puts 'async: amazonaws'
    end

    wtfismyip = Fiber.new do
      puts Net::HTTP.get(URI('https://wtfismyip.com/text'))
      puts 'async: wtfismyip'
    end

    amazonaws.resume
    wtfismyip.resume
  end

  x.report('async lightio') do
    amazonaws = LightIO::Beam.new do
      puts Net::HTTP.get(URI('http://checkip.amazonaws.com/'))
      puts 'async: amazonaws'
    end

    wtfismyip = LightIO::Beam.new do
      puts Net::HTTP.get(URI('https://wtfismyip.com/text'))
      puts 'async: wtfismyip'
    end

    amazonaws.join
    wtfismyip.join
  end
end
