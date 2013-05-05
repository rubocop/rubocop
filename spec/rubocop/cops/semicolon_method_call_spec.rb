# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe SemicolonMethodCall do
      let(:smc) { SemicolonMethodCall.new }

      it 'registers an offence for instance method call' do
        inspect_source(smc,
                       'file.rb',
                       ['test::method_name'])
        expect(smc.offences.size).to eq(1)
      end

      it 'registers an offence for class method call' do
        inspect_source(smc,
                       'file.rb',
                       ['Class::method_name'])
        expect(smc.offences.size).to eq(1)
      end

      it 'does not register an offence for constant access' do
        inspect_source(smc,
                       'file.rb',
                       ['Tip::Top::SOME_CONST'])
        expect(smc.offences).to be_empty
      end

    end
  end
end
