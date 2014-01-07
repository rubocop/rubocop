# encoding: utf-8

module Rubocop
  module Cop
    # Commissioner class is responsible for processing the AST and delagating
    # work to the specified cops.
    class Commissioner < Parser::AST::Processor
      attr_reader :errors

      METHODS_NOT_DEFINED_IN_PARSER_PROCESSOR = [
        :on_sym, :on_str, :on_int, :on_float
      ]

      def self.callback_methods
        Parser::AST::Processor.instance_methods.select do |method|
          method.to_s =~ /^on_/
        end + METHODS_NOT_DEFINED_IN_PARSER_PROCESSOR
      end

      # Methods that are not defined in Parser::AST::Processor
      # won't have a `super` to call. So we should not attempt
      # to invoke `super` when defining them.
      def self.call_super(callback)
        if METHODS_NOT_DEFINED_IN_PARSER_PROCESSOR.include?(callback)
          ''
        else
          'super'
        end
      end

      def initialize(cops, options = {})
        @cops = cops
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
        invoke_cops_callback(processed_source)
        process(processed_source.ast) if processed_source.ast
        @cops.each_with_object([]) do |cop, offences|
          filename = processed_source.buffer.name
          # ignore files that are of no interest to the cop in question
          offences.concat(cop.offences) if cop.relevant_file?(filename)
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

      # There are cops that require their own custom processing.
      # If they define the #investigate method, all input parameters passed
      # to the commissioner will be passed to the cop too in order to do
      # its own processing.
      def invoke_cops_callback(processed_source)
        @cops.each do |cop|
          next unless cop.respond_to?(:investigate)

          filename = processed_source.buffer.name

          # ignore files that are of no interest to the cop in question
          next unless cop.relevant_file?(filename)

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
