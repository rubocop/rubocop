# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Algorithmic constants for `OpenSSL::Cipher` and `OpenSSL::Digest`
      # deprecated since OpenSSL version 2.2.0. Prefer passing a string
      # instead.
      #
      # @example
      #
      #   # Example for OpenSSL::Cipher instantiation.
      #
      #   # bad
      #   OpenSSL::Cipher::AES.new(128, :GCM)
      #
      #   # good
      #   OpenSSL::Cipher.new('AES-128-GCM')
      #
      # @example
      #
      #   # Example for OpenSSL::Digest instantiation.
      #
      #   # bad
      #   OpenSSL::Digest::SHA256.new
      #
      #   # good
      #   OpenSSL::Digest.new('SHA256')
      #
      # @example
      #
      #   # Example for ::Digest inherited class methods.
      #
      #   # bad
      #   OpenSSL::Digest::SHA256.digest('foo')
      #
      #   # good
      #   OpenSSL::Digest.digest('SHA256', 'foo')
      #
      class DeprecatedOpenSSLConstant < Cop
        include RangeHelp

        MSG = 'Use `%<constant>s.%<method>s(%<replacement_args>s)`' \
          ' instead of `%<original>s`.'

        def_node_matcher :algorithm_const, <<~PATTERN
          (send
            $(const
              (const
                (const {nil? cbase} :OpenSSL) {:Cipher :Digest})
              _)
            ...)
        PATTERN

        def on_send(node)
          return if node.arguments.any? { |arg| arg.variable? || arg.send_type? || arg.const_type? }

          add_offense(node) if algorithm_const(node)
        end

        def autocorrect(node)
          algorithm_constant, = algorithm_const(node)

          lambda do |corrector|
            corrector.remove(algorithm_constant.loc.double_colon)
            corrector.remove(algorithm_constant.loc.name)

            corrector.replace(
              correction_range(node),
              "#{node.loc.selector.source}(#{replacement_args(node)})"
            )
          end
        end

        private

        def message(node)
          algorithm_constant, = algorithm_const(node)
          parent_constant = openssl_class(algorithm_constant)
          replacement_args = replacement_args(node)
          method = node.loc.selector.source

          format(
            MSG,
            constant: parent_constant,
            method: method,
            replacement_args: replacement_args,
            original: node.source
          )
        end

        def correction_range(node)
          range_between(node.loc.dot.end_pos, node.loc.expression.end_pos)
        end

        def openssl_class(node)
          node.children.first.source
        end

        def algorithm_name(node)
          name = node.loc.name.source

          if openssl_class(node) == 'OpenSSL::Cipher'
            name.scan(/.{3}/).join('-')
          else
            name
          end
        end

        def sanitize_arguments(arguments)
          arguments.flat_map do |arg|
            argument = arg.str_type? ? arg.value : arg.source

            argument.tr(":'", '').split('-')
          end
        end

        def replacement_args(node)
          algorithm_constant, = algorithm_const(node)
          algorithm_name = algorithm_name(algorithm_constant)

          if openssl_class(algorithm_constant) == 'OpenSSL::Cipher'
            build_cipher_arguments(node, algorithm_name)
          else
            (["'#{algorithm_name}'"] + node.arguments.map(&:source)).join(', ')
          end
        end

        def build_cipher_arguments(node, algorithm_name)
          algorithm_parts = algorithm_name.split('-')
          size_and_mode = sanitize_arguments(node.arguments)
          "'#{(algorithm_parts + size_and_mode + ['CBC']).take(3).join('-')}'"
        end
      end
    end
  end
end
