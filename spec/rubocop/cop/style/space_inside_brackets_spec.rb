# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe SpaceInsideBrackets do
        let(:space) { SpaceInsideBrackets.new }

        it 'registers an offence for an array literal with spaces inside' do
          inspect_source(space, ['a = [1, 2 ]',
                                           'b = [ 1, 2]'])
          expect(space.messages).to eq(
            ['Space inside square brackets detected.',
             'Space inside square brackets detected.'])
        end

        it 'accepts space inside strings within square brackets' do
          inspect_source(space, ["['Encoding:',",
                                 " '  Enabled: false']"])
          expect(space.messages).to be_empty
        end

        it 'accepts space inside square brackets if on its own row' do
          inspect_source(space, ['a = [',
                                 '     1, 2',
                                 '    ]'])
          expect(space.messages).to be_empty
        end

        it 'accepts square brackets as method name' do
          inspect_source(space, ['def Vector.[](*array)',
                                           'end'])
          expect(space.messages).to be_empty
        end

        it 'accepts square brackets called with method call syntax' do
          inspect_source(space, ['subject.[](0)'])
          expect(space.messages).to be_empty
        end

        it 'only reports a single space once' do
          inspect_source(space, ['[ ]'])
          expect(space.messages).to eq(
            ['Space inside square brackets detected.'])
        end
      end
    end
  end
end
