# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Lint::RescueException do
  subject(:cop) { described_class.new }

  it 'registers an offense for rescue from Exception' do
    inspect_source(cop,
                   ['begin',
                    '  something',
                    'rescue Exception',
                    '  #do nothing',
                    'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for rescue with ::Exception' do
    inspect_source(cop,
                   ['begin',
                    '  something',
                    'rescue ::Exception',
                    '  #do nothing',
                    'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for rescue with StandardError, Exception' do
    inspect_source(cop,
                   ['begin',
                    '  something',
                    'rescue StandardError, Exception',
                    '  #do nothing',
                    'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for rescue with Exception => e' do
    inspect_source(cop,
                   ['begin',
                    '  something',
                    'rescue Exception => e',
                    '  #do nothing',
                    'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'does not register an offense for rescue with no class' do
    inspect_source(cop,
                   ['begin',
                    '  something',
                    '  return',
                    'rescue',
                    '  file.close',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'does not register an offense for rescue with no class and => e' do
    inspect_source(cop,
                   ['begin',
                    '  something',
                    '  return',
                    'rescue => e',
                    '  file.close',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'does not register an offense for rescue with other class' do
    inspect_source(cop,
                   ['begin',
                    '  something',
                    '  return',
                    'rescue ArgumentError => e',
                    '  file.close',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'does not register an offense for rescue with other classes' do
    inspect_source(cop,
                   ['begin',
                    '  something',
                    '  return',
                    'rescue EOFError, ArgumentError => e',
                    '  file.close',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'does not register an offense for rescue with a module prefix' do
    inspect_source(cop,
                   ['begin',
                    '  something',
                    '  return',
                    'rescue Test::Exception => e',
                    '  file.close',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'does not crash when the splat operator is used in a rescue' do
    inspect_source(cop,
                   ['ERRORS = [Exception]',
                    'begin',
                    '  a = 3 / 0',
                    'rescue *ERRORS',
                    '  puts e',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'does not crash when the namespace of a rescued class is in a local ' \
     'variable' do
    inspect_source(cop,
                   ['adapter = current_adapter',
                    'begin',
                    'rescue adapter::ParseError',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  context 'without exception capture' do
    let(:source) do
      ['begin',
       'rescue Exception',
       'end']
    end

    let(:corrected_source) do
      ['begin', # rubocop:disable Style/WordArray
       'rescue',
       'end'].join("\n")
    end

    it 'autocorrects by unspecifying the exception class' do
      expect(autocorrect_source(cop, source)).to eq(corrected_source)
    end
  end

  context 'with exception capture' do
    let(:source) do
      ['begin',
       'rescue Exception => e',
       'end']
    end

    let(:corrected_source) do
      ['begin',
       'rescue => e',
       'end'].join("\n")
    end

    it 'autocorrects by unspecifying the exception class' do
      expect(autocorrect_source(cop, source)).to eq(corrected_source)
    end
  end
end
