# frozen_string_literal: true

module RuboCop
  module Cop
    # Commissioner class is responsible for processing the AST and delegating
    # work to the specified cops.
    class Commissioner
      include RuboCop::AST::Traversal

      CopError = Struct.new(:error, :line, :column)

      attr_reader :errors

      def self.callback_methods
        Parser::Meta::NODE_TYPES.map { |type| :"on_#{type}" }
      end

      def initialize(cops, forces = [], options = {})
        @cops = cops
        @forces = forces
        @options = options
        @callbacks = {}

        reset_errors
      end

      # In the dynamically generated methods below, a call to `super` is used
      # to continue iterating over the children of a node.
      # However, if we know that a certain node type (like `int`) never has
      # child nodes, there is no reason to pay the cost of calling `super`.
      no_child_callbacks = NO_CHILD_NODES.map do |type|
        :"on_#{type}"
      end

      callback_methods.each do |callback|
        next unless method_defined?(callback)
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{callback}(node)
            @callbacks[:"#{callback}"] ||= @cops.select do |cop|
              cop.respond_to?(:"#{callback}")
            end
            @callbacks[:#{callback}].each do |cop|
              with_cop_error_handling(cop, node) do
                cop.send(:#{callback}, node)
              end
            end

            #{!no_child_callbacks.include?(callback) && 'super'}
          end
        RUBY
      end

      def investigate(processed_source)
        reset_errors
        remove_irrelevant_cops(processed_source.buffer.name)
        reset_callbacks
        prepare(processed_source)
        invoke_custom_processing(@cops, processed_source)
        invoke_custom_processing(@forces, processed_source)
        walk(processed_source.ast) if processed_source.ast
        @cops.flat_map(&:offenses)
      end

      private

      def reset_errors
        @errors = Hash.new { |hash, k| hash[k] = [] }
      end

      def remove_irrelevant_cops(filename)
        @cops.reject! { |cop| cop.excluded_file?(filename) }
        @cops.reject! do |cop|
          cop.class.respond_to?(:support_target_ruby_version?) &&
            !cop.class.support_target_ruby_version?(cop.target_ruby_version)
        end
        @cops.reject! do |cop|
          cop.class.respond_to?(:support_target_rails_version?) &&
            !cop.class.support_target_rails_version?(cop.target_rails_version)
        end
      end

      def reset_callbacks
        @callbacks.clear
      end

      # TODO: Bad design.
      def prepare(processed_source)
        @cops.each { |cop| cop.processed_source = processed_source }
      end

      # There are cops/forces that require their own custom processing.
      # If they define the #investigate method, all input parameters passed
      # to the commissioner will be passed to the cop too in order to do
      # its own processing.
      def invoke_custom_processing(cops_or_forces, processed_source)
        cops_or_forces.each do |cop|
          next unless cop.respond_to?(:investigate)

          with_cop_error_handling(cop) do
            cop.investigate(processed_source)
          end
        end
      end

      # Allow blind rescues here, since we're absorbing and packaging or
      # re-raising exceptions that can be raised from within the individual
      # cops' `#investigate` methods.
      #
      # rubocop:disable Lint/RescueWithoutErrorClass
      def with_cop_error_handling(cop, node = nil)
        yield
      rescue => e
        raise e if @options[:raise_error]
        if node
          line = node.loc.line
          column = node.loc.column
        end
        error = CopError.new(e, line, column)
        @errors[cop] << error
      end
      # rubocop:enable Lint/RescueWithoutErrorClass
    end
  end
end
