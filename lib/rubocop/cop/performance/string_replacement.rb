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
        DELETE = 'delete'.freeze
        TR = 'tr'.freeze
        BANG = '!'.freeze
        SINGLE_QUOTE = "'".freeze

        def_node_matcher :string_replacement?, <<-PATTERN
          (send _ {:gsub :gsub!}
                    ${regexp str (send (const nil? :Regexp) {:new :compile} _)}
                    $str)
        PATTERN

        def on_send(node)
          string_replacement?(node) do |first_param, second_param|
            return if accept_second_param?(second_param)
            return if accept_first_param?(first_param)

            offense(node, first_param, second_param)
          end
        end

        def autocorrect(node)
          _string, _method, first_param, second_param = *node
          first_source, = first_source(first_param)
          second_source, = *second_param

          unless first_param.str_type?
            first_source = interpret_string_escapes(first_source)
          end

          replacement_method =
            replacement_method(node, first_source, second_source)

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
          second_source, = *second_param
          second_source.length > 1
        end

        def accept_first_param?(first_param)
          first_source, options = first_source(first_param)
          return true if first_source.nil?

          unless first_param.str_type?
            return true if options
            return true unless first_source =~ DETERMINISTIC_REGEX
            # This must be done after checking DETERMINISTIC_REGEX
            # Otherwise things like \s will trip us up
            first_source = interpret_string_escapes(first_source)
          end

          first_source.length != 1
        end

        def offense(node, first_param, second_param)
          first_source, = first_source(first_param)
          unless first_param.str_type?
            first_source = interpret_string_escapes(first_source)
          end
          second_source, = *second_param
          message = message(node, first_source, second_source)

          add_offense(node, range(node), message)
        end

        def first_source(first_param)
          case first_param.type
          when :regexp
            source_from_regex_literal(first_param)
          when :send
            source_from_regex_constructor(first_param)
          when :str
            first_param.children.first
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

        def range(node)
          range_between(node.loc.selector.begin_pos, node.source_range.end_pos)
        end

        def replacement_method(node, first_source, second_source)
          replacement = if second_source.empty? && first_source.length == 1
                          DELETE
                        else
                          TR
                        end

          "#{replacement}#{BANG if node.bang_method?}"
        end

        def message(node, first_source, second_source)
          replacement_method =
            replacement_method(node, first_source, second_source)

          format(MSG, replacement_method, node.method_name)
        end

        def method_suffix(node)
          node.loc.end ? node.loc.end.source : ''
        end

        def remove_second_param(corrector, node, first_param)
          end_range = range_between(first_param.source_range.end_pos,
                                    node.source_range.end_pos)

          corrector.replace(end_range, method_suffix(node))
        end
      end
    end
  end
end
