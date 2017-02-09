# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks for the use of the read_attribute or
      # write_attribute methods.
      #
      # @example
      #
      #   # bad
      #   x = read_attribute(:attr)
      #   write_attribute(:attr, val)
      #
      #   # good
      #   x = self[:attr]
      #   self[:attr] = val
      class ReadWriteAttribute < Cop
        MSG = 'Prefer `%s` over `%s`.'.freeze

        def_node_matcher :read_write_attribute?, <<-PATTERN
          {
            (send nil :read_attribute _)
            (send nil :write_attribute _ _)
          }
        PATTERN

        def on_send(node)
          return unless read_write_attribute?(node)

          add_offense(node, :selector)
        end

        private

        def message(node)
          if node.method?(:read_attribute)
            format(MSG, 'self[:attr]', 'read_attribute(:attr)')
          else
            format(MSG, 'self[:attr] = val', 'write_attribute(:attr, val)')
          end
        end

        def autocorrect(node)
          case node.method_name
          when :read_attribute
            replacement = read_attribute_replacement(node)
          when :write_attribute
            replacement = write_attribute_replacement(node)
          end

          ->(corrector) { corrector.replace(node.source_range, replacement) }
        end

        def read_attribute_replacement(node)
          "self[#{node.first_argument.source}]"
        end

        def write_attribute_replacement(node)
          "self[#{node.first_argument.source}] = #{node.last_argument.source}"
        end
      end
    end
  end
end
