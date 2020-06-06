# frozen_string_literal: true

module RuboCop
  module Cop
    # Commissioner class is responsible for processing the AST and delegating
    # work to the specified cops.
    class Commissioner
      include RuboCop::AST::Traversal

      # How a Commissioner returns the results of the investigation
      # as a list of Cop::InvestigationReport and any errors caught
      # during the investigation.
      # Immutable
      # Consider creation API private
      InvestigationReport = Struct.new(:processed_source, :cop_reports, :errors) do
        def cops
          @cops ||= cop_reports.map(&:cop)
        end

        def offenses_per_cop
          @offenses_per_cop ||= cop_reports.map(&:offenses)
        end

        def correctors
          @correctors ||= cop_reports.map(&:corrector)
        end

        def offenses
          @offenses ||= offenses_per_cop.flatten(1)
        end

        def merge(investigation)
          InvestigationReport.new(processed_source,
                                  cop_reports + investigation.cop_reports,
                                  errors + investigation.errors)
        end
      end

      attr_reader :errors

      def initialize(cops, forces = [], options = {})
        @cops = cops
        @forces = forces
        @options = options
        @callbacks = {}

        reset
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

      # @return [InvestigationReport]
      def investigate(processed_source)
        reset

        @cops.each { |cop| cop.send :begin_investigation, processed_source }
        if processed_source.valid_syntax?
          invoke(:on_new_investigation, @cops)
          invoke(:investigate, @forces, processed_source)
          walk(processed_source.ast) unless @cops.empty?
          invoke(:on_investigation_end, @cops)
        else
          invoke(:on_other_file, @cops)
        end
        reports = @cops.map { |cop| cop.send(:complete_investigation) }
        InvestigationReport.new(processed_source, reports, @errors)
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

      def reset
        @errors = []
        @callbacks = {}
      end

      def invoke(callback, cops, *args)
        cops.each do |cop|
          with_cop_error_handling(cop) do
            cop.send(callback, *args)
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

        err = ErrorWithAnalyzedFileLocation.new(cause: e, node: node, cop: cop)
        @errors << err
      end
    end
  end
end
