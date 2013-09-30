# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Lint::AssignmentInCondition, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { { 'AllowSafeAssignment' => true } }

  it 'registers an offence for lvar assignment in condition' do
    inspect_source(cop,
                   ['if test = 10',
                    'end'
                   ])
    expect(cop.offences.size).to eq(1)
  end

  it 'registers an offence for lvar assignment in while condition' do
    inspect_source(cop,
                   ['while test = 10',
                    'end'
                   ])
    expect(cop.offences.size).to eq(1)
  end

  it 'registers an offence for lvar assignment in until condition' do
    inspect_source(cop,
                   ['until test = 10',
                    'end'
                   ])
    expect(cop.offences.size).to eq(1)
  end

  it 'registers an offence for ivar assignment in condition' do
    inspect_source(cop,
                   ['if @test = 10',
                    'end'
                   ])
    expect(cop.offences.size).to eq(1)
  end

  it 'registers an offence for clvar assignment in condition' do
    inspect_source(cop,
                   ['if @@test = 10',
                    'end'
                   ])
    expect(cop.offences.size).to eq(1)
  end

  it 'registers an offence for gvar assignment in condition' do
    inspect_source(cop,
                   ['if $test = 10',
                    'end'
                   ])
    expect(cop.offences.size).to eq(1)
  end

  it 'registers an offence for constant assignment in condition' do
    inspect_source(cop,
                   ['if TEST = 10',
                    'end'
                   ])
    expect(cop.offences.size).to eq(1)
  end

  it 'accepts == in condition' do
    inspect_source(cop,
                   ['if test == 10',
                    'end'
                   ])
    expect(cop.offences).to be_empty
  end

  it 'accepts = in a block that is called in a condition' do
    inspect_source(cop,
                   ['return 1 if any_errors? { o = inspect(file) }'])
    expect(cop.offences).to be_empty
  end

  it 'accepts ||= in condition' do
    inspect_source(cop,
                   ['raise StandardError unless foo ||= bar'])
    expect(cop.offences).to be_empty
  end

  context 'safe assignment is allowed' do
    it 'accepts = in condition surrounded with braces' do
      inspect_source(cop,
                     ['if (test = 10)',
                      'end'
                     ])
      expect(cop.offences).to be_empty
    end

  end

  context 'safe assignment is not allowed' do
    let(:cop_config) { { 'AllowSafeAssignment' => false } }

    it 'does not accepts = in condition surrounded with braces' do
      inspect_source(cop,
                     ['if (test = 10)',
                      'end'
                     ])
      expect(cop.offences.size).to eq(1)
    end
  end
end
