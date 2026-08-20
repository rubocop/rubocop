# frozen_string_literal: true

module RuboCop
  module Cop
    # Shared machinery for cops that compare a call site's arguments against
    # a method signature from the project index (`Rubydex::Signature`).
    #
    # A signature is reduced to a shape - `[min, max, has_keywords]` where
    # `max` is nil for a rest parameter - and the number of positional
    # arguments a call passes is counted with Ruby's semantics for trailing
    # keyword hashes: keywords passed to a method with no keyword parameters
    # collapse into a single positional hash.
    module IndexedMethodArity
      private

      def arity_satisfied?(given, min, max)
        given >= min && (max.nil? || given <= max)
      end

      def expected_range(min, max)
        return "#{min}+" if max.nil?
        return min.to_s if min == max

        "#{min}..#{max}"
      end

      # The agreed `[min, max, has_keywords]` shape of an indexed member's
      # method definitions, or nil when the member is not backed by plain
      # method definitions (attr, alias), has no signature, forwards
      # arguments, or its definitions disagree on arity (e.g. reopened with
      # a different one).
      def indexed_member_shape(member)
        definitions = member.definitions.grep(Rubydex::MethodDefinition)
        return nil if definitions.empty?

        signature_shape(definitions.flat_map(&:signatures))
      end

      def signature_shape(signatures)
        shapes = signatures.filter_map { |signature| shape_for(signature) }.uniq
        shapes.one? ? shapes.first : nil
      end

      def shape_for(signature)
        return nil if signature.forward_parameter

        min = signature.positional_parameters.size + signature.post_parameters.size

        [min, maximum_positional(signature, min), keyword_parameters?(signature)]
      end

      def maximum_positional(signature, min)
        return nil if signature.rest_positional_parameter

        min + signature.optional_positional_parameters.size
      end

      def keyword_parameters?(signature)
        !signature.keyword_parameters.empty? ||
          !signature.optional_keyword_parameters.empty? ||
          !signature.rest_keyword_parameter.nil?
      end

      # The number of positional arguments the call passes, or nil when it
      # cannot be determined statically (argument forwarding).
      def positional_argument_count(node, callee_has_keywords)
        arguments = node.arguments
        return nil if forwards_arguments?(arguments)

        arguments = arguments[0...-1] if arguments.last&.block_pass_type?
        return arguments.size unless (keyword_hash = keyword_hash(arguments.last))
        return nil if double_splat?(keyword_hash)

        # A keyword-style hash passed to a method with no keyword parameters is
        # received as a single positional hash argument.
        callee_has_keywords ? arguments.size - 1 : arguments.size
      end

      def forwards_arguments?(arguments)
        arguments.any? do |argument|
          argument.type?(:splat, :forwarded_args, :forwarded_restarg, :forwarded_kwrestarg)
        end
      end

      def keyword_hash(node)
        node if node&.hash_type? && !node.braces?
      end

      def double_splat?(hash_node)
        hash_node.each_child_node.any?(&:kwsplat_type?)
      end
    end
  end
end
