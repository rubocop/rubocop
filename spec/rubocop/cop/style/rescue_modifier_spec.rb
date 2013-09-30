# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::RescueModifier do
  subject(:cop) { described_class.new }

  it 'registers an offence for modifier rescue' do
    inspect_source(cop,
                   ['method rescue handle'])
    expect(cop.offences.size).to eq(1)
    expect(cop.messages)
      .to eq(['Avoid using rescue in its modifier form.'])
  end

  it 'handles more complex expression with modifier rescue' do
    inspect_source(cop,
                   ['method1 or method2 rescue handle'])
    expect(cop.offences.size).to eq(1)
    expect(cop.messages)
      .to eq(['Avoid using rescue in its modifier form.'])
  end

  it 'handles modifier rescue in normal rescue' do
    inspect_source(cop,
                   ['begin',
                    '  test rescue modifier_handle',
                    'rescue',
                    '  normal_handle',
                    'end'])
    expect(cop.offences.size).to eq(1)
    expect(cop.offences.first.line).to eq(2)
  end

  it 'does not register an offence for normal rescue' do
    inspect_source(cop,
                   ['begin',
                    '  test',
                    'rescue',
                    '  handle',
                    'end'])
    expect(cop.offences).to be_empty
  end

  it 'does not register an offence for normal rescue with ensure' do
    inspect_source(cop,
                   ['begin',
                    '  test',
                    'rescue',
                    '  handle',
                    'ensure',
                    '  cleanup',
                    'end'])
    expect(cop.offences).to be_empty
  end

  it 'does not register an offence for nested normal rescue' do
    inspect_source(cop,
                   ['begin',
                    '  begin',
                    '    test',
                    '  rescue',
                    '    handle_inner',
                    '  end',
                    'rescue',
                    '  handle_outer',
                    'end'])
    expect(cop.offences).to be_empty
  end

  context 'when an instance method has implicit begin' do
    it 'accepts normal rescue' do
      inspect_source(cop,
                     ['def some_method',
                      '  test',
                      'rescue',
                      '  handle',
                      'end'])
      expect(cop.offences).to be_empty
    end

    it 'handles modifier rescue in body of implicit begin' do
      inspect_source(cop,
                     ['def some_method',
                      '  test rescue modifier_handle',
                      'rescue',
                      '  normal_handle',
                      'end'])
      expect(cop.offences.size).to eq(1)
      expect(cop.offences.first.line).to eq(2)
    end
  end

  context 'when a singleton method has implicit begin' do
    it 'accepts normal rescue' do
      inspect_source(cop,
                     ['def self.some_method',
                      '  test',
                      'rescue',
                      '  handle',
                      'end'])
      expect(cop.offences).to be_empty
    end

    it 'handles modifier rescue in body of implicit begin' do
      inspect_source(cop,
                     ['def self.some_method',
                      '  test rescue modifier_handle',
                      'rescue',
                      '  normal_handle',
                      'end'])
      expect(cop.offences.size).to eq(1)
      expect(cop.offences.first.line).to eq(2)
    end
  end
end
