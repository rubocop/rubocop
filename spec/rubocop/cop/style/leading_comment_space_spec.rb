# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe LeadingCommentSpace do
        let(:lcs) { LeadingCommentSpace.new }

        it 'registers an offence for comment without leading space' do
          inspect_source(lcs,
                         ['#missing space'])
          expect(lcs.offences.size).to eq(1)
        end

        it 'does not register an offence for # followed by no text' do
          inspect_source(lcs,
                         ['#'])
          expect(lcs.offences).to be_empty
        end

        it 'does not register an offence for more than one space' do
          inspect_source(lcs,
                         ['#   heavily indented'])
          expect(lcs.offences).to be_empty
        end

        it 'does not register an offence for more than one #' do
          inspect_source(lcs,
                         ['###### heavily indented'])
          expect(lcs.offences).to be_empty
        end

        it 'does not register an offence for only #s' do
          inspect_source(lcs,
                         ['######'])
          expect(lcs.offences).to be_empty
        end

        it 'does not register an offence for #! on first line' do
          inspect_source(lcs,
                         ['#!/usr/bin/ruby',
                          'test'])
          expect(lcs.offences).to be_empty
        end

        it 'registers an offence for #! after the first line' do
          inspect_source(lcs,
                         ['test', '#!/usr/bin/ruby'])
          expect(lcs.offences.size).to eq(1)
        end

        it 'accepts rdoc syntax' do
          inspect_source(lcs,
                         ['#++',
                          '#--',
                          '#:nodoc:'])

          expect(lcs.offences).to be_empty
        end
      end
    end
  end
end
