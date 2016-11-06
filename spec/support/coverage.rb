# frozen_string_literal: true

if ENV['TRAVIS'] || ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.add_filter '/spec/'
  SimpleCov.add_filter '/vendor/bundle/'
  SimpleCov.command_name 'rspec'
  SimpleCov.start
end
