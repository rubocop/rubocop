# encoding: utf-8

module Rubocop
  module Cop
    class Grammar
      def initialize(tokens)
        @tokens_without_pos = tokens.map { |t| [t.type, t.text] }
        process_embedded_expressions if RUBY_VERSION < '2.0'
        @token_indexes = {}
        @tokens_without_pos.each_with_index do |t, i|
          @token_indexes[t] ||= []
          @token_indexes[t] << i
        end
        @ix = 0
        @table = {}
        token_positions = tokens.map { |t| [t.pos.lineno, t.pos.column] }
        @index_by_pos = Hash[*token_positions.each_with_index.to_a.flatten(1)]
        @special = {
          assign:      [[:on_op,     '=']],
          brace_block: [[:on_lbrace, '{']],
          hash:        [[:on_lbrace, '{']],
          ifop:        [[:on_op, '?'], [:on_op, ':']]
        }
      end

      # In ruby 1.9.3 and below, the string "#{x}" will give the tokens
      # [:on_tstring_beg, '"'], [:on_embexpr_beg, '#{'], [:on_ident, 'x'],
      # [:on_rbrace, '}'], [:on_tstring_end, '"']
      # which is not so good for us. We want to distinguish between a
      # right brace that ends an embedded expression inside a string
      # and an ordinary right brace. So we replace :on_rbrace with the
      # made up :on_embexpr_end.
      def process_embedded_expressions
        state = :outside
        brace_depth = 0
        @tokens_without_pos.each_with_index do |(type, _), ix|
          case state
          when :outside
            state = :inside_string if type == :on_tstring_beg
          when :inside_string
            case type
            when :on_tstring_end
              state = :outside
            when :on_embexpr_beg
              brace_depth = 1
              state = :inside_expr
            end
          when :inside_expr
            case type
            when :on_lbrace, :on_embexpr_end
              brace_depth += 1
            when :on_rbrace
              if brace_depth == 1
                @tokens_without_pos[ix][0] = :on_embexpr_end
                state = :inside_string
              end
              brace_depth -= 1
            end
          end
        end
      end

      # Returns a hash mapping indexes in the token array to grammar
      # paths, e.g.:
      # {  0 => [:program, :assign, :var_field, :@ident],
      #    1 => [:program, :assign],
      #    2 => [:program, :assign, :@int],
      #    4 => [:program, :assign, :var_field, :@ident],
      #    5 => [:program, :assign],
      #    7 => [:program, :assign, :@int],
      #    9 => [:program, :assign, :var_field, :@ident],
      #   11 => [:program, :assign],
      #   12 => [:program, :assign, :@int] }
      def correlate(sexp, path = [])
        case sexp
        when Array
          case sexp[0]
          when /^@/
            # Leaves in the grammar have a corresponding token with a
            # position, which we search for and advance @ix.
            @ix = @index_by_pos[[sexp[-1].lineno, sexp[-1].column]]
            fail "#{sexp}\n#{@index_by_pos}" unless @ix
            @table[@ix] = path + [sexp[0]]
            @ix += 1
          when *@special.keys
            # Here we don't advance @ix because there may be other
            # tokens inbetween the current one and the one we get from
            # @special.
            @special[sexp[0]].each do |token_to_find|
              find(path, sexp, token_to_find)
            end
          when :block_var # "{ |...|" or "do |...|"
            @ix = find(path, sexp, [:on_op, '|']) + 1
            find(path, sexp, [:on_op, '|'])
          end
          path += [sexp[0]] if Symbol === sexp[0]
          # Compensate for reverse order of if/unless/while/until modifier.
          modifiers = [:if_mod, :unless_mod, :while_mod, :until_mod]
          children = modifiers.include?(sexp[0]) ? sexp.reverse : sexp

          children.each do |elem|
            case elem
            when Array then correlate(elem, path) # Dive deeper
            when Symbol
              unless elem.to_s =~ /^@?[a-z_]+$/
                # There's a trailing @ in some symbols in sexp,
                # e.g. :-@, that don't appear in tokens. That's why we
                # chomp it off.
                find(path, [elem], [:on_op, elem.to_s.chomp('@')])
              end
            end
          end
        end
        @table
      end

      private

      def find(path, sexp, token_to_find)
        indices = @token_indexes[token_to_find] or return
        ix = indices.find { |i| i >= @ix } or return
        @table[ix] = path + [sexp[0]]
        add_matching_rbrace(ix) if token_to_find == [:on_lbrace, '{']
        ix
      end

      def add_matching_rbrace(ix)
        brace_depth = 0
        rbrace_offset = @tokens_without_pos[ix..-1].index do |t|
          brace_depth += 1 if t == [:on_lbrace, '{']
          brace_depth -= 1 if t == [:on_rbrace, '}']
          brace_depth == 0 && t == [:on_rbrace, '}']
        end
        @table[ix + rbrace_offset] = @table[ix] if rbrace_offset
      end
    end
  end
end
