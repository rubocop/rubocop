# encoding: utf-8

module Rubocop
  module Cop
    # Commissioner class is responsible for processing the AST and delagating
    # work to the specified cops.
    class Commissioner < Parser::AST::Processor
      attr_reader :errors

      def self.callback_methods
        Parser::AST::Processor.instance_methods.select do |method|
          method.to_s =~ /^on_/
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
          end
        EOS
      end

      def inspect(source_buffer, source, tokens, ast, comments)
        reset_errors
        process(ast) if ast
        process_source(source_buffer, source, tokens, ast, comments)
        @cops.reduce([]) do |offences, cop|
          offences.concat(cop.offences)
          offences
        end
      end

      private

      def reset_errors
        @errors = Hash.new { |hash, k| hash[k] = [] }
      end

      def process_source(source_buffer, source, tokens, ast, comments)
        @cops.each do |cop|
          if cop.respond_to?(:source_callback)
            cop.source_callback(source_buffer, source, tokens, ast, comments)
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
