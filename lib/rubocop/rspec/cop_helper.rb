# frozen_string_literal: true

require 'tempfile'

# This module provides methods that make it easier to test Cops.
module CopHelper
  extend RSpec::SharedContext

  let(:ruby_version) { 2.6 }
  let(:rails_version) { false }

  def inspect_source(source, file = nil)
    RuboCop::Formatter::DisabledConfigFormatter.config_to_allow_offenses = {}
    RuboCop::Formatter::DisabledConfigFormatter.detected_styles = {}
    processed_source = parse_source(source, file)
    unless processed_source.valid_syntax?
      raise 'Error parsing example code: ' \
            "#{processed_source.diagnostics.map(&:render).join("\n")}"
    end

    _investigate(cop, processed_source)
  end

  def parse_source(source, file = nil)
    if file.respond_to?(:write)
      file.write(source)
      file.rewind
      file = file.path
    end

    processed_source = RuboCop::ProcessedSource.new(source, ruby_version, file)
    processed_source.config = configuration
    processed_source.registry = registry
    processed_source
  end

  def configuration
    @configuration ||= if defined?(config)
                         config
                       else
                         RuboCop::Config.new({}, "#{Dir.pwd}/.rubocop.yml")
                       end
  end

  def registry
    @registry ||= begin
      keys = configuration.keys
      cops =
        keys.map { |directive| RuboCop::Cop::Registry.global.find_cops_by_directive(directive) }
            .flatten
      cops << cop_class if defined?(cop_class) && !cops.include?(cop_class)
      cops.compact!
      RuboCop::Cop::Registry.new(cops)
    end
  end

  def autocorrect_source_file(source)
    Tempfile.open('tmp') { |f| autocorrect_source(source, f) }
  end

  def autocorrect_source(source, file = nil)
    RuboCop::Formatter::DisabledConfigFormatter.config_to_allow_offenses = {}
    RuboCop::Formatter::DisabledConfigFormatter.detected_styles = {}
    cop.instance_variable_get(:@options)[:autocorrect] = true
    processed_source = parse_source(source, file)
    _investigate(cop, processed_source)

    @last_corrector.rewrite
  end

  def _investigate(cop, processed_source)
    team = RuboCop::Cop::Team.new([cop], nil, raise_error: true)
    report = team.investigate(processed_source)
    @last_corrector = report.correctors.first || RuboCop::Cop::Corrector.new(processed_source)
    report.offenses.reject(&:disabled?)
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
