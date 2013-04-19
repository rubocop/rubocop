# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe PercentLiterals do
      let(:pl) { PercentLiterals.new }

      it 'registers an offence for %q' do
        inspect_source(pl,
                       'file.rb',
                       ['puts %q(test)'])
        expect(pl.offences.size).to eq(1)
        expect(pl.offences.map(&:message))
          .to eq(['The use of %q is discouraged.'])
      end

      it 'registers an offence for %Q' do
        inspect_source(pl,
                       'file.rb',
                       ['puts %Q(test)'])
        expect(pl.offences.size).to eq(1)
        expect(pl.offences.map(&:message))
          .to eq(['The use of %Q is discouraged.'])
      end

      it 'registers an offence for %x' do
        inspect_source(pl,
                       'file.rb',
                       ['puts %x(test)'])
        expect(pl.offences.size).to eq(1)
        expect(pl.offences.map(&:message))
          .to eq(['The use of %x is discouraged.'])
      end

      it 'registers an offence for %s' do
        inspect_source(pl,
                       'file.rb',
                       ['puts %s(test)'])
        expect(pl.offences.size).to eq(1)
        expect(pl.offences.map(&:message))
          .to eq(['The use of %s is discouraged.'])
      end
    end
  end
end
