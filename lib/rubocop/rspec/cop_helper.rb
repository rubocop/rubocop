# frozen_string_literal: true

require 'tempfile'

# This module provides methods that make it easier to test Cops.
module CopHelper
  extend RSpec::SharedContext

  let(:ruby_version) { 2.2 }
  let(:enabled_rails) { false }
  let(:rails_version) { false }

  def inspect_source_file(cop, source)
    Tempfile.open('tmp') { |f| inspect_source(cop, source, f) }
  end

  def inspect_gemfile(cop, source)
    inspect_source(cop, source, 'Gemfile')
  end

  def inspect_source(cop, source, file = nil)
    if source.is_a?(Array) && source.size == 1
      raise "Don't use an array for a single line of code: #{source}"
    end
    RuboCop::Formatter::DisabledConfigFormatter.config_to_allow_offenses = {}
    RuboCop::Formatter::DisabledConfigFormatter.detected_styles = {}
    processed_source = parse_source(source, file)
    raise 'Error parsing example code' unless processed_source.valid_syntax?
    _investigate(cop, processed_source)
  end

  def parse_source(source, file = nil)
    source = source.join($RS) if source.is_a?(Array)

    if file && file.respond_to?(:write)
      file.write(source)
      file.rewind
      file = file.path
    end

    RuboCop::ProcessedSource.new(source, ruby_version, file)
  end

  def autocorrect_source_file(cop, source)
    Tempfile.open('tmp') { |f| autocorrect_source(cop, source, f) }
  end

  def autocorrect_source(cop, source, file = nil)
    cop.instance_variable_get(:@options)[:auto_correct] = true
    processed_source = parse_source(source, file)
    _investigate(cop, processed_source)

    corrector =
      RuboCop::Cop::Corrector.new(processed_source.buffer, cop.corrections)
    corrector.rewrite
  end

  def autocorrect_source_with_loop(cop, source, file = nil)
    loop do
      cop.instance_variable_set(:@corrections, [])
      new_source = autocorrect_source(cop, source, file)
      return new_source if new_source == source
      source = new_source
    end
  end

  def _investigate(cop, processed_source)
    forces = RuboCop::Cop::Force.all.each_with_object([]) do |klass, instances|
      next unless cop.join_force?(klass)
      instances << klass.new([cop])
    end

    commissioner =
      RuboCop::Cop::Commissioner.new([cop], forces, raise_error: true)
    commissioner.investigate(processed_source)
    commissioner
  end
end

module RuboCop
  module Cop
    # Monkey-patch Cop for tests to provide easy access to messages and
    # highlights.
    class Cop
      def messages
        offenses.sort.map(&:message)
      end

      def highlights
        offenses.sort.map { |o| o.location.source }
      end
    end
  end
end

RSpec.configure do |config|
  config.include CopHelper
end
