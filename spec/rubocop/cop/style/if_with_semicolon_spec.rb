# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe IfWithSemicolon do
        let(:iws) { IfWithSemicolon.new }

        it 'registers an offence for one line if/;/end' do
          inspect_source(iws, ['if cond; run else dont end'])
          expect(iws.messages).to eq(
            ['Never use if x; Use the ternary operator instead.'])
        end

        it 'can handle modifier conditionals' do
          inspect_source(iws, ['class Hash',
                               'end if RUBY_VERSION < "1.8.7"'])
          expect(iws.messages).to be_empty
        end
      end
    end
  end
end
