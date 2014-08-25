# encoding: utf-8

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
        class_eval <<-EOS
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
        prepare(processed_source)
        invoke_custom_processing(@cops, processed_source)
        invoke_custom_processing(@forces, processed_source)
        process(processed_source.ast) if processed_source.ast
        @cops.each_with_object([]) do |cop, offenses|
          filename = processed_source.buffer.name
          # ignore files that are of no interest to the cop in question
          offenses.concat(cop.offenses) if cop.relevant_file?(filename)
        end
      end

      private

      def reset_errors
        @errors = Hash.new { |hash, k| hash[k] = [] }
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

          if cop.respond_to?(:relevant_file?)
            # ignore files that are of no interest to the cop in question
            filename = processed_source.buffer.name
            next unless cop.relevant_file?(filename)
          end

          with_cop_error_handling(cop) do
            cop.investigate(processed_source)
          end
        end
      end

      def with_cop_error_handling(cop)
        yield
      rescue => e
        if @options[:raise_error]
          raise e
        else
          @errors[cop] << e
        end
      end
    end
  end
end
