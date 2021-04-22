# frozen_string_literal: true

module RuboCop
  module Cop
    module Bundler
      # Enforce that Gem version declarations are either required
      # or prohibited.
      #
      # @example EnforcedStyle: required (default)
      #  # bad
      #  gem 'rubocop'
      #
      #  # good
      #  gem 'rubocop', '~> 1.12'
      #
      #  # good
      #  gem 'rubocop', '>= 1.10.0'
      #
      #  # good
      #  gem 'rubocop', '>= 1.5.0', '< 1.10.0'
      #
      # @example EnforcedStyle: prohibited
      #  # good
      #  gem 'rubocop'
      #
      #  # bad
      #  gem 'rubocop', '~> 1.12'
      #
      #  # bad
      #  gem 'rubocop', '>= 1.10.0'
      #
      #  # bad
      #  gem 'rubocop', '>= 1.5.0', '< 1.10.0'
      #
      class GemVersionDeclaration < Base
        include ConfigurableEnforcedStyle

        REQUIRED_MSG = 'Gem version declaration is required.'
        PROHIBITED_MSG = 'Gem version declaration is prohibited.'
        VERSION_DECLARATION_REGEX = /^[~<>=]*\s?[0-9.]+/.freeze

        # @!method gem_declaration?(node)
        def_node_matcher :gem_declaration?, '(send nil? :gem str ...)'

        # @!method includes_version_declaration?(node)
        def_node_matcher :includes_version_declaration?, <<~PATTERN
          (send nil? :gem <(str #version_declaration?) ...>)
        PATTERN

        def on_send(node)
          return unless gem_declaration?(node)
          return if ignored_gem?(node)

          if offense?(node)
            add_offense(node)
            opposite_style_detected
          else
            correct_style_detected
          end
        end

        private

        def ignored_gem?(node)
          ignored_gems.include?(node.first_argument.value)
        end

        def ignored_gems
          Array(cop_config['IgnoredGems'])
        end

        def message(range)
          gem_declaration = range.source

          if required_style?
            format(REQUIRED_MSG, gem_declaration: gem_declaration)
          elsif prohibited_style?
            format(PROHIBITED_MSG, gem_declaration: gem_declaration)
          end
        end

        def offense?(node)
          (required_style? && !includes_version_declaration?(node)) ||
            (prohibited_style? && includes_version_declaration?(node))
        end

        def prohibited_style?
          style == :prohibited
        end

        def required_style?
          style == :required
        end

        def version_declaration?(expression)
          expression.match?(VERSION_DECLARATION_REGEX)
        end
      end
    end
  end
end
