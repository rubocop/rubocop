# encoding: utf-8

if ENV['TRAVIS'] || ENV['COVERAGE']
  require 'simplecov'

  if ENV['TRAVIS']
    require 'coveralls'
    SimpleCov.formatter = Coveralls::SimpleCov::Formatter
  end

  SimpleCov.start do
    add_filter '/spec/'
    add_filter '/vendor/bundle/'
  end
end
