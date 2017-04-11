# frozen_string_literal: true

describe RuboCop::Cop::Performance::Caller do
  subject(:cop) { described_class.new }

  it "doesn't register an offense when caller is called" do
    inspect_source(cop, 'caller')
    expect(cop.messages).to be_empty
  end

  it "doesn't register an offense when caller with arguments is called" do
    inspect_source(cop, 'caller(1..1).first')
    inspect_source(cop, 'caller(1, 1).first')
    expect(cop.messages).to be_empty
  end

  it 'registers an offense when :first is called on caller' do
    inspect_source(cop, 'caller.first')
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense when :first is called on caller with 1' do
    inspect_source(cop, 'caller(1).first')
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense when :first is called on caller with 2' do
    inspect_source(cop, 'caller(2).first')
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense when :[] is called on caller' do
    inspect_source(cop, 'caller[1]')
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense when :[] is called on caller with 1' do
    inspect_source(cop, 'caller(1)[1]')
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense when :[] is called on caller with 2' do
    inspect_source(cop, 'caller(2)[1]')
    expect(cop.offenses.size).to eq(1)
  end
end
