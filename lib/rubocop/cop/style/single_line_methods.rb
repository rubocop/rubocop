# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for single-line method definitions that contain a body.
      # It will accept single-line methods with no body.
      #
      # Endless methods added in Ruby 3.0 are also accepted by this cop.
      #
      # If `Style/EndlessMethod` is enabled with `EnforcedStyle: allow_single_line` or
      # `allow_always`, single-line methods will be auto-corrected to endless
      # methods if there is only one statement in the body.
      #
      # @example
      #   # bad
      #   def some_method; body end
      #   def link_to(url); {:name => url}; end
      #   def @table.columns; super; end
      #
      #   # good
      #   def self.resource_class=(klass); end
      #   def @table.columns; end
      #   def some_method() = body
      #
      # @example AllowIfMethodIsEmpty: true (default)
      #   # good
      #   def no_op; end
      #
      # @example AllowIfMethodIsEmpty: false
      #   # bad
      #   def no_op; end
      #
      class SingleLineMethods < Base
        include Alignment
        extend AutoCorrector

        MSG = 'Avoid single-line method definitions.'

        def on_def(node)
          return unless node.single_line?
          return if node.endless?
          return if allow_empty? && !node.body

          add_offense(node) do |corrector|
            autocorrect(corrector, node)
          end
        end
        alias on_defs on_def

        private

        def autocorrect(corrector, node)
          if correct_to_endless?(node.body)
            correct_to_endless(corrector, node)
          else
            correct_to_multiline(corrector, node)
          end
        end

        def allow_empty?
          cop_config['AllowIfMethodIsEmpty']
        end

        def correct_to_endless?(body_node)
          return false if target_ruby_version < 3.0

          endless_method_config = config.for_cop('Style/EndlessMethod')

          return false unless endless_method_config['Enabled']
          return false if endless_method_config['EnforcedStyle'] == 'disallow'
          return false unless body_node

          !(body_node.begin_type? || body_node.kwbegin_type?)
        end

        def correct_to_multiline(corrector, node)
          each_part(node.body) do |part|
            LineBreakCorrector.break_line_before(
              range: part, node: node, corrector: corrector,
              configured_width: configured_indentation_width
            )
          end

          LineBreakCorrector.break_line_before(
            range: node.loc.end, node: node, corrector: corrector,
            indent_steps: 0, configured_width: configured_indentation_width
          )

          move_comment(node, corrector)
        end

        def correct_to_endless(corrector, node)
          self_receiver = node.self_receiver? ? 'self.' : ''
          arguments = node.arguments.any? ? node.arguments.source : '()'
          replacement = "def #{self_receiver}#{node.method_name}#{arguments} = #{node.body.source}"
          corrector.replace(node, replacement)
        end

        def each_part(body)
          return unless body

          if body.begin_type?
            body.each_child_node { |part| yield part.source_range }
          else
            yield body.source_range
          end
        end

        def move_comment(node, corrector)
          LineBreakCorrector.move_comment(
            eol_comment: processed_source.comment_at_line(node.source_range.line),
            node: node, corrector: corrector
          )
        end
      end
    end
  end
end
