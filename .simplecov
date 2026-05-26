# frozen_string_literal: true

SimpleCov.enable_coverage :branch
SimpleCov.minimum_coverage line: 98.00, branch: 93.00
SimpleCov.ignore_branches :implicit_else
SimpleCov.skip '/spec/'
SimpleCov.skip '/vendor/bundle/'

# Configuration for parallel spec runs
SimpleCov.merge_subprocesses true
SimpleCov.at_fork do |pid|
  SimpleCov.command_name "#{SimpleCov.command_name} (pid #{pid})"
  SimpleCov.print_errors false
  SimpleCov.formatter false
  SimpleCov.minimum_coverage 0
  SimpleCov.start
end
