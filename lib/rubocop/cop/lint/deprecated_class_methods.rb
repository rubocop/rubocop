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
      #   ENV.freeze # Calling `Env.freeze` raises `TypeError` since Ruby 2.7.
      #   Socket.gethostbyname(host)
      #   Socket.gethostbyaddr(host)
      #
      # @example
      #
      #   # good
      #
      #   File.exist?(some_path)
      #   Dir.exist?(some_path)
      #   block_given?
      #   ENV # `ENV.freeze` cannot prohibit changes to environment variables.
      #   Addrinfo.getaddrinfo(nodename, service)
      #   Addrinfo.tcp(host, port).getnameinfo
      class DeprecatedClassMethods < Base
        extend AutoCorrector

        # Inner class to DeprecatedClassMethods.
        # This class exists to add abstraction and clean naming
        # to the deprecated objects
        class DeprecatedClassMethod
          include RuboCop::AST::Sexp

          attr_reader :method, :class_constant

          def initialize(method, class_constant: nil, correctable: true)
            @method = method
            @class_constant = class_constant
            @correctable = correctable
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

          def correctable?
            @correctable
          end

          def to_s
            [class_constant, method].compact.join(delimiter)
          end

          private

          def delimiter
            CLASS_METHOD_DELIMETER
          end
        end

        # Inner class to DeprecatedClassMethods.
        # This class exists to add abstraction and clean naming
        # to the replacements for deprecated objects
        class Replacement
          attr_reader :method, :class_constant

          def initialize(method, class_constant: nil, instance_method: false)
            @method = method
            @class_constant = class_constant
            @instance_method = instance_method
          end

          def to_s
            [class_constant, method].compact.join(delimiter)
          end

          private

          def delimiter
            instance_method? ? INSTANCE_METHOD_DELIMETER : CLASS_METHOD_DELIMETER
          end

          def instance_method?
            @instance_method
          end
        end

        MSG = '`%<current>s` is deprecated in favor of `%<prefer>s`.'

        DEPRECATED_METHODS_OBJECT = {
          DeprecatedClassMethod.new(:exists?, class_constant: :File) =>
            Replacement.new(:exist?, class_constant: :File),

          DeprecatedClassMethod.new(:exists?, class_constant: :Dir) =>
            Replacement.new(:exist?, class_constant: :Dir),

          DeprecatedClassMethod.new(:iterator?) => Replacement.new(:block_given?),

          DeprecatedClassMethod.new(:freeze, class_constant: :ENV) =>
            Replacement.new(nil, class_constant: :ENV),

          DeprecatedClassMethod.new(:gethostbyaddr, class_constant: :Socket, correctable: false) =>
            Replacement.new(:getnameinfo, class_constant: :Addrinfo, instance_method: true),

          DeprecatedClassMethod.new(:gethostbyname, class_constant: :Socket, correctable: false) =>
            Replacement.new(:getaddrinfo, class_constant: :Addrinfo, instance_method: true)
        }.freeze

        RESTRICT_ON_SEND = DEPRECATED_METHODS_OBJECT.keys.map(&:method).freeze

        CLASS_METHOD_DELIMETER = '.'
        INSTANCE_METHOD_DELIMETER = '#'

        def on_send(node)
          check(node) do |deprecated|
            prefer = replacement(deprecated)
            message = format(MSG, current: deprecated, prefer: prefer)
            current_method = node.loc.selector

            add_offense(current_method, message: message) do |corrector|
              next unless deprecated.correctable?

              if (preferred_method = prefer.method)
                corrector.replace(current_method, preferred_method)
              else
                corrector.remove(node.loc.dot)
                corrector.remove(current_method)
              end
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
