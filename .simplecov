# frozen_string_literal: true

SimpleCov.enable_coverage :branch
SimpleCov.minimum_coverage line: 98.00, branch: 93.00
SimpleCov.ignore_branches :implicit_else
SimpleCov.skip '/spec/'
SimpleCov.skip '/vendor/bundle/'
SimpleCov.merge_subprocesses true
