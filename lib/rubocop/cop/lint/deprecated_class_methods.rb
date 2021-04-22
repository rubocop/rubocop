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
      #   Dir.exists?(some_path)
      #   iterator?
      #
      # @example
      #
      #   # good
      #
      #   File.exist?(some_path)
      #   Dir.exist?(some_path)
      #   block_given?
      class DeprecatedClassMethods < Base
        extend AutoCorrector

        # Inner class to DeprecatedClassMethods.
        # This class exists to add abstraction and clean naming
        # to the deprecated objects
        class DeprecatedClassMethod
          include RuboCop::AST::Sexp

          attr_reader :method, :class_constant

          def initialize(method, class_constant: nil)
            @method = method
            @class_constant = class_constant
          end

          def class_nodes
            @class_nodes ||=
              if class_constant
                [
                  s(:const, nil, class_constant),
                  s(:const, s(:cbase), class_constant)
                ]
              else
                [nil]
              end
          end

          def to_s
            [class_constant, method].compact.join(delimeter)
          end

          private

          def delimeter
            CLASS_METHOD_DELIMETER
          end
        end

        # Inner class to DeprecatedClassMethods.
        # This class exists to add abstraction and clean naming
        # to the replacements for deprecated objects
        class Replacement
          attr_reader :method, :class_constant

          def initialize(method, class_constant: nil)
            @method = method
            @class_constant = class_constant
          end

          def to_s
            [class_constant, method].compact.join(delimeter)
          end

          private

          def delimeter
            CLASS_METHOD_DELIMETER
          end
        end

        MSG = '`%<current>s` is deprecated in favor of `%<prefer>s`.'

        DEPRECATED_METHODS_OBJECT = {
          DeprecatedClassMethod.new(:exists?, class_constant: :File) =>
            Replacement.new(:exist?, class_constant: :File),

          DeprecatedClassMethod.new(:exists?, class_constant: :Dir) =>
            Replacement.new(:exist?, class_constant: :Dir),

          DeprecatedClassMethod.new(:iterator?) => Replacement.new(:block_given?)
        }.freeze

        RESTRICT_ON_SEND = DEPRECATED_METHODS_OBJECT.keys.map(&:method).freeze

        CLASS_METHOD_DELIMETER = '.'

        def on_send(node)
          check(node) do |deprecated|
            message = format(MSG, current: deprecated, prefer: replacement(deprecated))

            add_offense(node.loc.selector, message: message) do |corrector|
              corrector.replace(node.loc.selector, replacement(deprecated).method)
            end
          end
        end

        private

        def check(node)
          DEPRECATED_METHODS_OBJECT.each_key do |deprecated|
            next unless deprecated.class_nodes.include?(node.receiver)
            next unless node.method?(deprecated.method)

            yield deprecated
          end
        end

        def replacement(deprecated)
          DEPRECATED_METHODS_OBJECT[deprecated]
        end
      end
    end
  end
end
