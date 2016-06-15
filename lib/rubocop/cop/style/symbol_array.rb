# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop can check for array literals made up of symbols that are not
      # using the %i() syntax.
      #
      # Alternatively, it checks for symbol arrays using the %i() syntax on
      # projects which do not want to use that syntax, perhaps because they
      # support a version of Ruby lower than 2.0.
      class SymbolArray < Cop
        include ConfigurableEnforcedStyle
        include ArraySyntax

        PERCENT_MSG = 'Use `%i` or `%I` for an array of symbols.'.freeze
        ARRAY_MSG = 'Use `[]` for an array of symbols.'.freeze

        def on_array(node)
          if bracketed_array_of?(:sym, node)
            return if comments_in_array?(node)
            return if symbols_contain_spaces?(node)
            style_detected(:brackets)
            add_offense(node, :expression, PERCENT_MSG) if style == :percent
          elsif node.loc.begin && node.loc.begin.source =~ /\A%[iI]/
            style_detected(:percent)
            add_offense(node, :expression, ARRAY_MSG) if style == :brackets
          end
        end

        def validate_config
          if style == :percent && target_ruby_version < 2.0
            raise ValidationError, 'The default `percent` style for the ' \
                                  '`Style/SymbolArray` cop is only compatible' \
                                  ' with Ruby 2.0 and up, but the target Ruby' \
                                  " version for your project is 1.9.\nPlease " \
                                  'either disable this cop, configure it to ' \
                                  'use `array` style, or adjust the ' \
                                  '`TargetRubyVersion` parameter in your ' \
                                  'configuration.'
          end
        end

        private

        def comments_in_array?(node)
          comments = processed_source.comments
          array_range = node.source_range.to_a

          comments.any? do |comment|
            !(comment.loc.expression.to_a & array_range).empty?
          end
        end

        def symbols_contain_spaces?(node)
          node.children.any? do |sym|
            content, = *sym
            content =~ / /
          end
        end

        def autocorrect(node)
          syms = node.children.map { |c| c.children[0].to_s }
          corrected = if style == :percent
                        escape = syms.any? { |s| needs_escaping?(s) }
                        syms = syms.map { |s| escape_string(s) } if escape
                        syms = syms.map { |s| s.gsub(/\)/, '\\)') }
                        if escape
                          "%I(#{syms.join(' ')})"
                        else
                          "%i(#{syms.join(' ')})"
                        end
                      else
                        syms = syms.map { |s| to_symbol_literal(s) }
                        "[#{syms.join(', ')}]"
                      end

          lambda do |corrector|
            corrector.replace(node.source_range, corrected)
          end
        end
      end
    end
  end
end
