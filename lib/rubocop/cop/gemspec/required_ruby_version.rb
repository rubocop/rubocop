# frozen_string_literal: true

module RuboCop
  module Cop
    module Gemspec
      # Checks that `required_ruby_version` of gemspec and `TargetRubyVersion`
      # of .rubocop.yml are equal.
      # Thereby, RuboCop to perform static analysis working on the version
      # required by gemspec.
      #
      # @example
      #   # When `TargetRubyVersion` of .rubocop.yml is `2.3`.
      #
      #   # bad
      #   Gem::Specification.new do |spec|
      #     spec.required_ruby_version = '>= 2.2.0'
      #   end
      #
      #   # bad
      #   Gem::Specification.new do |spec|
      #     spec.required_ruby_version = '>= 2.4.0'
      #   end
      #
      #   # good
      #   Gem::Specification.new do |spec|
      #     spec.required_ruby_version = '>= 2.3.0'
      #   end
      #
      #   # good
      #   Gem::Specification.new do |spec|
      #     spec.required_ruby_version = '>= 2.3'
      #   end
      #
      #   # good
      #   Gem::Specification.new do |spec|
      #     spec.required_ruby_version = ['>= 2.3.0', '< 2.5.0']
      #   end
      class RequiredRubyVersion < Cop
        MSG = '`required_ruby_version` (%<required_ruby_version>s, ' \
              'declared in %<gemspec_filename>s) and `TargetRubyVersion` ' \
              '(%<target_ruby_version>s, which may be specified in ' \
              '.rubocop.yml) should be equal.'.freeze

        def_node_search :required_ruby_version, <<-PATTERN
          (send _ :required_ruby_version= ${(str _) (array (str _))})
        PATTERN

        def investigate(processed_source)
          required_ruby_version(processed_source.ast) do |version|
            ruby_version = extract_ruby_version(version)

            return if ruby_version == target_ruby_version.to_s

            add_offense(
              processed_source.ast,
              location: version.loc.expression,
              message: message(ruby_version, target_ruby_version)
            )
          end
        end

        private

        def extract_ruby_version(required_ruby_version)
          if required_ruby_version.array_type?
            required_ruby_version = required_ruby_version.children.detect do |v|
              v.str_content =~ /[>=]/
            end
          end

          required_ruby_version.str_content.match(/(\d\.\d)/)[1]
        end

        def message(required_ruby_version, target_ruby_version)
          format(
            MSG,
            required_ruby_version: required_ruby_version,
            gemspec_filename: File.basename(processed_source.file_path),
            target_ruby_version: target_ruby_version
          )
        end
      end
    end
  end
end
