# frozen_string_literal: true

require 'uri'
require_relative 'legacy/corrections_proxy'

module RuboCop
  module Cop
    # @deprecated Use Cop::Base instead
    # Legacy scaffold for Cops.
    # See https://docs.rubocop.org/rubocop/v1_upgrade_notes.html
    class Cop < Base
      attr_reader :offenses

      exclude_from_registry

      # @deprecated
      Correction = Struct.new(:lambda, :node, :cop) do
        def call(corrector)
          lambda.call(corrector)
        rescue StandardError => e
          raise ErrorWithAnalyzedFileLocation.new(cause: e, node: node, cop: cop)
        end
      end

      def self.support_autocorrect?
        method_defined?(:autocorrect)
      end

      def self.joining_forces
        return unless method_defined?(:join_force?)

        cop = new
        Force.all.select { |force_class| cop.join_force?(force_class) }
      end

      ### Deprecated registry access

      # @deprecated Use Registry.global
      def self.registry
        Registry.global
      end

      # @deprecated Use Registry.all
      def self.all
        Registry.all
      end

      # @deprecated Use Registry.qualified_cop_name
      def self.qualified_cop_name(name, origin)
        Registry.qualified_cop_name(name, origin)
      end

      def add_offense(node_or_range, location: :expression, message: nil, severity: nil, &block)
        @v0_argument = node_or_range
        range = find_location(node_or_range, location)
        if block.nil? && !support_autocorrect?
          super(range, message: message, severity: severity)
        else
          super(range, message: message, severity: severity) do |corrector|
            emulate_v0_callsequence(corrector, &block)
          end
        end
      end

      def find_location(node, loc)
        # Location can be provided as a symbol, e.g.: `:keyword`
        loc.is_a?(Symbol) ? node.loc.public_send(loc) : loc
      end

      # @deprecated Use class method
      def support_autocorrect?
        # warn 'deprecated, use cop.class.support_autocorrect?' TODO
        self.class.support_autocorrect?
      end

      # @deprecated
      def corrections
        # warn 'Cop#corrections is deprecated' TODO
        return [] unless @last_corrector

        Legacy::CorrectionsProxy.new(@last_corrector)
      end

      # Called before all on_... have been called
      def on_new_investigation
        investigate(processed_source) if respond_to?(:investigate)
        super
      end

      # Called after all on_... have been called
      def on_investigation_end
        investigate_post_walk(processed_source) if respond_to?(:investigate_post_walk)
        super
      end

      private

      def begin_investigation(processed_source)
        super
        @offenses = current_offenses
        @last_corrector = @current_corrector
      end

      # Override Base
      def callback_argument(_range)
        @v0_argument
      end

      def apply_correction(corrector)
        suppress_clobbering { super }
      end

      # Just for legacy
      def emulate_v0_callsequence(corrector)
        lambda = correction_lambda
        yield corrector if block_given?
        unless corrector.empty?
          raise 'Your cop must inherit from Cop::Base and extend AutoCorrector'
        end

        return unless lambda

        suppress_clobbering { lambda.call(corrector) }
      end

      def correction_lambda
        return unless support_autocorrect?

        dedup_on_node(@v0_argument) { autocorrect(@v0_argument) }
      end

      def dedup_on_node(node)
        @corrected_nodes ||= {}.compare_by_identity
        yield unless @corrected_nodes.key?(node)
      ensure
        @corrected_nodes[node] = true
      end

      def suppress_clobbering
        yield
      rescue ::Parser::ClobberingError
        # ignore Clobbering errors
      end
    end
  end
end
