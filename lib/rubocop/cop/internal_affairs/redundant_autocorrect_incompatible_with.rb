# frozen_string_literal: true

module RuboCop
  module Cop
    module InternalAffairs
      # Checks for cops that are declared as incompatible for autocorrection by
      # both cops of the pair. One declaration is enough: when either cop has
      # been applied, the corrections of the other are held back until the next
      # pass.
      #
      # The declaration that is reported is the one in the cop whose name comes
      # second in alphabetical order.
      #
      # @example
      #   # bad
      #   class Bar < Base
      #     def self.autocorrect_incompatible_with
      #       [Style::Foo]
      #     end
      #   end
      #
      #   class Foo < Base
      #     def self.autocorrect_incompatible_with
      #       [Style::Bar]
      #     end
      #   end
      #
      #   # good
      #   class Bar < Base
      #     def self.autocorrect_incompatible_with
      #       [Style::Foo]
      #     end
      #   end
      #
      #   class Foo < Base
      #   end
      #
      class RedundantAutocorrectIncompatibleWith < Base
        MSG = '`%<other>s` already declares that it is incompatible with this cop.'

        def on_defs(node)
          return unless declaration?(node) && (own = defining_cop_name(node))

          node.body.each_child_node(:const) do |const|
            other = qualified_name(const.const_name, own)
            next unless own > other && declared_by?(other, own)

            add_offense(const, message: format(MSG, other: other))
          end
        end

        private

        def declaration?(node)
          node.method?(:autocorrect_incompatible_with) && node.receiver.self_type? &&
            node.body&.array_type?
        end

        # @return [String, nil] the name of the cop that the method is defined in
        def defining_cop_name(node)
          department, name = node.parent_module_name&.split('::')&.last(2)

          "#{department}/#{name}" if name
        end

        # A cop of the same department can be given without the department.
        def qualified_name(const_name, cop_name)
          department, name = const_name.split('::').last(2)
          return "#{department}/#{name}" if name

          "#{cop_name.split('/').first}/#{department}"
        end

        def declared_by?(other, cop_name)
          cop_class = Registry.global.find_by_cop_name(other)
          return false unless cop_class

          cop_class.autocorrect_incompatible_with.any? { |cop| cop.cop_name == cop_name }
        end
      end
    end
  end
end
