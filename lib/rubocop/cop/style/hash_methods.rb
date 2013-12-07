# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for uses of the deprecated methods Hash#has_key?
      # and Hash#has_value?
      class HashMethods < Cop
        MSG = '%s is deprecated in favor of %s.'

        DEPRECATED_METHODS = [:has_key?, :has_value?]

        def on_send(node)
          _receiver, method_name, *args = *node

          if args.size == 1 && DEPRECATED_METHODS.include?(method_name)
            add_offence(node, :selector,
                        MSG.format(method_name,
                                   proper_method_name(method_name)))
          end
        end

        def autocorrect(node)
          @corrections << lambda do |corrector|
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
