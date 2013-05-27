# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe RescueModifier do
      let(:rm) { RescueModifier.new }

      it 'registers an offence for modifier rescue' do
        inspect_source(rm,
                       ['method rescue handle'])
        expect(rm.offences.size).to eq(1)
        expect(rm.offences.map(&:message))
          .to eq([RescueModifier::MSG])
      end

      it 'handles more complex expression with modifier rescue' do
        inspect_source(rm,
                       ['method1 or method2 rescue handle'])
        expect(rm.offences.size).to eq(1)
        expect(rm.offences.map(&:message))
          .to eq([RescueModifier::MSG])
      end

      it 'does not register an offence for normal rescue' do
        inspect_source(rm,
                       ['begin',
                        '  test',
                        'rescue',
                        '  handle',
                        'end'])
        expect(rm.offences).to be_empty
      end
    end
  end
end
