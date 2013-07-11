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
              if cop.respond_to?(:#{callback})
                delegate_to(cop, :#{callback}, node)
              end
            end

            #{call_super(callback)}
          end
        EOS
      end

      def investigate(source_buffer, source, tokens, ast, comments)
        reset_errors
        process(ast) if ast
        invoke_cops_callback(source_buffer, source, tokens, ast, comments)
        @cops.reduce([]) do |offences, cop|
          offences.concat(cop.offences)
          offences
        end
      end

      private

      def reset_errors
        @errors = Hash.new { |hash, k| hash[k] = [] }
      end

      # There are cops that require their own custom processing.
      # If they define the #investigate method all input parameters passed
      # to the commissioner will be passed to the cop too in order to do
      # its own processing.
      def invoke_cops_callback(source_buffer, source, tokens, ast, comments)
        @cops.each do |cop|
          if cop.respond_to?(:investigate)
            cop.investigate(source_buffer, source, tokens, ast, comments)
          end
        end
      end

      def delegate_to(cop, callback, node)
        cop.send callback, node
      rescue => e
        if @options[:raise_error]
          fail e
        else
          @errors[cop] << e
        end
      end
    end
  end
end
