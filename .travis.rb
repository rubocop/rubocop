# frozen_string_literal: true

require 'English'
require 'benchmark'

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
    # See https://github.com/rubocop-hq/rubocop/pull/4523#issuecomment-309136113
    def check_requiring_libraries
      sh!("ruby -I lib -r rubocop -e 'exit 0'")
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

RubocopTravis.run
