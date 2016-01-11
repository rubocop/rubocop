# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    # Commissioner class is responsible for processing the AST and delegating
    # work to the specified cops.
    class Commissioner < Parser::AST::Processor
      attr_reader :errors

      def self.callback_methods
        Parser::Meta::NODE_TYPES.map { |type| "on_#{type}" }
      end

      # Methods that are not defined in Parser::AST::Processor
      # won't have a `super` to call. So we should not attempt
      # to invoke `super` when defining them.
      def self.call_super(callback)
        if Parser::AST::Processor.method_defined?(callback)
          'super'
        else
          ''
        end
      end

      def initialize(cops, forces, options = {})
        @cops = cops
        @forces = forces
        @options = options
        reset_errors
      end

      callback_methods.each do |callback|
        class_eval <<-EOS, __FILE__, __LINE__
          def #{callback}(node)
            @cops.each do |cop|
              next unless cop.respond_to?(:#{callback})
              with_cop_error_handling(cop) do
                cop.send(:#{callback}, node)
              end
            end

            #{call_super(callback)}
          end
        EOS
      end

      def investigate(processed_source)
        reset_errors
        remove_irrelevant_cops(processed_source.buffer.name)
        prepare(processed_source)
        invoke_custom_processing(@cops, processed_source)
        invoke_custom_processing(@forces, processed_source)
        process(processed_source.ast) if processed_source.ast
        @cops.flat_map(&:offenses)
      end

      private

      def reset_errors
        @errors = Hash.new { |hash, k| hash[k] = [] }
      end

      def remove_irrelevant_cops(filename)
        @cops.reject! { |cop| cop.excluded_file?(filename) }
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

      def with_cop_error_handling(cop)
        yield
      rescue => e
        raise e if @options[:raise_error]
        @errors[cop] << e
      end
    end
  end
end
