# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe BraceAfterPercent do
      let(:bap) { BraceAfterPercent.new }

      it 'registers an offence for %w[' do
        inspect_source(bap,
                       'file.rb',
                       ['puts %w[test top]'])
        expect(bap.offences.size).to eq(1)
        expect(bap.offences.map(&:message))
          .to eq([BraceAfterPercent::ERROR_MESSAGE])
      end

      it 'registers an offence for %w(' do
        inspect_source(bap,
                       'file.rb',
                       ['puts %w(test top)'])
        expect(bap.offences).to be_empty
      end
    end
  end
end
