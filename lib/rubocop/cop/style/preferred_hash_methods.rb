# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for uses of methods Hash#has_key? and Hash#has_value?
      # Prefer to use Hash#key? and Hash#value? instead
      class PreferredHashMethods < Cop
        MSG = 'Use `Hash#%s` instead of `Hash#%s`.'.freeze

        PREFERRED_METHODS = [:has_key?, :has_value?].freeze

        def on_send(node)
          _receiver, method_name, *args = *node
          return unless args.size == 1 &&
                        PREFERRED_METHODS.include?(method_name)

          add_offense(node, :selector,
                      format(MSG,
                             proper_method_name(method_name),
                             method_name))
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.loc.selector,
                              proper_method_name(node.loc.selector.source))
          end
        end

        private

        def proper_method_name(method_name)
          method_name.to_s.sub(/has_/, '')
        end
      end
    end
  end
end
