# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe MultilineTernaryOperator do
      let(:op) { MultilineTernaryOperator.new }

      it 'registers an offence for a multiline ternary operator expression' do
        inspect_source(op, 'file.rb', ['a = cond ?',
                                        '  b : c'])
        expect(op.offences.map(&:message)).to eq(
          ['Avoid multi-line ?: (the ternary operator); use if/unless ' +
           'instead.'])
      end

      it 'accepts a single line ternary operator expression' do
        inspect_source(op, 'file.rb', ['a = cond ? b : c'])
        expect(op.offences.map(&:message)).to be_empty
      end
    end

    describe NestedTernaryOperator do
      let(:op) { NestedTernaryOperator.new }

      it 'registers an offence for a nested ternary operator expression' do
        inspect_source(op, 'file.rb', ['a ? (b ? b1 : b2) : a2'])
        expect(op.offences.map(&:message)).to eq(
          ['Ternary operators must not be nested. Prefer if/else constructs ' +
           'instead.'])
      end

      it 'accepts a non-nested ternary operator within an if' do
        inspect_source(op, 'file.rb', ['a = if x',
                                       '  cond ? b : c',
                                       'else',
                                       '  d',
                                       'end'])
        expect(op.offences.map(&:message)).to be_empty
      end
    end
  end
end
