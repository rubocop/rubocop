# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for uses of the deprecated class method usages.
      #
      # @example
      #
      #   # bad
      #
      #   File.exists?(some_path)
      #
      # @example
      #
      #   # good
      #
      #   File.exist?(some_path)
      class DeprecatedClassMethods < Cop
        # Inner class to DeprecatedClassMethods.
        # This class exists to add abstraction and clean naming to the
        # objects that are going to be operated on.
        class DeprecatedClassMethod
          include RuboCop::AST::Sexp

          attr_reader :class_constant, :deprecated_method, :replacement_method

          def initialize(class_constant, deprecated_method, replacement_method)
            @class_constant = class_constant
            @deprecated_method = deprecated_method
            @replacement_method = replacement_method
          end

          def class_nodes
            @class_nodes ||= [
              s(:const, nil, class_constant),
              s(:const, s(:cbase), class_constant)
            ]
          end
        end

        MSG = '`%s` is deprecated in favor of `%s`.'.freeze
        DEPRECATED_METHODS_OBJECT = [
          DeprecatedClassMethod.new(:File, :exists?, :exist?),
          DeprecatedClassMethod.new(:Dir, :exists?, :exist?)
        ].freeze

        def on_send(node)
          check(node) do |data|
            message = format(MSG, deprecated_method(data),
                             replacement_method(data))

            add_offense(node, location: :selector, message: message)
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            check(node) do |data|
              corrector.replace(node.loc.selector,
                                data.replacement_method.to_s)
            end
          end
        end

        private

        def check(node)
          DEPRECATED_METHODS_OBJECT.each do |data|
            next unless data.class_nodes.include?(node.receiver)
            next unless node.method?(data.deprecated_method)
            yield data
          end
        end

        def deprecated_method(data)
          method_call(data.class_constant, data.deprecated_method)
        end

        def replacement_method(data)
          method_call(data.class_constant, data.replacement_method)
        end

        def method_call(class_constant, method)
          format('%s.%s', class_constant, method)
        end
      end
    end
  end
end
