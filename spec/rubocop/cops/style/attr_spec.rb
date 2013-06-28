# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe Attr do
        let(:cop) { Attr.new }

        it 'registers an offence attr' do
          inspect_source(cop, ['class SomeClass',
                               '  attr :name',
                               'end'])
          expect(cop.offences.size).to eq(1)
        end
      end
    end
  end
end
