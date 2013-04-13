# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe WhenThen do
      let(:wt) { WhenThen.new }

      it 'registers an offence for when x;' do
        inspect_source(wt, 'file.rb', ['case a',
                                       'when b; c',
                                       'end'])
        expect(wt.offences.map(&:message)).to eq(
          ['Never use "when x;". Use "when x then" instead.'])
      end

      it 'misses semicolon but does not crash when there are no tokens' do
        inspect_source(wt, 'file.rb', ['case a',
                                       'when []; {}',
                                       'end'])
        expect(wt.offences.map(&:message)).to eq([])
      end

      it 'accepts when x then' do
        inspect_source(wt, 'file.rb', ['case a',
                                       'when b then c',
                                       'end'])
        expect(wt.offences.map(&:message)).to be_empty
      end

      it 'accepts ; separating statements in the body of when' do
        inspect_source(wt, 'file.rb', ['case a',
                                       'when b then c; d',
                                       'end',
                                       '',
                                       'case e',
                                       'when f',
                                       '  g; h',
                                       'end'])
        expect(wt.offences.map(&:message)).to be_empty
      end
    end
  end
end
