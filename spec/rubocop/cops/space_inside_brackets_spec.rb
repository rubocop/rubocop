# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe SpaceInsideBrackets do
      let(:space) { SpaceInsideBrackets.new }

      it 'registers an offence for an array literal with spaces inside' do
        inspect_source(space, 'file.rb', ['a = [1, 2 ]',
                                         'b = [ 1, 2]'])
        expect(space.offences.map(&:message)).to eq(
          ['Space inside square brackets detected.',
           'Space inside square brackets detected.'])
      end

      it 'accepts space inside square brackets if on its own row' do
        inspect_source(space, 'file.rb', ['a = [',
                                         '     1, 2',
                                         '    ]'])
        expect(space.offences.map(&:message)).to be_empty
      end

      it 'accepts square brackets as method name' do
        inspect_source(space, 'file.rb', ['def Vector.[](*array)',
                                         'end'])
        expect(space.offences.map(&:message)).to be_empty
      end

      it 'accepts square brackets called with method call syntax' do
        inspect_source(space, 'file.rb', ['subject.[](0)'])
        expect(space.offences.map(&:message)).to be_empty
      end

      it 'only reports a single space once' do
        inspect_source(space, 'file.rb', ['[ ]'])
        expect(space.offences.map(&:message)).to eq(
          ['Space inside square brackets detected.'])
      end
    end
  end
end
