# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for array literals made up of word-like
      # strings, that are not using the %w() syntax.
      class WordArray < Cop
        include ArraySyntax
        # The parameter is called MinSize (meaning the minimum array size for
        # which an offense can be registered), but essentially it's a Max
        # parameter (the maximum number of something that's allowed).
        include ConfigurableMax

        MSG = 'Use `%w` or `%W` for array of words.'

        def on_array(node)
          array_elems = node.children
          return unless array_of?(:str, node) &&
                        !complex_content?(array_elems) &&
                        array_elems.size > min_size && !comments_in_array?(node)

          add_offense(node, :expression) { self.max = array_elems.size }
        end

        private

        def parameter_name
          'MinSize'
        end

        def comments_in_array?(node)
          comments = processed_source.comments

          array_range = node.loc.expression.to_a

          comments.any? do |comment|
            !(comment.loc.expression.to_a & array_range).empty?
          end
        end

        def complex_content?(arr_sexp)
          arr_sexp.each do |s|
            source = s.loc.expression.source
            next if source.start_with?('?') # %W(\r \n) can replace [?\r, ?\n]

            str_content = Util.strip_quotes(source)
            return true unless str_content =~ word_regex
          end

          false
        end

        def min_size
          cop_config['MinSize']
        end

        def word_regex
          cop_config['WordRegex']
        end

        def autocorrect(node)
          @interpolated = false
          contents = node.children.map { |n| source_for(n) }.join(' ')
          char = @interpolated ? 'W' : 'w'

          lambda do |corrector|
            corrector.replace(node.loc.expression, "%#{char}(#{contents})")
          end
        end

        def source_for(str_node)
          if character_literal?(str_node)
            @interpolated = true
            begin_pos = str_node.loc.expression.begin_pos + '?'.length
            end_pos = str_node.loc.expression.end_pos
          else
            begin_pos = str_node.loc.begin.end_pos
            end_pos = str_node.loc.end.begin_pos
          end
          Parser::Source::Range.new(str_node.loc.expression.source_buffer,
                                    begin_pos, end_pos).source
        end

        def character_literal?(node)
          node.loc.end.nil?
        end
      end
    end
  end
end
