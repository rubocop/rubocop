# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe BlockComments do
        subject(:cop) { BlockComments.new }

        it 'registers an offence for block comments' do
          inspect_source(cop,
                         ['=begin',
                          'comment',
                          '=end'])
          expect(cop.offences.size).to eq(1)
        end

        it 'accepts regular comments' do
          inspect_source(cop,
                         ['# comment'])
          expect(cop.offences).to be_empty
        end
      end
    end
  end
end
