# frozen_string_literal: true

require 'English'
require 'benchmark'
require 'open3'

# A module for continuous integration.
module RubocopTravis
  class << self
    def run
      run_main_task
      report_coverage
      documentation
      check_requiring_libraries
    end

    private

    # Check requiring libraries successfully.
    def check_requiring_libraries
      check_require_status

      check_require_output
    end

    # See https://github.com/rubocop-hq/rubocop/pull/4523#issuecomment-309136113
    def check_require_status
      sh!("ruby -I lib -r rubocop -e 'exit 0'")
    end

    def check_require_output
      whitelisted = ->(line) { line =~ /warning: private attribute\?$/ }

      warnings = captured_sh!('ruby -Ilib -w -W2 lib/rubocop.rb 2>&1')
                 .lines
                 .grep(%r{/lib/rubocop}) # ignore warnings from dependencies
                 .reject(&whitelisted)

      return if warnings.empty?

      raise "Requiring rubocop raises the following warnings: #{warnings}"
    end

    # Running YARD under jruby crashes so skip checking the manual.
    def documentation
      return if jruby?
      sh!('bundle exec rake documentation_syntax_check ' \
          'generate_cops_documentation')
    end

    def jruby?
      RUBY_ENGINE == 'jruby'
    end

    def master?
      ENV['TRAVIS_BRANCH'] == 'master' && ENV['TRAVIS_PULL_REQUEST'] == 'false'
    end

    def report_coverage
      sh!('bundle exec codeclimate-test-reporter') if master? && test?
    end

    # Run main task(RSpec or RuboCop).
    def run_main_task
      if master? || !test? || jruby?
        sh!("bundle exec rake #{ENV['TASK']}")
      else
        sh!("bundle exec rake parallel:#{ENV['TASK']}")
      end
    end

    def captured_sh!(command)
      puts "$ #{command}"

      status = nil
      output = ''

      time = Benchmark.realtime do
        output, status = Open3.capture2e(command)
      end

      puts "#{time} seconds"
      puts
      raise "`#{command}` is failed" unless status.success?
      output
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

    def test?
      ENV['TASK'] != 'internal_investigation'
    end
  end
end

if ENV['TASK'].nil? || ENV['TASK'].empty?
  raise 'The TASK environemnt variable needs to be set with a valid rake task'
end

RubocopTravis.run
