# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Identifies `eql?` method definitions which do not
      # check for argument class which might lead to runtime errors.
      #
      # @example
      #
      #   # bad
      #   def eql?(other)
      #     other.name == name
      #   end
      #
      #   # bad
      #   def eql?(other)
      #     to_s == other.to_s
      #   end
      #
      #   # good
      #   def eql?(other)
      #     other.is_a?(self.class) && other.name == name
      #   end
      #
      #   # good
      #   def eql?(other)
      #     other.instance_of?(self.class) && to_s == other.to_s
      #   end
      class ObjectEqualityOverride < Base
        MSG = 'Check the class of `%<parameter_name>s` in `eql?`.'

        def on_def(node)
          unsafe_object_equality_override?(node) do |parameter_name|
            add_offense(node, message: format(MSG, parameter_name: parameter_name))
          end
        end

        # @!method unsafe_object_equality_override?(node)
        def_node_matcher :unsafe_object_equality_override?, <<~PATTERN
          (def :eql? (args (arg $_parameter_name)) !`#class_or_hash_check?(_parameter_name))
        PATTERN

        # @!method class_or_hash_check?(node, argument_name)
        def_node_matcher :class_or_hash_check?, <<~PATTERN
          {
            (send (lvar %1) {:is_a? :kind_of? :instance_of?} (send (self) :class))
            (send {nil? (self)} :instance_of? (send (lvar %1) :class))
            (send (send (lvar %1) :class) {:<= :<} (send (self) :class))
            (send <(send (lvar %1) :class) :== (send (self) :class)>)
            (send <(send {nil? (self)} :hash) :== (send (lvar %1) :hash)>)
          }
        PATTERN
      end
    end
  end
end
