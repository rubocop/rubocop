# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe AvoidPerlBackrefs do
        let(:ap) { AvoidPerlBackrefs.new }

        it 'registers an offence for $1' do
          inspect_source(ap, ['puts $1'])
          expect(ap.offences.size).to eq(1)
          expect(ap.offences.map(&:message))
            .to eq(['Prefer the use of MatchData over $1.'])
        end
      end
    end
  end
end
