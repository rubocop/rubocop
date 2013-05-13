# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe AvoidClassVars do
      let(:acv) { AvoidClassVars.new }

      it 'registers an offence for class variable declaration' do
        inspect_source(acv,
                       'file.rb',
                       ['class TestClass; @@test = 10; end'])
        expect(acv.offences.size).to eq(1)
        expect(acv.offences.map(&:message))
          .to eq(['Replace class var @@test with a class instance var.'])
      end

      it 'does not register an offence for class variable usage' do
        inspect_source(acv,
                       'file.rb',
                       ['@@test.test(20)'])
        expect(acv.offences).to be_empty
      end
    end
  end
end
