# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe Grammar do
      EXAMPLE = '3.times { |i| x = i }'
      let (:grammar) { Grammar.new(Ripper.lex(EXAMPLE)) }

      it "correlates token indices to grammar paths" do
        method_block = [:program, :method_add_block]
        grammar.correlate(Ripper.sexp(EXAMPLE)).should == {
          0  => method_block + [:call, :@int],
          2  => method_block + [:call, :@ident],
          6  => method_block + [:brace_block, :block_var],
          7  => method_block + [:brace_block, :block_var, :params, :@ident],
          8  => method_block + [:brace_block, :block_var],
          10 => method_block + [:brace_block, :assign, :var_field, :@ident],
          12 => method_block + [:brace_block, :assign],
          14 => method_block + [:brace_block, :assign, :var_ref, :@ident],
        }
      end
    end
  end
end
