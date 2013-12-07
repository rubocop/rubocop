# encoding: utf-8

module Rubocop
  module Cop
    module Rails
      # This cop checks for the use of the read_attribute method.
      #
      # @example
      #
      #   # bad
      #   read_attributed(:attr)
      #
      #   # good
      #   self[:attr]
      class ReadAttribute < Cop
        MSG = 'Prefer self[:attribute] over read_attribute(:attribute).'

        def on_send(node)
          receiver, method_name, *_args = *node

          if receiver.nil? && method_name == :read_attribute
            add_offence(node, :selector)
          end
        end
      end
    end
  end
end
