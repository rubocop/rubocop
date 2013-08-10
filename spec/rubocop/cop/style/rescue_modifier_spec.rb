# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
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

        it 'handles modifier rescue in normal rescue' do
          inspect_source(rm,
                         ['begin',
                          '  test rescue modifier_handle',
                          'rescue',
                          '  normal_handle',
                          'end'])
          expect(rm.offences.size).to eq(1)
          expect(rm.offences.first.line).to eq(2)
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

        it 'does not register an offence for normal rescue with ensure' do
          inspect_source(rm,
                         ['begin',
                          '  test',
                          'rescue',
                          '  handle',
                          'ensure',
                          '  cleanup',
                          'end'])
          expect(rm.offences).to be_empty
        end

        it 'does not register an offence for nested normal rescue' do
          inspect_source(rm,
                         ['begin',
                          '  begin',
                          '    test',
                          '  rescue',
                          '    handle_inner',
                          '  end',
                          'rescue',
                          '  handle_outer',
                          'end'])
          expect(rm.offences).to be_empty
        end

        context 'when an instance method has implicit begin' do
          it 'accepts normal rescue' do
            inspect_source(rm,
                           ['def some_method',
                            '  test',
                            'rescue',
                            '  handle',
                            'end'])
            expect(rm.offences).to be_empty
          end

          it 'handles modifier rescue in body of implicit begin' do
            inspect_source(rm,
                           ['def some_method',
                            '  test rescue modifier_handle',
                            'rescue',
                            '  normal_handle',
                            'end'])
            expect(rm.offences.size).to eq(1)
            expect(rm.offences.first.line).to eq(2)
          end
        end

        context 'when a singleton method has implicit begin' do
          it 'accepts normal rescue' do
            inspect_source(rm,
                           ['def self.some_method',
                            '  test',
                            'rescue',
                            '  handle',
                            'end'])
            expect(rm.offences).to be_empty
          end

          it 'handles modifier rescue in body of implicit begin' do
            inspect_source(rm,
                           ['def self.some_method',
                            '  test rescue modifier_handle',
                            'rescue',
                            '  normal_handle',
                            'end'])
            expect(rm.offences.size).to eq(1)
            expect(rm.offences.first.line).to eq(2)
          end
        end
      end
    end
  end
end
