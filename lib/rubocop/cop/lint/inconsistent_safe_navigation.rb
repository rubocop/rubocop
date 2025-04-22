# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Detects when a receiver is used inconsistently with safe navigation (`&.`) and
      # regular method calls (`.`). This can lead to the mistake of using a regular method
      # call when the receiver could be nil, or unnecessarily using safe navigation when
      # the receiver is guaranteed to be non-nil.
      #
      # @example
      #   # bad
      #   user.address&.street
      #   user.address.city
      #
      #   # good - consistent use of safe navigation
      #   user.address&.street
      #   user.address&.city
      #
      #   # good - consistent use of regular method calls
      #   user.address.street
      #   user.address.city
      #
      class InconsistentSafeNavigation < Base
        MSG = 'Inconsistent use of safe navigation operator. This receiver is accessed ' \
              'elsewhere %<nav_type>s safe navigation operator.'

        def initialize(config = nil, options = nil)
          super
          @safe_nav_receivers = {}
          @dot_nav_receivers = {}
        end

        def on_csend(node)
          check_receiver(node, :with)
        end

        def on_send(node)
          return unless node.receiver
          return if node.safe_navigation?

          check_receiver(node, :without)
        end

        def on_new_investigation
          @safe_nav_receivers.clear
          @dot_nav_receivers.clear
        end

        def on_investigation_end
          inconsistent_receivers = find_inconsistent_receivers

          inconsistent_receivers.each do |receiver, nav_type|
            offending_nodes = if nav_type == :with
                                @dot_nav_receivers[receiver]
                              else
                                @safe_nav_receivers[receiver]
                              end

            offending_nodes.each do |node|
              message = format(MSG, nav_type: nav_type == :with ? 'with' : 'without')
              add_offense(node, message: message)
            end
          end
        end

        private

        def check_receiver(node, nav_type)
          receiver_source = extract_receiver_source(node)
          return if receiver_source.nil? || receiver_source.empty?

          if nav_type == :with
            @safe_nav_receivers[receiver_source] ||= []
            @safe_nav_receivers[receiver_source] << node
          else
            @dot_nav_receivers[receiver_source] ||= []
            @dot_nav_receivers[receiver_source] << node
          end
        end

        def extract_receiver_source(node)
          receiver = node.receiver
          return nil unless receiver

          # Normalize receiver source to handle different types of receivers
          receiver.source.sub(/^\(|\)$/, '')
        end

        def find_inconsistent_receivers
          inconsistent_receivers = {}

          @safe_nav_receivers.each_key do |receiver|
            inconsistent_receivers[receiver] = :without if @dot_nav_receivers.key?(receiver)
          end

          @dot_nav_receivers.each_key do |receiver|
            inconsistent_receivers[receiver] = :with if @safe_nav_receivers.key?(receiver)
          end

          inconsistent_receivers
        end
      end
    end
  end
end
