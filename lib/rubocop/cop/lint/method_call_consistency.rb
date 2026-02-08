# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Detects inconsistent use of safe navigation operator (&.) across the same receiver.
      #
      # This cop ensures that if a receiver is accessed using both regular dot notation (.)
      # and safe navigation operator (&.), the usage is consistent throughout the file.
      #
      # @example
      #   # bad
      #   user.name
      #   user&.email
      #   user.phone
      #
      #   # good
      #   user&.name
      #   user&.email
      #   user&.phone
      #
      #   # also good
      #   user.name
      #   user.email
      #   user.phone
      class MethodCallConsistency < Base
        MSG = 'Inconsistent use of safe navigation operator. This receiver is accessed ' \
              'elsewhere %<nav_type>s safe navigation operator.'

        def initialize(config = nil, options = nil)
          super
          reset_state
        end

        def on_new_investigation
          reset_state
        end

        def on_csend(node)
          track_receiver(node, :with_safe_nav)
        end

        def on_send(node)
          return unless node.receiver
          return if node.safe_navigation?

          track_receiver(node, :without_safe_nav)
        end

        def on_investigation_end
          report_inconsistencies
        end

        private

        # Tracks receivers and their navigation style usage
        attr_reader :safe_nav_receivers, :dot_nav_receivers

        # Resets tracking state for new investigation
        def reset_state
          @safe_nav_receivers = {}
          @dot_nav_receivers = {}
        end

        # Tracks a receiver's usage with a specific navigation style
        #
        # @param node [AST::Node] The method call node
        # @param nav_type [Symbol] Either :with_safe_nav or :without_safe_nav
        def track_receiver(node, nav_type)
          receiver_source = extract_receiver_source(node)
          return if receiver_source.nil? || receiver_source.empty?

          case nav_type
          when :with_safe_nav
            safe_nav_receivers[receiver_source] ||= []
            safe_nav_receivers[receiver_source] << node
          when :without_safe_nav
            dot_nav_receivers[receiver_source] ||= []
            dot_nav_receivers[receiver_source] << node
          end
        end

        # Extracts the receiver source code, normalizing it by removing parentheses
        #
        # @param node [AST::Node] The method call node
        # @return [String, nil] The receiver source code or nil if no receiver
        def extract_receiver_source(node)
          receiver = node.receiver
          return nil unless receiver

          receiver.source.gsub(/^\(|\)$/, '')
        end

        # Reports all inconsistencies found during investigation
        def report_inconsistencies
          find_inconsistent_receivers.each do |receiver, nav_type|
            offending_nodes = determine_offending_nodes(nav_type)
            report_offenses(receiver, offending_nodes, nav_type)
          end
        end

        # Finds receivers that use both navigation styles inconsistently
        #
        # @return [Hash<String, Symbol>] Map of receiver to offending nav_type
        def find_inconsistent_receivers
          inconsistent = {}

          safe_nav_receivers.each_key do |receiver|
            inconsistent[receiver] = :without_safe_nav if dot_nav_receivers.key?(receiver)
          end

          dot_nav_receivers.each_key do |receiver|
            inconsistent[receiver] = :with_safe_nav if safe_nav_receivers.key?(receiver)
          end

          inconsistent
        end

        # Determines which nodes should be flagged as offending
        #
        # @param nav_type [Symbol] The navigation type that should be flagged
        # @return [Hash<String, Array<AST::Node>>] Offending nodes by receiver
        def determine_offending_nodes(nav_type)
          case nav_type
          when :with_safe_nav
            dot_nav_receivers
          when :without_safe_nav
            safe_nav_receivers
          end
        end

        # Reports offenses for the given nodes
        #
        # @param receiver [String] The receiver source code
        # @param offending_nodes [Hash] Map of receivers to nodes
        # @param nav_type [Symbol] The navigation type that's inconsistent
        def report_offenses(receiver, offending_nodes, nav_type)
          nodes = offending_nodes[receiver]
          return unless nodes

          message = build_message(nav_type)
          nodes.each { |node| add_offense(node, message: message) }
        end

        # Builds the offense message based on navigation type
        #
        # @param nav_type [Symbol] The navigation type
        # @return [String] The formatted message
        def build_message(nav_type)
          nav_text = nav_type == :with_safe_nav ? 'with' : 'without'
          format(MSG, nav_type: nav_text)
        end
      end
    end
  end
end
