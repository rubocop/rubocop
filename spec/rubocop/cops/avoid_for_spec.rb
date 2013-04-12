# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe AvoidFor do
      let(:af) { AvoidFor.new }

      it 'registers an offence for for' do
        inspect_source(af,
                       'file.rb',
                       ['for n in [1, 2, 3] do',
                        'puts n',
                        'end'])
        expect(af.offences.size).to eq(1)
        expect(af.offences.map(&:message))
          .to eq([AvoidFor::ERROR_MESSAGE])
      end
    end
  end
end
