# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Check that constants are fully qualified.
      #
      # @example
      #   # By default checks every constant
      #
      #   # bad
      #   User
      #
      #   # bad
      #   User::Login
      #
      #   # good
      #   ::User
      #
      #   # good
      #   ::User::Login
      #
      # @example Only: ['Login']
      #   # Restrict this cop to only being concerned about certain constants
      #
      #   # bad
      #   Login
      #
      #   # good
      #   ::Login
      #
      #   # good
      #   User::Login
      #
      # @example Ignore: ['Login']
      #   # Restrict this cop not being concerned about certain constants
      #
      #   # bad
      #   User
      #
      #   # good
      #   ::User::Login
      #
      #   # good
      #   Login
      #
      class ConstantResolution < Cop
        MSG = 'Fully qualify this constant to avoid possibly ambiguous resolution.'

        def_node_matcher :unqualified_const?, <<~PATTERN
          (const nil? #const_name?)
        PATTERN

        def on_const(node)
          return unless unqualified_const?(node)

          add_offense(node)
        end

        private

        def const_name?(name)
          name = name.to_s
          (allowed_names.empty? || allowed_names.include?(name)) &&
            !ignored_names.include?(name)
        end

        def allowed_names
          cop_config['Only']
        end

        def ignored_names
          cop_config['Ignore']
        end
      end
    end
  end
end
