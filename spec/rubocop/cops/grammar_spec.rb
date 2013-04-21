# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe Grammar do
      EXAMPLE = '3.times { |i| x = "#{c ? y : a}#{z}}" }'
      tokens = Ripper.lex(EXAMPLE).map { |t| Token.new(*t) }
      let(:grammar) { Grammar.new(tokens) }

      it 'correlates token indices to grammar paths' do
        method_block = [:program, :method_add_block]
        brace_block = method_block + [:brace_block]
        string_embexpr = brace_block + [:assign, :string_literal,
                                        :string_content,
                                        :string_embexpr]

        test_2_0 = [[[1, 0], :on_int, '3'],
          [[1, 1], :on_period, '.'],
          [[1, 2], :on_ident, 'times'],
          [[1, 7], :on_sp, ' '],
          [[1, 8], :on_lbrace, '{'],
          [[1, 9], :on_sp, ' '], # 5
          [[1, 10], :on_op, '|'],
          [[1, 11], :on_ident, 'i'],
          [[1, 12], :on_op, '|'],
          [[1, 13], :on_sp, ' '],
          [[1, 14], :on_ident, 'x'],
          [[1, 15], :on_sp, ' '],
          [[1, 16], :on_op, '='],
          [[1, 17], :on_sp, ' '],
          [[1, 18], :on_tstring_beg, '"'],
          [[1, 19], :on_embexpr_beg, '#{'],
          [[1, 21], :on_ident, 'c'],
          [[1, 22], :on_sp, ' '],
          [[1, 23], :on_op, '?'],
          [[1, 24], :on_sp, ' '],
          [[1, 25], :on_ident, 'y'],
          [[1, 26], :on_sp, ' '],
          [[1, 27], :on_op, ':'],
          [[1, 28], :on_sp, ' '],
          [[1, 29], :on_ident, 'a'],
          [[1, 30], :on_embexpr_end, '}'],
          [[1, 31], :on_embexpr_beg, '#{'],
          [[1, 33], :on_ident, 'z'],
          [[1, 34], :on_embexpr_end, '}'],
          [[1, 35], :on_tstring_content, '}'],
          [[1, 36], :on_tstring_end, '"'],
          [[1, 37], :on_sp, ' '],
          [[1, 38], :on_rbrace, '}']]
        expect(Ripper.lex(EXAMPLE)).to eq(test_2_0) if RUBY_VERSION >= '2.0'
        sexp = Ripper.sexp(EXAMPLE)
        Position.make_position_objects(sexp)

        varref = (RUBY_VERSION == '1.9.2') ? :var_ref : :vcall

        test = {
          0  => method_block + [:call, :@int],                      # 3
          2  => method_block + [:call, :@ident],                    # times
          4  => brace_block,                                        # {
          6  => brace_block + [:block_var],                         # |
          7  => brace_block + [:block_var, :params, :@ident],       # i
          8  => brace_block + [:block_var],                         # |
          10 => brace_block + [:assign, :var_field, :@ident],       # x
          12 => brace_block + [:assign],                            # =
          16 => string_embexpr + [:ifop, varref, :@ident],          # c
          18 => string_embexpr + [:ifop],                           # ?
          20 => string_embexpr + [:ifop, varref, :@ident],          # y
          22 => string_embexpr + [:ifop],                           # :
          24 => string_embexpr + [:ifop, varref, :@ident],          # a
          27 => string_embexpr + [:vcall, :@ident],                 # z
          29 => brace_block + [:assign, :string_literal,
                               :string_content, :@tstring_content], # }
          32 => brace_block,
        }
        expect(grammar.correlate(sexp)).to eq(test)
      end
    end
  end
end
