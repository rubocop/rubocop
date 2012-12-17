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
          assign:         '=',
          rest_param:     '*',
          blockarg:       '&',
          args_add_star:  '*',
          args_add_block: '&',
          dot2:           '..',
          const_path_ref: '::',
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
          case sexp[0]
          when /^@/
            # Leaves in the grammar have a corresponding token with a
            # position, which we search for and advance @ix.
            @ix = @index_by_pos[sexp[-1]]
            @table[@ix] = path + [sexp[0]]
            @ix += 1
          when *@special.keys
            # Here we don't advance @ix because there may be other
            # tokens inbetween the current one and the one we get from
            # @special.
            find(path, sexp, [:on_op, @special[sexp[0]]])
          when :block_var # "{ |...|" or "do |...|"
            @ix = find(path, sexp, [:on_op, '|']) + 1
            find(path, sexp, [:on_op, '|'])
          end
          path += [sexp[0]] if Symbol === sexp[0]
          # Compensate for reverse order of if modifier
          children = (sexp[0] == :if_mod) ? sexp.reverse : sexp

          children.each { |elem|
            case elem
            when Array
              correlate(elem, path) # Dive deeper
            when Symbol
              unless elem.to_s =~ /^@?[a-z_]+$/
                # There's a trailing @ in some symbols in sexp,
                # e.g. :-@, that don't appear in tokens. That's why we
                # chomp it off.
                find(path, [elem], [:on_op, elem.to_s.chomp('@')])
              end
            end
          }
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
