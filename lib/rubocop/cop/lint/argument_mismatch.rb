# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for calls that pass the wrong number of positional arguments to a
      # method whose definition is known from the project index.
      #
      # The check is powered by the project-wide index, so it only runs when
      # `AllCops/UseProjectIndex` is enabled and the `rubydex` gem is installed.
      # Without the index the cop does nothing.
      #
      # Only calls on constant receivers (`Foo.bar`) are considered, and only
      # when the receiver resolves in the index, its entire ancestry is resolved
      # (so a method inherited from a gem or the standard library never produces
      # an offense), and the called method resolves to a single, unambiguous
      # signature. Calls that forward arguments (`*`, `**`, `...`) are skipped
      # because their argument count is not statically known. Keyword arguments
      # passed to a method that declares no keyword parameters are counted as the
      # single positional hash they collapse into, matching Ruby's semantics.
      #
      # Constructor calls (`Foo.new`) and keyword-argument validation are out of
      # scope: only positional arity of explicitly defined singleton methods is
      # checked.
      #
      # @example
      #   # Given the project defines:
      #   #   class Report
      #   #     def self.generate(source, format); end
      #   #   end
      #
      #   # bad
      #   Report.generate(source)
      #
      #   # bad
      #   Report.generate(source, :pdf, :extra)
      #
      #   # good
      #   Report.generate(source, :pdf)
      #
      class ArgumentMismatch < Base
        include ProjectIndexHelp
        include IndexedMethodArity

        MSG = 'Wrong number of arguments to `%<method>s` (given %<given>d, expected %<expected>s).'

        def on_send(node)
          return unless project_index
          return unless node.receiver&.const_type?

          shape = resolved_signature_shape(node)
          return unless shape

          min, max, has_keywords = shape
          given = positional_argument_count(node, has_keywords)
          return if given.nil? || arity_satisfied?(given, min, max)

          add_offense(node.loc.selector, message: message(node, given, min, max))
        end
        alias on_csend on_send

        private

        def message(node, given, min, max)
          format(MSG, method: node.method_name, given: given, expected: expected_range(min, max))
        end

        # `[min, max, has_keywords]` for the called singleton method, or nil when
        # the receiver or its ancestry is not resolved.
        def resolved_signature_shape(node)
          declaration = resolve_constant_in_index(node.receiver)
          return nil unless declaration.is_a?(Rubydex::Namespace)
          return nil unless fully_resolved_index_ancestry?(declaration)

          singleton_signature_shape(declaration, node.method_name)
        rescue StandardError
          nil
        end

        def singleton_signature_shape(declaration, method_name)
          member = indexed_singleton_member(declaration, "#{method_name}()")
          return nil unless member

          indexed_member_shape(member)
        end
      end
    end
  end
end
