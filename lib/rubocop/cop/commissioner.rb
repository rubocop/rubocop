# frozen_string_literal: true

module RuboCop
  module Cop
    # Commissioner class is responsible for processing the AST and delegating
    # work to the specified cops.
    class Commissioner
      include RuboCop::AST::Traversal

      CopError = Struct.new(:error, :line, :column)

      attr_reader :errors

      def initialize(cops, forces = [], options = {})
        @cops = cops
        @forces = forces
        @options = options
        @callbacks = {}

        reset_errors
      end

      # Create methods like :on_send, :on_super, etc. They will be called
      # during AST traversal and try to call corresponding methods on cops.
      # A call to `super` is used
      # to continue iterating over the children of a node.
      # However, if we know that a certain node type (like `int`) never has
      # child nodes, there is no reason to pay the cost of calling `super`.
      Parser::Meta::NODE_TYPES.each do |node_type|
        method_name = :"on_#{node_type}"
        next unless method_defined?(method_name)

        define_method(method_name) do |node|
          trigger_responding_cops(method_name, node)
          super(node) unless NO_CHILD_NODES.include?(node_type)
        end
      end

      def investigate(processed_source)
        reset_errors
        remove_irrelevant_cops(processed_source.file_path)
        reset_callbacks
        prepare(processed_source)
        invoke_custom_processing(@cops, processed_source)
        invoke_custom_processing(@forces, processed_source)
        walk(processed_source.ast) unless processed_source.blank?
        invoke_custom_post_walk_processing(@cops, processed_source)
        @cops.flat_map(&:offenses)
      end

      private

      def trigger_responding_cops(callback, node)
        @callbacks[callback] ||= @cops.select do |cop|
          cop.respond_to?(callback)
        end
        @callbacks[callback].each do |cop|
          with_cop_error_handling(cop, node) do
            cop.send(callback, node)
          end
        end
      end

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
      #
      # These custom processors are invoked before the AST traversal,
      # so they can build initial state that is later used by callbacks
      # during the AST traversal.
      def invoke_custom_processing(cops_or_forces, processed_source)
        cops_or_forces.each do |cop|
          next unless cop.respond_to?(:investigate)

          with_cop_error_handling(cop) do
            cop.investigate(processed_source)
          end
        end
      end

      # There are cops that require their own custom processing **after**
      # the AST traversal. By performing the walk before invoking these
      # custom processors, we allow these cops to build their own
      # state during the primary AST traversal instead of performing their
      # own AST traversals. Minimizing the number of walks is more efficient.
      #
      # If they define the #investigate_post_walk method, all input parameters
      # passed to the commissioner will be passed to the cop too in order to do
      # its own processing.
      def invoke_custom_post_walk_processing(cops, processed_source)
        cops.each do |cop|
          next unless cop.respond_to?(:investigate_post_walk)

          with_cop_error_handling(cop) do
            cop.investigate_post_walk(processed_source)
          end
        end
      end

      # Allow blind rescues here, since we're absorbing and packaging or
      # re-raising exceptions that can be raised from within the individual
      # cops' `#investigate` methods.
      def with_cop_error_handling(cop, node = nil)
        yield
      rescue StandardError => e
        raise e if @options[:raise_error]

        if node
          line = node.first_line
          column = node.loc.column
        end
        error = CopError.new(e, line, column)
        @errors[cop] << error
      end
    end
  end
end
