# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for a file requiring itself with `require_relative`.
      #
      # @example
      #
      #   # bad
      #
      #   # foo.rb
      #   require_relative 'foo'
      #   require_relative 'bar'
      #
      #   # good
      #
      #   # foo.rb
      #   require_relative 'bar'
      #
      class RequireRelativeSelfPath < Base
        include RangeHelp
        extend AutoCorrector

        MSG = 'Remove the `require_relative` that requires itself.'
        RESTRICT_ON_SEND = %i[require_relative].freeze
        BODY_PARENTS = %i[
          any_block any_def class module sclass when in_pattern resbody while until for
        ].freeze

        def on_send(node)
          return unless (required_feature = node.first_argument)
          return unless required_feature.respond_to?(:value)
          return unless same_file?(processed_source.file_path, required_feature.value)

          add_offense(node) do |corrector|
            range = removal_range(node)
            corrector.remove(range) if range
          end
        end

        private

        def removal_range(node)
          source = node.source_range
          range = range_for_statement_removal(source)
          return range if !node.parent || (node.parent.type?(:begin, :kwbegin) && !node.value_used?)
          return unless range == range_by_whole_lines(source, include_final_newline: true)

          range if statement?(node)
        end

        # Whether the node is a statement in the body of its parent, which stays valid without
        # it. An operand can't go: the parent would take the next line in its place.
        def statement?(node)
          parent = node.parent

          case parent.type
          when :begin then !parent.loc?(:begin)
          when :kwbegin, :rescue, :ensure then true
          when :if then !parent.ternary? && !parent.condition.equal?(node)
          when :case, :case_match then parent.else_branch.equal?(node)
          else body?(parent, node)
          end
        end

        def body?(parent, node)
          return false unless parent.type?(*BODY_PARENTS) && parent.body.equal?(node)
          # An endless method and a modifier `rescue` have nothing after the body to end them.
          return !parent.endless? if parent.any_def_type?

          !parent.resbody_type? || begins_its_line?(parent.source_range)
        end

        def same_file?(file_path, required_feature)
          return false unless File.extname(file_path) == '.rb'

          # `require_relative` is resolved relative to the current file's directory, so a
          # bare `foo`/`foo.rb` (no path separator) requires the current file itself. Compare
          # against the basename so this works whether `file_path` is relative or absolute.
          basename = File.basename(file_path, '.rb')
          required_feature == basename || required_feature == "#{basename}.rb"
        end
      end
    end
  end
end
