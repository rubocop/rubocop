# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe OneLineConditional do
        subject(:cop) { described_class.new }

        it 'registers an offence for one line if/then/end' do
          inspect_source(cop, ['if cond then run else dont end'])
          expect(cop.messages).to eq([cop.error_message])
        end
      end
    end
  end
end
