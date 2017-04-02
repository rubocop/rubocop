# frozen_string_literal: true

describe RuboCop::Cop::Lint::Void do
  subject(:cop) { described_class.new }

  described_class::OPS.each do |op|
    it "registers an offense for void op #{op} if not on last line" do
      inspect_source(cop,
                     ["a #{op} b",
                      "a #{op} b",
                      "a #{op} b"])
      expect(cop.offenses.size).to eq(2)
    end
  end

  described_class::OPS.each do |op|
    it "accepts void op #{op} if on last line" do
      inspect_source(cop,
                     ['something',
                      "a #{op} b"])
      expect(cop.offenses).to be_empty
    end
  end

  described_class::OPS.each do |op|
    it "accepts void op #{op} by itself without a begin block" do
      inspect_source(cop, "a #{op} b")
      expect(cop.offenses).to be_empty
    end
  end

  %w[var @var @@var VAR].each do |var|
    it "registers an offense for void var #{var} if not on last line" do
      inspect_source(cop,
                     ["#{var} = 5",
                      var,
                      'top'])
      expect(cop.offenses.size).to eq(1)
    end
  end

  %w(1 2.0 :test /test/ [1] {}).each do |lit|
    it "registers an offense for void lit #{lit} if not on last line" do
      inspect_source(cop,
                     [lit,
                      'top'])
      expect(cop.offenses.size).to eq(1)
    end
  end

  it 'registers an offense for void `self` if not on last line' do
    inspect_source(cop, 'self; top')
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for void `defined?` if not on last line' do
    inspect_source(cop,
                   ['defined?(x)',
                    'top'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'handles explicit begin blocks' do
    inspect_source(cop,
                   ['begin',
                    ' 1',
                    ' 2',
                    'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts short call syntax' do
    inspect_source(cop,
                   ['lambda.(a)',
                    'top'])
    expect(cop.offenses).to be_empty
  end

  it 'accepts backtick commands' do
    inspect_source(cop,
                   ['`touch x`',
                    'nil'])
    expect(cop.offenses).to be_empty
  end

  it 'accepts percent-x commands' do
    inspect_source(cop,
                   ['%x(touch x)',
                    'nil'])
    expect(cop.offenses).to be_empty
  end
end
