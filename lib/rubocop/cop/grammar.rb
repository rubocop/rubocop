module Rubocop
  module Cop
    class Grammar
      def initialize(tokens)
        @tokens_without_pos = tokens.map { |tok| tok[1..-1] }
        @ix = 0
        @table = {}
        token_positions = tokens.map { |tok| tok[0] }
        @index_by_pos = Hash[*token_positions.each_with_index.to_a.flatten(1)]
        @special = {
          'assign'         => [:on_op, '='],
          'rest_param'     => [:on_op, '*'],
          'blockarg'       => [:on_op, '&'],
          'args_add_star'  => [:on_op, '*'],
          'args_add_block' => [:on_op, '&'],
          'dot2'           => [:on_op, '..'],
          'const_path_ref' => [:on_op, '::'],
        }
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
          case sexp[0].to_s
          when /^@/
            # Leaves in the grammar have a corresponding token with a
            # position, which we search for and advance @ix.
            @ix = @index_by_pos[sexp[-1]]
            @table[@ix] = path + [sexp[0]]
          when *@special.keys
            find(path, sexp, @special[sexp[0].to_s])
          when *%w'case when then break return0'
            find(path, sexp, [:on_kw, sexp[0].to_s[%r'^[a-z]+']])
          when *%w'block_var'
            @ix = find(path, sexp, [:on_op, '|'])
            @ix += 1
            find(path, sexp, [:on_op, '|'])
          end
          path += [sexp[0]] unless Array === sexp[0]
          sexp.each { |elem|
            case elem
            when Array
              correlate(elem, path)
            when Symbol
              unless elem.to_s =~ /^@?[a-z_]+$/
                find(path, [elem], [:on_op, elem.to_s.chomp('@')])
              end
            end
          }
        when :"."
          find(path, [sexp], [:on_period, sexp.to_s])
        end
        @table
      end

      private

      def find(path, sexp, token_to_find)
        offset = @tokens_without_pos[@ix..-1].index(token_to_find) or return
        ix = @ix + offset
        @table[ix] = path + [sexp[0]]
        ix
      end
    end
  end
end
