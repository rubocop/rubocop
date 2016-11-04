# frozen_string_literal: true

if ENV['TRAVIS'] || ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.add_filter '/spec/'
  SimpleCov.add_filter '/vendor/bundle/'
  SimpleCov.start

  SimpleCov.command_name "rspec_#{Process.pid}"
end
