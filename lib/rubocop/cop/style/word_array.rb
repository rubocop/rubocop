# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for array literals made up of word-like
      # strings, that are not using the %w() syntax.
      class WordArray < Cop
        include ArraySyntax
        # The parameter is called MinSize (meaning the minimum array size for
        # which an offence can be registered), but essentially it's a Max
        # parameter (the maximum number of something that's allowed).
        include ConfigurableMax

        MSG = 'Use %w or %W for array of words.'

        def on_array(node)
          array_elems = node.children
          if array_of?(:str, node) && !complex_content?(array_elems) &&
            array_elems.size > min_size && !comments_in_array?(node)
            add_offence(node, :expression) { self.max = array_elems.size }
          end
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
            unless source.start_with?('?') # %W(\r \n) can replace [?\r, ?\n]
              str_content = Util.strip_quotes(source)
              return true unless str_content =~ /\A[\w-]+\z/
            end
          end

          false
        end

        def min_size
          cop_config['MinSize']
        end

        def autocorrect(node)
          sb = node.loc.expression.source_buffer
          interpolated = false

          contents = node.children.map do |n|
            if character_literal?(n)
              interpolated = true
              begin_pos = n.loc.expression.begin_pos + '?'.length
              end_pos = n.loc.expression.end_pos
            else
              begin_pos = n.loc.begin.end_pos
              end_pos = n.loc.end.begin_pos
            end
            Parser::Source::Range.new(sb, begin_pos, end_pos).source
          end.join(' ')

          char = interpolated ? 'W' : 'w'

          @corrections << lambda do |corrector|
            corrector.replace(node.loc.expression, "%#{char}(#{contents})")
          end
        end

        def character_literal?(node)
          node.loc.end.nil?
        end
      end
    end
  end
end
