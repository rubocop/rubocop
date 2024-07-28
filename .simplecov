# frozen_string_literal: true

SimpleCov.start do
  add_filter '/spec/'
  add_filter '/vendor/bundle/'
  enable_coverage :branch
end
