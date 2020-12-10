# frozen_string_literal: true

module RuboCop
  module Cop
    module Gemspec
      # Checks that `required_ruby_version` of gemspec is specified and
      # equal to `TargetRubyVersion` of .rubocop.yml.
      # Thereby, RuboCop to perform static analysis working on the version
      # required by gemspec.
      #
      # @example
      #   # When `TargetRubyVersion` of .rubocop.yml is `2.5`.
      #
      #   # bad
      #   Gem::Specification.new do |spec|
      #     # no `required_ruby_version` specified
      #   end
      #
      #   # bad
      #   Gem::Specification.new do |spec|
      #     spec.required_ruby_version = '>= 2.4.0'
      #   end
      #
      #   # bad
      #   Gem::Specification.new do |spec|
      #     spec.required_ruby_version = '>= 2.6.0'
      #   end
      #
      #   # good
      #   Gem::Specification.new do |spec|
      #     spec.required_ruby_version = '>= 2.5.0'
      #   end
      #
      #   # good
      #   Gem::Specification.new do |spec|
      #     spec.required_ruby_version = '>= 2.5'
      #   end
      #
      #   # accepted but not recommended
      #   Gem::Specification.new do |spec|
      #     spec.required_ruby_version = ['>= 2.5.0', '< 2.7.0']
      #   end
      #
      #   # accepted but not recommended, since
      #   # Ruby does not really follow semantic versionning
      #   Gem::Specification.new do |spec|
      #     spec.required_ruby_version = '~> 2.5'
      #   end
      class RequiredRubyVersion < Base
        include RangeHelp

        NOT_EQUAL_MSG = '`required_ruby_version` (%<required_ruby_version>s, ' \
                        'declared in %<gemspec_filename>s) and `TargetRubyVersion` ' \
                        '(%<target_ruby_version>s, which may be specified in ' \
                        '.rubocop.yml) should be equal.'
        MISSING_MSG = '`required_ruby_version` should be specified.'

        def_node_search :required_ruby_version, <<~PATTERN
          (send _ :required_ruby_version= $_)
        PATTERN

        def_node_matcher :defined_ruby_version, <<~PATTERN
          {$(str _) $(array (str _) (str _))
            (send (const (const nil? :Gem) :Requirement) :new $(str _))}
        PATTERN

        # rubocop:disable Metrics/AbcSize
        def on_new_investigation
          version_def = required_ruby_version(processed_source.ast).first

          if version_def
            ruby_version = extract_ruby_version(defined_ruby_version(version_def))
            return if !ruby_version || ruby_version == target_ruby_version.to_s

            add_offense(
              version_def.loc.expression,
              message: not_equal_message(ruby_version, target_ruby_version)
            )
          else
            range = source_range(processed_source.buffer, 1, 0)
            add_offense(range, message: MISSING_MSG)
          end
        end
        # rubocop:enable Metrics/AbcSize

        private

        def extract_ruby_version(required_ruby_version)
          return unless required_ruby_version

          if required_ruby_version.array_type?
            required_ruby_version = required_ruby_version.children.detect do |v|
              /[>=]/.match?(v.str_content)
            end
          end

          required_ruby_version.str_content.scan(/\d/).first(2).join('.')
        end

        def not_equal_message(required_ruby_version, target_ruby_version)
          format(
            NOT_EQUAL_MSG,
            required_ruby_version: required_ruby_version,
            gemspec_filename: File.basename(processed_source.file_path),
            target_ruby_version: target_ruby_version
          )
        end
      end
    end
  end
end
