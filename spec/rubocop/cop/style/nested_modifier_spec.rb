# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::NestedModifier do
  subject(:cop) { described_class.new }

  shared_examples 'avoidable' do |keyword|
    it "registers an offense for modifier #{keyword}" do
      inspect_source("something #{keyword} a if b")
      expect(cop.messages).to eq(['Avoid using nested modifiers.'])
      expect(cop.highlights).to eq([keyword])
    end
  end

  shared_examples 'not correctable' do |keyword|
    it "does not auto-correct when #{keyword} is the outer modifier" do
      source = "something if a #{keyword} b"
      corrected = autocorrect_source(source)
      expect(corrected).to eq source
      expect(cop.offenses.map(&:corrected?)).to eq [false]
    end

    it "does not auto-correct when #{keyword} is the inner modifier" do
      source = "something #{keyword} a if b"
      corrected = autocorrect_source(source)
      expect(corrected).to eq source
      expect(cop.offenses.map(&:corrected?)).to eq [false]
    end
  end

  context 'if' do
    it_behaves_like 'avoidable', 'if'
  end

  context 'unless' do
    it_behaves_like 'avoidable', 'unless'
  end

  it 'auto-corrects if + if' do
    corrected = autocorrect_source('something if a if b')
    expect(corrected).to eq 'something if b && a'
  end

  it 'auto-corrects unless + unless' do
    corrected = autocorrect_source('something unless a unless b')
    expect(corrected).to eq 'something unless b || a'
  end

  it 'auto-corrects if + unless' do
    corrected = autocorrect_source('something if a unless b')
    expect(corrected).to eq 'something unless b || !a'
  end

  it 'auto-corrects unless with a comparison operator + if' do
    corrected = autocorrect_source('something unless b > 1 if true')
    expect(corrected).to eq 'something if true && !(b > 1)'
  end

  it 'auto-corrects unless + if' do
    corrected = autocorrect_source('something unless a if b')
    expect(corrected).to eq 'something if b && !a'
  end

  it 'adds parentheses when needed in auto-correction' do
    corrected = autocorrect_source('something if a || b if c || d')
    expect(corrected).to eq 'something if (c || d) && (a || b)'
  end

  it 'does not add redundant parentheses in auto-correction' do
    corrected = autocorrect_source('something if a unless c || d')
    expect(corrected).to eq 'something unless c || d || !a'
  end

  context 'while' do
    it_behaves_like 'avoidable', 'while'
    it_behaves_like 'not correctable', 'while'
  end

  context 'until' do
    it_behaves_like 'avoidable', 'until'
    it_behaves_like 'not correctable', 'until'
  end

  it 'registers one offense for more than two modifiers' do
    expect_offense(<<-RUBY.strip_indent)
      something until a while b unless c if d
                                ^^^^^^ Avoid using nested modifiers.
    RUBY
  end
end
