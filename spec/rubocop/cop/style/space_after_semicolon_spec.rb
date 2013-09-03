# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe SpaceAfterSemicolon do
        subject(:space) { SpaceAfterSemicolon.new }

        it 'registers an offence for semicolon without space after it' do
          inspect_source(space, ['x = 1;y = 2'])
          expect(space.messages).to eq(
            ['Space missing after semicolon.'])
        end

        it 'does not crash if semicolon is the last character of the file' do
          inspect_source(space, ['x = 1;'])
          expect(space.messages).to be_empty
        end
      end
    end
  end
end
