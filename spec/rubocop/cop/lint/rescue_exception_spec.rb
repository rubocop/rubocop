# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Lint
      describe RescueException do
        subject(:re) { RescueException.new }

        it 'registers an offence for rescue from Exception' do
          inspect_source(re,
                         ['begin',
                          '  something',
                          'rescue Exception',
                          '  #do nothing',
                          'end'])
          expect(re.offences.size).to eq(1)
          expect(re.messages)
            .to eq([RescueException::MSG])
        end

        it 'registers an offence for rescue with ::Exception' do
          inspect_source(re,
                         ['begin',
                          '  something',
                          'rescue ::Exception',
                          '  #do nothing',
                          'end'])
          expect(re.offences.size).to eq(1)
          expect(re.messages)
            .to eq([RescueException::MSG])
        end

        it 'registers an offence for rescue with StandardError, Exception' do
          inspect_source(re,
                         ['begin',
                          '  something',
                          'rescue StandardError, Exception',
                          '  #do nothing',
                          'end'])
          expect(re.offences.size).to eq(1)
          expect(re.messages)
            .to eq([RescueException::MSG])
        end

        it 'registers an offence for rescue with Exception => e' do
          inspect_source(re,
                         ['begin',
                          '  something',
                          'rescue Exception => e',
                          '  #do nothing',
                          'end'])
          expect(re.offences.size).to eq(1)
          expect(re.messages)
            .to eq([RescueException::MSG])
        end

        it 'does not register an offence for rescue with no class' do
          inspect_source(re,
                         ['begin',
                          '  something',
                          '  return',
                          'rescue',
                          '  file.close',
                          'end'])
          expect(re.offences).to be_empty
        end

        it 'does not register an offence for rescue with no class and => e' do
          inspect_source(re,
                         ['begin',
                          '  something',
                          '  return',
                          'rescue => e',
                          '  file.close',
                          'end'])
          expect(re.offences).to be_empty
        end

        it 'does not register an offence for rescue with other class' do
          inspect_source(re,
                         ['begin',
                          '  something',
                          '  return',
                          'rescue ArgumentError => e',
                          '  file.close',
                          'end'])
          expect(re.offences).to be_empty
        end

        it 'does not register an offence for rescue with other classes' do
          inspect_source(re,
                         ['begin',
                          '  something',
                          '  return',
                          'rescue EOFError, ArgumentError => e',
                          '  file.close',
                          'end'])
          expect(re.offences).to be_empty
        end

        it 'does not register an offence for rescue with a module prefix' do
          inspect_source(re,
                         ['begin',
                          '  something',
                          '  return',
                          'rescue Test::Exception => e',
                          '  file.close',
                          'end'])
          expect(re.offences).to be_empty
        end

        it 'does not crash when the splat operator is used in a rescue' do
          inspect_source(re,
                         ['ERRORS = [Exception]',
                          'begin',
                          '  a = 3 / 0',
                          'rescue *ERRORS',
                          '  puts e',
                          'end'])
          expect(re.offences).to be_empty
        end
      end
    end
  end
end
