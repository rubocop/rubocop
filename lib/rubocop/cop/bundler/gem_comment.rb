# frozen_string_literal: true

module RuboCop
  module Cop
    module Bundler
      # Add a comment describing each gem in your Gemfile.
      #
      # @example OnlyIfVersionRestricted: false (default)
      #   # bad
      #
      #   gem 'foo'
      #
      #   # good
      #
      #   # Helpers for the foo things.
      #   gem 'foo'
      #
      # @example OnlyIfVersionRestricted: true
      #   # bad
      #
      #   gem 'foo', '>= 2.1'
      #
      #   # good
      #
      #   # Version 2.1 introduces breaking change bar
      #   gem 'foo', '< 2.1'
      #
      class GemComment < Cop
        include DefNode

        MSG = 'Missing gem description comment.'

        def_node_matcher :gem_declaration?, '(send nil? :gem str ...)'

        def on_send(node)
          return unless gem_declaration?(node)
          return if ignored_gem?(node)
          return if commented?(node)
          return if cop_config['OnlyIfVersionRestricted'] && !version_restricted_gem?(node)

          add_offense(node)
        end

        private

        def commented?(node)
          preceding_lines = preceding_lines(node)
          preceding_comment?(node, preceding_lines.last)
        end

        # The args node1 & node2 may represent a RuboCop::AST::Node
        # or a Parser::Source::Comment. Both respond to #loc.
        def precede?(node1, node2)
          node2.loc.line - node1.loc.line == 1
        end

        def preceding_lines(node)
          processed_source.ast_with_comments[node].select do |line|
            line.loc.line < node.loc.line
          end
        end

        def preceding_comment?(node1, node2)
          node1 && node2 && precede?(node2, node1) &&
            comment_line?(node2.loc.expression.source)
        end

        def ignored_gem?(node)
          ignored_gems = Array(cop_config['IgnoredGems'])
          ignored_gems.include?(node.first_argument.value)
        end

        # Besides the gem name, all other *positional* arguments to `gem` are version restrictions,
        # as long as it has one we know there's a version restriction.
        def version_restricted_gem?(send_node)
          # arguments[0] is the gem name
          send_node.arguments[1]&.str_type? == true
        end
      end
    end
  end
end
