# frozen_string_literal: true

describe RuboCop::Cop::Style::FormatString, :config do
  subject(:cop) { described_class.new(config) }

  context 'when enforced style is sprintf' do
    let(:cop_config) { { 'EnforcedStyle' => 'sprintf' } }
    it 'registers an offense for a string followed by something' do
      inspect_source(cop,
                     'puts "%d" % 10')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Favor `sprintf` over `String#%`.'])
    end

    it 'registers an offense for something followed by an array' do
      inspect_source(cop,
                     'puts x % [10, 11]')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Favor `sprintf` over `String#%`.'])
    end

    it 'does not register an offense for numbers' do
      expect_no_offenses('puts 10 % 4')
    end

    it 'does not register an offense for ambiguous cases' do
      inspect_source(cop,
                     'puts x % 4')
      expect(cop.offenses).to be_empty

      inspect_source(cop,
                     'puts x % Y')
      expect(cop.offenses).to be_empty
    end

    it 'works if the first operand contains embedded expressions' do
      inspect_source(cop,
                     'puts "#{x * 5} %d #{@test}" % 10')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Favor `sprintf` over `String#%`.'])
    end

    it 'registers an offense for format' do
      inspect_source(cop,
                     'format(something, a, b)')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Favor `sprintf` over `format`.'])
    end

    it 'registers an offense for format with 2 arguments' do
      inspect_source(cop,
                     'format("%X", 123)')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Favor `sprintf` over `format`.'])
    end
  end

  context 'when enforced style is format' do
    let(:cop_config) { { 'EnforcedStyle' => 'format' } }

    it 'registers an offense for a string followed by something' do
      inspect_source(cop,
                     'puts "%d" % 10')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Favor `format` over `String#%`.'])
    end

    it 'registers an offense for something followed by an array' do
      inspect_source(cop,
                     'puts x % [10, 11]')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Favor `format` over `String#%`.'])
    end

    it 'registers an offense for something followed by a hash' do
      inspect_source(cop,
                     'puts x % { a: 10, b: 11 }')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Favor `format` over `String#%`.'])
    end

    it 'does not register an offense for numbers' do
      expect_no_offenses('puts 10 % 4')
    end

    it 'does not register an offense for ambiguous cases' do
      inspect_source(cop,
                     'puts x % 4')
      expect(cop.offenses).to be_empty

      inspect_source(cop,
                     'puts x % Y')
      expect(cop.offenses).to be_empty
    end

    it 'works if the first operand contains embedded expressions' do
      inspect_source(cop,
                     'puts "#{x * 5} %d #{@test}" % 10')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Favor `format` over `String#%`.'])
    end

    it 'registers an offense for sprintf' do
      inspect_source(cop,
                     'sprintf(something, a, b)')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Favor `format` over `sprintf`.'])
    end

    it 'registers an offense for sprintf with 2 arguments' do
      inspect_source(cop,
                     "sprintf('%020d', 123)")
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Favor `format` over `sprintf`.'])
    end
  end

  context 'when enforced style is percent' do
    let(:cop_config) { { 'EnforcedStyle' => 'percent' } }

    it 'registers an offense for format' do
      inspect_source(cop,
                     'format(something, a, b)')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Favor `String#%` over `format`.'])
    end

    it 'registers an offense for sprintf' do
      inspect_source(cop,
                     'sprintf(something, a, b)')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Favor `String#%` over `sprintf`.'])
    end

    it 'registers an offense for sprintf with 3 arguments' do
      inspect_source(cop,
                     'format("%d %04x", 123, 123)')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Favor `String#%` over `format`.'])
    end

    it 'accepts format with 1 argument' do
      expect_no_offenses('format :xml')
    end

    it 'accepts sprintf with 1 argument' do
      expect_no_offenses('sprintf :xml')
    end

    it 'accepts format without arguments' do
      expect_no_offenses('format')
    end

    it 'accepts sprintf without arguments' do
      expect_no_offenses('sprintf')
    end

    it 'accepts String#%' do
      expect_no_offenses('puts "%d" % 10')
    end
  end
end
