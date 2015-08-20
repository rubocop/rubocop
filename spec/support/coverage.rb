# encoding: utf-8

if ENV['TRAVIS'] || ENV['COVERAGE']
  require 'simplecov'
  require 'coveralls' if ENV['TRAVIS']

  SimpleCov.command_name "rspec_#{Process.pid}"
  SimpleCov.start do
    add_filter '/spec/'
    add_filter '/vendor/bundle/'
  end
end
