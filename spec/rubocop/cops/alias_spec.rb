# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe Alias do
      let(:a) { Alias.new }

      it 'registers an offence for alias' do
        inspect_source(a,
                       'file.rb',
                       ['alias :ala :bala'])
        expect(a.offences.size).to eq(1)
        expect(a.offences.map(&:message))
          .to eq([Alias::ERROR_MESSAGE])
      end

      it 'does not mess with double alias' do
        culprit = <<-EOS
    alias has_foo? foo?
    alias has_bar? bar?
    EOS
        inspect_source(a,
                       'file.rb',
                       [culprit])
        expect(a.offences.size).to eq(2)
        expect(a.offences.map(&:message))
          .to eq([Alias::ERROR_MESSAGE, Alias::ERROR_MESSAGE])
      end

      it 'does not register an offence for alias_method' do
        inspect_source(a,
                       'file.rb',
                       ['alias_method :ala, :bala'])
        expect(a.offences).to be_empty
      end
    end
  end
end
