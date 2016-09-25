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

        def on_send(node)
          receiver, method_name, *_args = *node
          return if receiver
          return unless [:read_attribute,
                         :write_attribute].include?(method_name)

          add_offense(node, :selector)
        end

        def message(node)
          _receiver, method_name, *_args = *node

          if method_name == :read_attribute
            format(MSG, 'self[:attr]', 'read_attribute(:attr)')
          else
            format(MSG, 'self[:attr] = val', 'write_attribute(:attr, val)')
          end
        end

        def autocorrect(node)
          _receiver, method_name, _body = *node

          case method_name
          when :read_attribute
            replacement = read_attribute_replacement(node)
          when :write_attribute
            replacement = write_attribute_replacement(node)
          end

          ->(corrector) { corrector.replace(node.source_range, replacement) }
        end

        private

        def read_attribute_replacement(node)
          _receiver, _method_name, body = *node

          "self[#{body.source}]"
        end

        def write_attribute_replacement(node)
          _receiver, _method_name, *args = *node
          name, value = *args

          "self[#{name.source}] = #{value.source}"
        end
      end
    end
  end
end
