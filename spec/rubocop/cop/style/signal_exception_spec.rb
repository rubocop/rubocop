# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe SignalException do
        subject(:cop) { described_class.new }

        it 'registers an offence for raise in begin section' do
          inspect_source(cop,
                         ['begin',
                          '  raise',
                          'rescue Exception',
                          '  #do nothing',
                          'end'])
          expect(cop.offences.size).to eq(1)
          expect(cop.messages)
            .to eq(['Use `fail` instead of `raise` to signal exceptions.'])
        end

        it 'registers an offence for raise in def body' do
          inspect_source(cop,
                         ['def test',
                          '  raise',
                          'rescue Exception',
                          '  #do nothing',
                          'end'])
          expect(cop.offences.size).to eq(1)
          expect(cop.messages)
            .to eq(['Use `fail` instead of `raise` to signal exceptions.'])
        end

        it 'registers an offence for fail in rescue section' do
          inspect_source(cop,
                         ['begin',
                          '  fail',
                          'rescue Exception',
                          '  fail',
                          'end'])
          expect(cop.offences.size).to eq(1)
          expect(cop.messages)
            .to eq(['Use `raise` instead of `fail` to rethrow exceptions.'])
        end

        it 'registers an offence for fail def rescue section' do
          inspect_source(cop,
                         ['def test',
                          '  fail',
                          'rescue Exception',
                          '  fail',
                          'end'])
          expect(cop.offences.size).to eq(1)
          expect(cop.messages)
            .to eq(['Use `raise` instead of `fail` to rethrow exceptions.'])
        end

        it 'is not confused by nested begin/rescue' do
          inspect_source(cop,
                         ['begin',
                          '  raise',
                          '  begin',
                          '    raise',
                          '  rescue',
                          '    fail',
                          '  end',
                          'rescue Exception',
                          '  #do nothing',
                          'end'])
          expect(cop.offences.size).to eq(3)
          expect(cop.messages)
            .to eq(['Use `fail` instead of `raise` to signal exceptions.'] * 2 +
                   ['Use `raise` instead of `fail` to rethrow exceptions.'])
        end

        it 'auto-corrects raise to fail when appropriate' do
          new_source = autocorrect_source(cop,
                                          ['begin',
                                           '  raise',
                                           'rescue Exception',
                                           '  raise',
                                           'end'])
          expect(new_source).to eq(['begin',
                                    '  fail',
                                    'rescue Exception',
                                    '  raise',
                                    'end'].join("\n"))
        end

        it 'auto-corrects fail to raise when appropriate' do
          new_source = autocorrect_source(cop,
                                          ['begin',
                                           '  fail',
                                           'rescue Exception',
                                           '  fail',
                                           'end'])
          expect(new_source).to eq(['begin',
                                    '  fail',
                                    'rescue Exception',
                                    '  raise',
                                    'end'].join("\n"))
        end
      end
    end
  end
end
