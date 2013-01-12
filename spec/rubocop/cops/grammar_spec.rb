# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe Grammar do
      EXAMPLE = '3.times { |i| x = "#{y}#{z}}" }'
      tokens = Ripper.lex(EXAMPLE).map { |t| Token.new(*t) }
      let (:grammar) { Grammar.new(tokens) }

      it 'correlates token indices to grammar paths' do
        method_block = [:program, :method_add_block]
        brace_block = method_block + [:brace_block]
        Ripper.lex(EXAMPLE).should ==
          [[[1, 0], :on_int, '3'],
           [[1, 1], :on_period, '.'],
           [[1, 2], :on_ident, 'times'],
           [[1, 7], :on_sp, ' '],
           [[1, 8], :on_lbrace, '{'],
           [[1, 9], :on_sp, ' '], # 5
           [[1, 10], :on_op, '|'],
           [[1, 11], :on_ident, 'i'],
           [[1, 12], :on_op, '|'],
           [[1, 13], :on_sp, ' '],
           [[1, 14], :on_ident, 'x'], # 10
           [[1, 15], :on_sp, ' '],
           [[1, 16], :on_op, '='],
           [[1, 17], :on_sp, ' '],
           [[1, 18], :on_tstring_beg, '"'],
           [[1, 19], :on_embexpr_beg, '#{'], # 15
           [[1, 21], :on_ident, 'y'],
           [[1, 22], :on_rbrace, '}'],
           [[1, 23], :on_embexpr_beg, '#{'],
           [[1, 25], :on_ident, 'z'],
           [[1, 26], :on_rbrace, '}'], # 20
           [[1, 27], :on_tstring_content, '}'],
           [[1, 28], :on_tstring_end, '"'],
           [[1, 29], :on_sp, ' '],
           [[1, 30], :on_rbrace, '}']]

        sexp = Ripper.sexp(EXAMPLE)
        Position.make_position_objects(sexp)

        varref = (RUBY_VERSION == '1.9.2') ? :var_ref : :vcall
        grammar.correlate(sexp).should == {
          0  => method_block + [:call, :@int],                    # 3
          2  => method_block + [:call, :@ident],                  # times
          4  => brace_block,                                      # {
          6  => brace_block + [:block_var],                       # |
          7  => brace_block + [:block_var, :params, :@ident],     # i
          8  => brace_block + [:block_var],                       # |
          10 => brace_block + [:assign, :var_field, :@ident],     # x
          12 => brace_block + [:assign],                          # =
          16 => brace_block + [:assign, :string_literal, :string_content,
                               :string_embexpr, varref, :@ident], # y
          19 => brace_block + [:assign, :string_literal, :string_content,
                               :string_embexpr, varref, :@ident], # z
          21 => brace_block + [:assign, :string_literal, :string_content,
                               :@tstring_content],                # }
          24 => brace_block,                                      # }
        }
      end
    end
  end
end
