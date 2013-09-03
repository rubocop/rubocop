# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Lint
      describe EmptyEnsure do
        subject(:cop) { EmptyEnsure.new }

        it 'registers an offence for empty ensure' do
          inspect_source(cop,
                         ['begin',
                          '  something',
                          'ensure',
                          'end'])
          expect(cop.offences.size).to eq(1)
        end

        it 'does not register an offence for non-empty ensure' do
          inspect_source(cop,
                         ['begin',
                          '  something',
                          '  return',
                          'ensure',
                          '  file.close',
                          'end'])
          expect(cop.offences).to be_empty
        end
      end
    end
  end
end
