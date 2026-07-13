# frozen_string_literal: true

SimpleCov.enable_coverage :branch
# Coverage numbers may differ between CI and local execution.
# Update minimum_coverage only to the lower of those numbers.
SimpleCov.minimum_coverage line: 98.5, branch: 93
SimpleCov.ignore_branches :implicit_else
SimpleCov.skip '/spec/'
SimpleCov.skip '/vendor/bundle/'
SimpleCov.merge_subprocesses true
