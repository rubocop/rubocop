# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for call sites where a module or class name acts as
      # a receiver. The purpose is to generate a list of offenses where the
      # identifier is being called that can be used to audit the use of the
      # receiver.
      #
      # E.g. you have ThirdPartyAPILibrary that you would like to ensure is only
      # called from within a wrapper class, WrapThirdParty. You may annotate
      # those calls made within WrapThirdParty with a local disable to show they
      # are approved. If a future developer attempted to make a call to
      # ThirdPartyAPILibrary, it would be caught as a rubocop offense.
      #
      # @example Identifiers: ['FakeClassName', 'FakeModuleName']
      #
      #   # bad
      #   FakeModuleName.example_method
      #
      #   # bad
      #   FakeClassName.another_example
      #
      #   # good
      #   FakeModuleName
      #
      #   # good
      #   FakeClassName
      #
      class ApprovedCallSite < Cop
        def on_send(node)
          identifiers.each do |identifier|
            if receiver?(node, identifier)
              add_offense(node, message: "#{identifier} call site.")
            end
          end
        end

        def receiver?(node, identifier)
          pattern = "(send (const nil? :#{identifier}) ...)"

          NodePattern.new(pattern).match(node)
        end

        def identifiers
          Array(cop_config.fetch('Identifiers', []))
            .map(&:to_s)
            .reject(&:blank?)
        end
      end
    end
  end
end
