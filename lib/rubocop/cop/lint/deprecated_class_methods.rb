# encoding: utf-8

module RuboCop
  module Cop
    module Lint
      # This cop checks for uses of the deprecated class method usages.
      class DeprecatedClassMethods < Cop
        include AST::Sexp

        MSG = '`%s` is deprecated in favor of `%s`.'

        DEPRECATED_METHODS = [
          [:File, :exists?, :exist?],
          [:Dir, :exists?, :exist?]
        ]

        def on_send(node)
          receiver, method_name, *_args = *node

          DEPRECATED_METHODS.each do |data|
            next unless class_nodes(data).include?(receiver)
            next unless method_name == data[1]

            add_offense(node, :selector,
                        format(MSG,
                               deprecated_method(data),
                               replacement_method(data)))
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            receiver, method_name, *_args = *node

            DEPRECATED_METHODS.each do |data|
              next unless class_nodes(data).include?(receiver)
              next unless method_name == data[1]

              corrector.replace(node.loc.selector,
                                data[2].to_s)
            end
          end
        end

        private

        def class_nodes(data)
          [s(:const, nil, data[0]),
           s(:const, s(:cbase), data[0])]
        end

        def deprecated_method(data)
          format('%s.%s', data[0], data[1])
        end

        def replacement_method(data)
          format('%s.%s', data[0], data[2])
        end
      end
    end
  end
end
