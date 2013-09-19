# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe LambdaCall do
        subject(:cop) { described_class.new }

        it 'registers an offence for x.()' do
          inspect_source(cop,
                         ['x.(a, b)'])
          expect(cop.offences.size).to eq(1)
        end

        it 'accepts x.call()' do
          inspect_source(cop, ['x.call(a, b)'])
          expect(cop.offences).to be_empty
        end

        it 'auto-corrects x.() to x.call()' do
          new_source = autocorrect_source(cop, ['a.(x)'])
          expect(new_source).to eq('a.call(x)')
        end
      end
    end
  end
end
