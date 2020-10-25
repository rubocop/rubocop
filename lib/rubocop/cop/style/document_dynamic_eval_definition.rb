# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # When using `class_eval` (or other `eval`) with string interpolation,
      # add a comment block showing its appearance if interpolated (a practice used in Rails code).
      #
      # @example
      #   # from activesupport/lib/active_support/core_ext/string/output_safety.rb
      #
      #   # bad
      #   UNSAFE_STRING_METHODS.each do |unsafe_method|
      #     if 'String'.respond_to?(unsafe_method)
      #       class_eval <<-EOT, __FILE__, __LINE__ + 1
      #         def #{unsafe_method}(*params, &block)
      #           to_str.#{unsafe_method}(*params, &block)
      #         end
      #
      #         def #{unsafe_method}!(*params)
      #           @dirty = true
      #           super
      #         end
      #       EOT
      #     end
      #   end
      #
      #   # good
      #   UNSAFE_STRING_METHODS.each do |unsafe_method|
      #     if 'String'.respond_to?(unsafe_method)
      #       class_eval <<-EOT, __FILE__, __LINE__ + 1
      #         def #{unsafe_method}(*params, &block)       # def capitalize(*params, &block)
      #           to_str.#{unsafe_method}(*params, &block)  #   to_str.capitalize(*params, &block)
      #         end                                         # end
      #
      #         def #{unsafe_method}!(*params)              # def capitalize!(*params)
      #           @dirty = true                             #   @dirty = true
      #           super                                     #   super
      #         end                                         # end
      #       EOT
      #     end
      #   end
      #
      class DocumentDynamicEvalDefinition < Base
        MSG = 'Add a comment block showing its appearance if interpolated.'

        RESTRICT_ON_SEND = %i[eval class_eval module_eval instance_eval].freeze

        def on_send(node)
          arg_node = node.first_argument
          return unless arg_node&.dstr_type?

          add_offense(node.loc.selector) unless comment_docs?(arg_node)
        end

        private

        def comment_docs?(node)
          node.each_child_node(:begin).all? do |begin_node|
            source_line = processed_source.lines[begin_node.first_line - 1]
            source_line.match?(/\s*#[^{]+/)
          end
        end
      end
    end
  end
end
