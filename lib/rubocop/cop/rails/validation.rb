# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks for the use of old-style attribute validation macros.
      class Validation < Cop
        MSG = 'Prefer the new style validations `%s` over `%s`.'.freeze

        TYPES = %w[
          acceptance
          confirmation
          exclusion
          format
          inclusion
          length
          numericality
          presence
          size
          uniqueness
        ].freeze

        BLACKLIST = TYPES.map { |p| "validates_#{p}_of".to_sym }.freeze
        WHITELIST = TYPES.map { |p| "validates :column, #{p}: value" }.freeze

        def on_send(node)
          return unless !node.receiver && BLACKLIST.include?(node.method_name)

          add_offense(node, location: :selector)
        end

        private

        def message(node)
          format(MSG, preferred_method(node.method_name), node.method_name)
        end

        def preferred_method(method)
          WHITELIST[BLACKLIST.index(method.to_sym)]
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.loc.selector, 'validates')
            correct_validate_type(corrector, node)
          end
        end

        def correct_validate_type(corrector, node)
          options = node.arguments.find { |arg| !arg.sym_type? }
          validate_type = node.method_name.to_s.split('_')[1]

          if options
            corrector.replace(options.loc.expression,
                              "#{validate_type}: { #{options.source} }")
          else
            corrector.insert_after(node.loc.expression,
                                   ", #{validate_type}: true")
          end
        end
      end
    end
  end
end
