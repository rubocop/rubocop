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
Rainbow.enabled = false

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

  config.mock_with :rspec do |c|
    c.syntax = :expect # disables `should_receive` and `stub`
  end

  config.include(ExitCodeMatchers)
end

def inspect_source_file(cop, source)
  Tempfile.open('tmp') { |f| inspect_source(cop, source, f) }
end

def inspect_source(cop, source, file = nil)
  Rubocop::Formatter::DisabledConfigFormatter.config_to_allow_offences = {}
  processed_source = parse_source(source, file)
  fail 'Error parsing example code' unless processed_source.valid_syntax?
  _investigate(cop, processed_source)
end

def parse_source(source, file = nil)
  source = source.join($RS) if source.is_a?(Array)
  if file.is_a? String
    Rubocop::SourceParser.parse(source, file)
  elsif file
    file.write(source)
    file.rewind
    Rubocop::SourceParser.parse(source, file.path)
  else
    Rubocop::SourceParser.parse(source)
  end
end

def autocorrect_source(cop, source)
  cop.instance_variable_get(:@options)[:auto_correct] = true
  processed_source = parse_source(source)
  _investigate(cop, processed_source)

  corrector =
    Rubocop::Cop::Corrector.new(processed_source.buffer, cop.corrections)
  corrector.rewrite
end

def _investigate(cop, processed_source)
  commissioner = Rubocop::Cop::Commissioner.new([cop], raise_error: true)
  commissioner.investigate(processed_source)
  commissioner
end

class Rubocop::Cop::Cop
  def messages
    offences.sort.map(&:message)
  end

  def highlights
    offences.sort.map { |o| o.location.source }
  end
end

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
