# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe AvoidClassVars do
      let(:acv) { AvoidClassVars.new }

      it 'registers an offence for class variables' do
        inspect_source(acv,
                       'file.rb',
                       ['class TestClass; @@test = 10; end'])
        expect(acv.offences.size).to eq(1)
        expect(acv.offences.map(&:message))
          .to eq(['Replace class var @@test with a class instance var.'])
      end
    end
  end
end
