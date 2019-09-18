# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Prefer a single-line format for class definitions with no body.

      # @example ExceptionClassOnly: true (default)
      #   # bad
      #   class FooError < StandardError
      #   end
      #
      #   # good
      #   class FooError < StandardError; end
      #
      #   class Foo < Bar; end
      #
      #   class Foo < Bar
      #   end
      #
      # @example ExceptionClassOnly: false
      #   # bad
      #   class FooError < StandardError
      #   end
      #
      #   class Foo < Bar
      #   end
      #
      #   # good
      #   class FooError < StandardError; end
      #
      #   class Foo < Bar; end
      class EmptyClass < Cop
        MSG = 'Use a single-line format for class definitions with no body.'

        def on_class(node)
          return if node.single_line?

          klass, _parent, body = node.children

          return if body

          return exception_only_flow(node, klass) if exception_class_only?

          add_offense(node)
        end

        def autocorrect(node)
          klass, parent, _body = node.children

          return if exception_class_only? && !exception_class?(klass.source)

          replacement = build_replacment(klass, parent)

          lambda do |corrector|
            corrector.replace(node.source_range, replacement)
          end
        end

        private

        def build_replacment(klass, parent)
          middle_part = if parent?(parent)
                          " < #{parent.source};"
                        else
                          ';'
                        end

          "class #{klass.source}#{middle_part} end"
        end

        def parent?(parent)
          parent&.source
        end

        def exception_only_flow(node, klass)
          add_offense(node) if exception_class?(klass.source)
        end

        def exception_class?(klass_str)
          klass_str =~ /.*(Error|Exception)\z/
        end

        def exception_class_only?
          cop_config['ExceptionClassOnly']
        end
      end
    end
  end
end
