# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # This cops checks for inconsistent indentation.
      #
      # The difference between `rails` and `normal` is that the `rails` style
      # prescribes that in classes and modules the `protected` and `private`
      # modifier keywords shall be indented the same as public methods and that
      # protected and private members shall be indented one step more than the
      # modifiers. Other than that, both styles mean that entities on the same
      # logical depth shall have the same indentation.
      #
      # @example EnforcedStyle: normal (default)
      #   # bad
      #   class A
      #     def test
      #       puts 'hello'
      #        puts 'world'
      #     end
      #   end
      #
      #   # bad
      #   class A
      #     def test
      #       puts 'hello'
      #       puts 'world'
      #     end
      #
      #     protected
      #
      #       def foo
      #       end
      #
      #     private
      #
      #       def bar
      #       end
      #   end
      #
      #   # good
      #   class A
      #     def test
      #       puts 'hello'
      #       puts 'world'
      #     end
      #   end
      #
      #   # good
      #   class A
      #     def test
      #       puts 'hello'
      #       puts 'world'
      #     end
      #
      #     protected
      #
      #     def foo
      #     end
      #
      #     private
      #
      #     def bar
      #     end
      #   end
      #
      # @example EnforcedStyle: rails
      #   # bad
      #   class A
      #     def test
      #       puts 'hello'
      #        puts 'world'
      #     end
      #   end
      #
      #   # bad
      #   class A
      #     def test
      #       puts 'hello'
      #       puts 'world'
      #     end
      #
      #     protected
      #
      #     def foo
      #     end
      #
      #     private
      #
      #     def bar
      #     end
      #   end
      #
      #   # good
      #   class A
      #     def test
      #       puts 'hello'
      #       puts 'world'
      #     end
      #   end
      #
      #   # good
      #   class A
      #     def test
      #       puts 'hello'
      #       puts 'world'
      #     end
      #
      #     protected
      #
      #       def foo
      #       end
      #
      #     private
      #
      #       def bar
      #       end
      #   end
      class IndentationConsistency < Cop
        include Alignment
        include ConfigurableEnforcedStyle

        MSG = 'Inconsistent indentation detected.'.freeze

        def on_begin(node)
          check(node)
        end

        def on_kwbegin(node)
          check(node)
        end

        def autocorrect(node)
          AlignmentCorrector.correct(processed_source, node, column_delta)
        end

        private

        def check(node)
          children_to_check = [[]]
          node.children.each do |child|
            # Modifier nodes have special indentation and will be checked by
            # the AccessModifierIndentation cop. This cop uses them as dividers
            # in rails mode. Then consistency is checked only within each
            # section delimited by a modifier node.
            if child.send_type? && child.access_modifier?
              children_to_check << [] if style == :rails
            else
              children_to_check.last << child
            end
          end
          children_to_check.each { |group| check_alignment(group) }
        end
      end
    end
  end
end
