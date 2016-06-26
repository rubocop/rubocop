# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Performance
      # This cop identifies places where `gsub` can be replaced by
      # `tr` or `delete`.
      #
      # @example
      #   @bad
      #   'abc'.gsub('b', 'd')
      #   'abc'.gsub('a', '')
      #   'abc'.gsub(/a/, 'd')
      #   'abc'.gsub!('a', 'd')
      #
      #   @good
      #   'abc'.gsub(/.*/, 'a')
      #   'abc'.gsub(/a+/, 'd')
      #   'abc'.tr('b', 'd')
      #   'a b c'.delete(' ')
      class StringReplacement < Cop
        MSG = 'Use `%s` instead of `%s`.'.freeze
        DETERMINISTIC_REGEX = /\A(?:#{LITERAL_REGEX})+\Z/
        REGEXP_CONSTRUCTOR_METHODS = [:new, :compile].freeze
        GSUB_METHODS = [:gsub, :gsub!].freeze
        DETERMINISTIC_TYPES = [:regexp, :str, :send].freeze
        DELETE = 'delete'.freeze
        TR = 'tr'.freeze
        BANG = '!'.freeze
        SINGLE_QUOTE = "'".freeze

        def on_send(node)
          _string, method, first_param, second_param = *node

          return unless GSUB_METHODS.include?(method)
          return if accept_second_param?(second_param)
          return if accept_first_param?(first_param)

          offense(node, method, first_param, second_param)
        end

        def autocorrect(node)
          _string, method, first_param, second_param = *node
          first_source, = first_source(first_param)
          second_source, = *second_param

          if regex?(first_param)
            first_source = interpret_string_escapes(first_source)
          end

          replacement_method =
            replacement_method(method, first_source, second_source)

          replace_method(node, first_source, second_source, first_param,
                         replacement_method)
        end

        def replace_method(node, first, second, first_param, replacement)
          lambda do |corrector|
            corrector.replace(node.loc.selector, replacement)
            unless first_param.str_type?
              corrector.replace(first_param.source_range,
                                to_string_literal(first))
            end

            if second.empty? && first.length == 1
              remove_second_param(corrector, node, first_param)
            end
          end
        end

        private

        def accept_second_param?(second_param)
          return true unless string?(second_param)
          second_source, = *second_param

          second_source.length > 1
        end

        def accept_first_param?(first_param)
          return true unless DETERMINISTIC_TYPES.include?(first_param.type)

          first_source, options = first_source(first_param)
          return true if first_source.nil?

          if regex?(first_param)
            return true if options
            return true unless first_source =~ DETERMINISTIC_REGEX
            # This must be done after checking DETERMINISTIC_REGEX
            # Otherwise things like \s will trip us up
            first_source = interpret_string_escapes(first_source)
          end

          first_source.length != 1
        end

        def offense(node, method, first_param, second_param)
          first_source, = first_source(first_param)
          if regex?(first_param)
            first_source = interpret_string_escapes(first_source)
          end
          second_source, = *second_param
          message = message(method, first_source, second_source)

          add_offense(node, range(node), message)
        end

        def string?(node)
          node && node.str_type?
        end

        def first_source(first_param)
          case first_param.type
          when :regexp, :send
            return nil unless regex?(first_param)
            source, options = extract_source(first_param)
          when :str
            source, = *first_param
          end

          [source, options]
        end

        def extract_source(node)
          case node.type
          when :regexp
            source_from_regex_literal(node)
          when :send
            source_from_regex_constructor(node)
          end
        end

        def source_from_regex_literal(node)
          regex, options = *node
          source, = *regex
          options, = *options
          [source, options]
        end

        def source_from_regex_constructor(node)
          _const, _init, regex = *node
          case regex.type
          when :regexp
            source_from_regex_literal(regex)
          when :str
            source, = *regex
            source
          end
        end

        def regex?(node)
          return true if node.regexp_type?

          const, init, = *node
          _, klass = *const

          klass == :Regexp && REGEXP_CONSTRUCTOR_METHODS.include?(init)
        end

        def range(node)
          Parser::Source::Range.new(node.source_range.source_buffer,
                                    node.loc.selector.begin_pos,
                                    node.source_range.end_pos)
        end

        def replacement_method(method, first_source, second_source)
          replacement = if second_source.empty? && first_source.length == 1
                          DELETE
                        else
                          TR
                        end

          "#{replacement}#{BANG if bang_method?(method)}"
        end

        def message(method, first_source, second_source)
          replacement_method = replacement_method(method,
                                                  first_source,
                                                  second_source)

          format(MSG, replacement_method, method)
        end

        def bang_method?(method)
          method.to_s.end_with?(BANG)
        end

        def method_suffix(node)
          node.loc.end ? node.loc.end.source : ''
        end

        def remove_second_param(corrector, node, first_param)
          end_range =
            Parser::Source::Range.new(node.source_range.source_buffer,
                                      first_param.source_range.end_pos,
                                      node.source_range.end_pos)

          corrector.replace(end_range, method_suffix(node))
        end
      end
    end
  end
end
