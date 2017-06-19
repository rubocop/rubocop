# frozen_string_literal: true

on_master = ENV['TRAVIS_BRANCH'] == 'master' &&
            ENV['TRAVIS_PULL_REQUEST'] == 'false'
if on_master || ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.add_filter '/spec/'
  SimpleCov.add_filter '/vendor/bundle/'
  SimpleCov.command_name 'rspec'
  SimpleCov.start
end
