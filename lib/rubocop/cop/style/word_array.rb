# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for array literals made up of word-like
      # strings, that are not using the %w() syntax.
      class WordArray < Cop
        include ArraySyntax

        MSG = 'Use %w or %W for array of words.'

        def on_array(node)
          array_elems = node.children
          if array_of?(:str, node) && !complex_content?(array_elems) &&
            array_elems.size > min_size && !comments_in_array?(node)
            convention(node, :expression)
          end
        end

        private

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
      end
    end
  end
end
