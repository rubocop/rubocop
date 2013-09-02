# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe AvoidClassVars do
        let(:acv) { AvoidClassVars.new }

        it 'registers an offence for class variable declaration' do
          inspect_source(acv,
                         ['class TestClass; @@test = 10; end'])
          expect(acv.offences.size).to eq(1)
          expect(acv.messages)
            .to eq(['Replace class var @@test with a class instance var.'])
        end

        it 'does not register an offence for class variable usage' do
          inspect_source(acv,
                         ['@@test.test(20)'])
          expect(acv.offences).to be_empty
        end
      end
    end
  end
end
