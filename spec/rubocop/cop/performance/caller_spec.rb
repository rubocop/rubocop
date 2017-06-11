# frozen_string_literal: true

describe RuboCop::Cop::Performance::Caller do
  subject(:cop) { described_class.new }

  it "doesn't register an offense when caller is called" do
    expect_no_offenses('caller')
  end

  it "doesn't register an offense when caller with arguments is called" do
    expect_no_offenses('caller(1, 1).first')
  end

  it 'registers an offense when :first is called on caller' do
    expect(caller.first).to eq(caller(1..1).first)
    expect_offense(<<-RUBY.strip_indent)
      caller.first
      ^^^^^^^^^^^^ Use `caller(1..1).first` instead of `caller.first`.
    RUBY
  end

  it 'registers an offense when :first is called on caller with 1' do
    expect(caller(1).first).to eq(caller(1..1).first)
    expect_offense(<<-RUBY.strip_indent)
      caller(1).first
      ^^^^^^^^^^^^^^^ Use `caller(1..1).first` instead of `caller.first`.
    RUBY
  end

  it 'registers an offense when :first is called on caller with 2' do
    expect(caller(2).first).to eq(caller(2..2).first)
    expect_offense(<<-RUBY.strip_indent)
      caller(2).first
      ^^^^^^^^^^^^^^^ Use `caller(2..2).first` instead of `caller.first`.
    RUBY
  end

  it 'registers an offense when :[] is called on caller' do
    expect(caller[1]).to eq(caller(2..2).first)
    expect_offense(<<-RUBY.strip_indent)
      caller[1]
      ^^^^^^^^^ Use `caller(2..2).first` instead of `caller[1]`.
    RUBY
  end

  it 'registers an offense when :[] is called on caller with 1' do
    expect(caller(1)[1]).to eq(caller(2..2).first)
    expect_offense(<<-RUBY.strip_indent)
      caller(1)[1]
      ^^^^^^^^^^^^ Use `caller(2..2).first` instead of `caller[1]`.
    RUBY
  end

  it 'registers an offense when :[] is called on caller with 2' do
    expect(caller(2)[1]).to eq(caller(3..3).first)
    expect_offense(<<-RUBY.strip_indent)
      caller(2)[1]
      ^^^^^^^^^^^^ Use `caller(3..3).first` instead of `caller[1]`.
    RUBY
  end
end
