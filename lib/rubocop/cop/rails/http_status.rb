# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Enforces use of symbolic or numeric value to define HTTP status.
      #
      # @example EnforcedStyle: symbolic (default)
      #   # bad
      #   render :foo, status: 200
      #   render json: { foo: 'bar' }, status: 200
      #   render plain: 'foo/bar', status: 304
      #   redirect_to root_url, status: 301
      #
      #   # good
      #   render :foo, status: :ok
      #   render json: { foo: 'bar' }, status: :ok
      #   render plain: 'foo/bar', status: :not_modified
      #   redirect_to root_url, status: :moved_permanently
      #
      # @example EnforcedStyle: numeric
      #   # bad
      #   render :foo, status: :ok
      #   render json: { foo: 'bar' }, status: :not_found
      #   render plain: 'foo/bar', status: :not_modified
      #   redirect_to root_url, status: :moved_permanently
      #
      #   # good
      #   render :foo, status: 200
      #   render json: { foo: 'bar' }, status: 404
      #   render plain: 'foo/bar', status: 304
      #   redirect_to root_url, status: 301
      #
      class HttpStatus < Cop
        begin
          require 'rack/utils'
          RACK_LOADED = true
        rescue LoadError
          RACK_LOADED = false
        end

        include ConfigurableEnforcedStyle

        def_node_matcher :http_status, <<-PATTERN
          {
            (send nil? {:render :redirect_to} _ $hash)
            (send nil? {:render :redirect_to} $hash)
          }
        PATTERN

        def_node_matcher :status_pair?, <<-PATTERN
          (pair (sym :status) ${int sym})
        PATTERN

        def on_send(node)
          http_status(node) do |hash_node|
            status = status_code(hash_node)
            return unless status
            checker = checker_class.new(status)
            return unless checker.offensive?
            add_offense(checker.node, message: checker.message)
          end
        end

        def support_autocorrect?
          RACK_LOADED
        end

        def autocorrect(node)
          lambda do |corrector|
            checker = checker_class.new(node)
            corrector.replace(node.loc.expression, checker.preferred_style)
          end
        end

        private

        def status_code(node)
          node.each_pair.each do |pair|
            status_pair?(pair) { |code| return code }
          end
          false
        end

        def checker_class
          case style
          when :symbolic
            SymbolicStyleChecker
          when :numeric
            NumericStyleChecker
          end
        end

        # :nodoc:
        class SymbolicStyleChecker
          MSG = 'Prefer `%<prefer>s` over `%<current>s` ' \
                'to define HTTP status code.'.freeze
          DEFAULT_MSG = 'Prefer `symbolic` over `numeric` ' \
                        'to define HTTP status code.'.freeze

          attr_reader :node
          def initialize(node)
            @node = node
          end

          def offensive?
            !node.sym_type? && !custom_http_status_code?
          end

          def message
            if RACK_LOADED
              format(MSG, prefer: preferred_style, current: number.to_s)
            else
              DEFAULT_MSG
            end
          end

          def preferred_style
            symbol.inspect
          end

          private

          def symbol
            ::Rack::Utils::SYMBOL_TO_STATUS_CODE.key(number)
          end

          def number
            node.children.first
          end

          def custom_http_status_code?
            node.int_type? &&
              !::Rack::Utils::SYMBOL_TO_STATUS_CODE.value?(number)
          end
        end

        # :nodoc:
        class NumericStyleChecker
          MSG = 'Prefer `%<prefer>s` over `%<current>s` ' \
                'to define HTTP status code.'.freeze
          DEFAULT_MSG = 'Prefer `numeric` over `symbolic` ' \
                        'to define HTTP status code.'.freeze
          WHITELIST_STATUS = %i[error success missing redirect].freeze

          attr_reader :node
          def initialize(node)
            @node = node
          end

          def offensive?
            !node.int_type? && !whitelisted_symbol?
          end

          def message
            if RACK_LOADED
              format(MSG, prefer: preferred_style, current: symbol.inspect)
            else
              DEFAULT_MSG
            end
          end

          def preferred_style
            number.to_s
          end

          private

          def number
            ::Rack::Utils::SYMBOL_TO_STATUS_CODE[symbol]
          end

          def symbol
            node.value
          end

          def whitelisted_symbol?
            node.sym_type? && WHITELIST_STATUS.include?(node.value)
          end
        end
      end
    end
  end
end
