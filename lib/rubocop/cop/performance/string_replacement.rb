# encoding: utf-8

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
        MSG = 'Use `%s` instead of `%s`.'
        DETERMINISTIC_REGEX = /^[\w\s\-,."']+$/
        REGEXP_CONSTRUCTOR_METHODS = [:new, :compile]
        GSUB_METHODS = [:gsub, :gsub!]
        DETERMINISTIC_TYPES = [:regexp, :str, :send]

        def on_send(node)
          _string, method, first_param, second_param = *node
          return unless GSUB_METHODS.include?(method)
          return unless second_param && second_param.str_type?
          return unless DETERMINISTIC_TYPES.include?(first_param.type)

          first_source = first_source(first_param)
          second_source, = *second_param

          return if first_source.nil?

          if regex?(first_param)
            return unless first_source =~ DETERMINISTIC_REGEX
          end

          if first_source.length != second_source.length
            return unless second_source.empty?
          end

          message = message(method, first_source, second_source)
          add_offense(node, range(node), message)
        end

        def autocorrect(node)
          _string, method, first_param, second_param = *node
          first_source = first_source(first_param)
          second_source, = *second_param
          replacement_method = replacement_method(first_source, second_source)

          lambda do |corrector|
            replacement =
              if second_source.empty? && first_source.length == 1
                "#{replacement_method}#{'!' if bang_method?(method)}" \
                "(#{escape(first_source)})"
              else
                "#{replacement_method}#{'!' if bang_method?(method)}" \
                "(#{escape(first_source)}, #{escape(second_source)})"
              end

            corrector.replace(range(node), replacement)
          end
        end

        private

        def first_source(first_param)
          case first_param.type
          when :regexp, :send
            return nil unless regex?(first_param)

            source, = extract_source(first_param)
          when :str
            source, = *first_param
          end

          source
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
          regex, = *node
          source, = *regex
          source
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
          Parser::Source::Range.new(node.loc.expression.source_buffer,
                                    node.loc.selector.begin_pos,
                                    node.loc.expression.end_pos)
        end

        def replacement_method(first_source, second_source)
          if second_source.empty? && first_source.length == 1
            'delete'
          else
            'tr'
          end
        end

        def message(method, first_source, second_source)
          replacement_method = replacement_method(first_source, second_source)

          format(MSG,
                 "#{replacement_method}#{'!' if bang_method?(method)}",
                 method)
        end

        def bang_method?(method)
          method.to_s.end_with?('!')
        end

        def escape(string)
          if require_double_quotes?(string)
            string.inspect
          else
            "'#{string}'"
          end
        end

        def require_double_quotes?(string)
          /'/ =~ string.inspect ||
            StringHelp::ESCAPED_CHAR_REGEXP =~ string.inspect
        end
      end
    end
  end
end
