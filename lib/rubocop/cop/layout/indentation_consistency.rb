# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # This cop checks for inconsistent indentation.
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

        # Not all nodes define `bare_access_modifier?` (for example,
        # `RuboCop::AST::DefNode` does not), so we must check `send_type?` first
        # to avoid a NoMethodError.
        def bare_access_modifier?(node)
          node.send_type? && node.bare_access_modifier?
        end

        # Returns an integer representing the correct indentation, or nil to
        # indicate that the correct indentation is that of the first child that
        # is not an access modifier.
        def base_column_for_normal_style(node)
          first_child = node.children.first
          return unless first_child && bare_access_modifier?(first_child)

          # If, as is most common, the access modifier is indented deeper than
          # the module (`access_modifier_indent > module_indent`) then the
          # indentation of the access modifier determines the correct
          # indentation.
          #
          # Otherwise, in the rare event that the access modifier is outdented
          # to the level of the module (see `AccessModifierIndentation` cop) we
          # return nil so that `check_alignment` will derive the correct
          # indentation from the first child that is not an access modifier.
          module_indent = display_column(node.parent.source_range)
          access_modifier_indent = display_column(first_child.source_range)
          access_modifier_indent if access_modifier_indent > module_indent
        end

        def check(node)
          if style == :rails
            check_rails_style(node)
          else
            check_normal_style(node)
          end
        end

        def check_normal_style(node)
          check_alignment(
            node.children.reject { |child| bare_access_modifier?(child) },
            base_column_for_normal_style(node)
          )
        end

        def check_rails_style(node)
          children_to_check = [[]]
          node.children.each do |child|
            # Modifier nodes have special indentation and will be checked by
            # the AccessModifierIndentation cop. This cop uses them as dividers
            # in rails mode. Then consistency is checked only within each
            # section delimited by a modifier node.
            if bare_access_modifier?(child)
              children_to_check << []
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
