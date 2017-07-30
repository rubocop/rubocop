# frozen_string_literal: true

require 'English'
require 'benchmark'

def jruby?
  RUBY_ENGINE == 'jruby'
end

def master?
  ENV['TRAVIS_BRANCH'] == 'master' && ENV['TRAVIS_PULL_REQUEST'] == 'false'
end

def test?
  ENV['TASK'] != 'internal_investigation'
end

def sh!(command)
  puts "$ #{command}"
  time = Benchmark.realtime do
    system(command)
  end
  puts "#{time} seconds"
  puts
  raise "`#{command}` is failed" unless $CHILD_STATUS.success?
end

# Run main task(RSpec or RuboCop).
if master? || !test? || jruby? || RUBY_VERSION < '2.1.0'
  sh!("bundle exec rake #{ENV['TASK']}")
else
  sh!("bundle exec rake parallel:#{ENV['TASK']}")
end

# Report test coverage
sh!('bundle exec codeclimate-test-reporter') if master? && test?

# Running YARD under jruby crashes so skip checking manual under jruby
# Workaround: This task makes a mysterious diff in Ruby 2.0.
#             So we ignore Ruby 2.0.
if RUBY_ENGINE == 'ruby' && RUBY_VERSION >= '2.1'
  sh!('bundle exec rake generate_cops_documentation')
end

# Check requiring libraries successfully.
# See https://github.com/bbatsov/rubocop/pull/4523#issuecomment-309136113
sh!("ruby -I lib -r rubocop -e 'exit 0'")
