# encoding: utf-8

if ENV['TRAVIS'] && RUBY_ENGINE == 'jruby'
  # Force JRuby not to select working directory
  # as temporary directory on Travis CI.
  # https://github.com/jruby/jruby/issues/405
  require 'fileutils'
  tmp_dir = ENV['TMPDIR'] || ENV['TMP'] || ENV['TEMP'] ||
            Etc.systmpdir || '/tmp'
  non_world_writable_tmp_dir = File.join(tmp_dir, 'rubocop')
  FileUtils.makedirs(non_world_writable_tmp_dir, mode: 0700)
  ENV['TMPDIR'] = non_world_writable_tmp_dir
end

if ENV['TRAVIS'] || ENV['COVERAGE']
  require 'simplecov'

  if ENV['TRAVIS']
    require 'coveralls'
    SimpleCov.formatter = Coveralls::SimpleCov::Formatter
  end

  SimpleCov.start do
    add_filter '/spec/'
    add_filter '/vendor/bundle/'
  end
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'rubocop'
require 'rubocop/cli'

# disable colors in specs
Sickill::Rainbow.enabled = false

module ExitCodeMatchers
  RSpec::Matchers.define :exit_with_code do |code|
    actual = nil
    match do |block|
      begin
        block.call
      rescue SystemExit => e
        actual = e.status
      end
      actual && actual == code
    end
    failure_message_for_should do |block|
      "expected block to call exit(#{code}) but exit" +
        (actual.nil? ? ' not called' : "(#{actual}) was called")
    end
    failure_message_for_should_not do |block|
      "expected block not to call exit(#{code})"
    end
    description do
      "expect block to call exit(#{code})"
    end
  end
end

RSpec.configure do |config|
  broken_filter = lambda do |v|
    v.is_a?(Symbol) ? RUBY_ENGINE == v.to_s : v
  end
  config.filter_run_excluding ruby: ->(v) { !RUBY_VERSION.start_with?(v.to_s) }
  config.filter_run_excluding broken: broken_filter
  config.treat_symbols_as_metadata_keys_with_true_values = true

  config.expect_with :rspec do |c|
    c.syntax = :expect # disables `should`
  end

  config.include(ExitCodeMatchers)
end

def inspect_source(cop, source)
  ast, comments, tokens, src_buffer, _ = Rubocop::CLI.parse('(string)') do |sb|
    sb.source = source.join($RS)
  end
  cop.inspect(src_buffer, source, tokens, ast, comments)
end

class Rubocop::Cop::Cop
  def messages
    offences.map(&:message)
  end
end

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
