# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for uses of the deprecated methods Hash#has_key?
      # and Hash#has_value?
      class DeprecatedHashMethods < Cop
        MSG = '`Hash#%s` is deprecated in favor of `Hash#%s`.'.freeze

        DEPRECATED_METHODS = [:has_key?, :has_value?].freeze

        def on_send(node)
          _receiver, method_name, *args = *node
          return unless args.size == 1 &&
                        DEPRECATED_METHODS.include?(method_name)

          add_offense(node, :selector,
                      format(MSG,
                             method_name,
                             proper_method_name(method_name)))
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
