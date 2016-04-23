# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks for the use of old-style attribute validation macros.
      class Validation < Cop
        MSG = 'Prefer the new style validations `%s` over `%s`.'.freeze

        TYPES = %w(
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
        ).freeze

        BLACKLIST = TYPES.map { |p| "validates_#{p}_of".to_sym }.freeze

        WHITELIST = TYPES.map { |p| "validates :column, #{p}: value" }.freeze

        def on_send(node)
          receiver, method_name, *_args = *node
          return unless receiver.nil? && BLACKLIST.include?(method_name)

          add_offense(node,
                      :selector,
                      format(MSG,
                             preferred_method(method_name),
                             method_name))
        end

        private

        def preferred_method(method)
          WHITELIST[BLACKLIST.index(method.to_sym)]
        end

        def autocorrect(node)
          _receiver, method_name, *args = *node
          options = args.find { |arg| arg.type != :sym }
          lambda do |corrector|
            validate_type = method_name.to_s.split('_')[1]
            corrector.replace(node.loc.selector, 'validates')
            cop_config['AllowUnusedKeywordArguments']
            if options
              corrector.replace(
                options.loc.expression,
                "#{validate_type}: { #{options.source} }"
              )
            else
              corrector.insert_after(
                node.loc.expression,
                ", #{validate_type}: true"
              )
            end
          end
        end
      end
    end
  end
end
