# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::MultilineHashKeyLineBreaks do
  subject(:cop) { described_class.new }

  context 'when on same line' do
    it 'does not add any offenses' do
      expect_no_offenses(<<~RUBY)
        {foo: 1, bar: "2"}
      RUBY
    end
  end

  context 'when on different lines than brackets but keys on one' do
    it 'does not add any offenses' do
      expect_no_offenses(<<~RUBY)
        {
          foo: 1, bar: "2"
        }
      RUBY
    end
  end

  context 'when on all keys on one line different than brackets' do
    it 'does not add any offenses' do
      expect_no_offenses(<<~RUBY)
        {
          foo => 1, bar => "2"
        }
      RUBY
    end
  end

  it 'registers an offense and corrects when key starts ' \
    'on same line as another' do
    expect_offense(<<~RUBY)
      {
        foo: 1,
        baz: 3, bar: "2"}
                ^^^^^^^^ Each key in a multi-line hash must start on a separate line.
    RUBY

    expect_correction(<<~RUBY)
      {
        foo: 1,
        baz: 3,\s
      bar: "2"}
    RUBY
  end

  context 'when key starts on same line as another with rockets' do
    it 'adds an offense' do
      expect_offense(<<~RUBY)
        {
          foo => 1,
          baz => 3, bar: "2"}
                    ^^^^^^^^ Each key in a multi-line hash must start on a separate line.
      RUBY

      expect_correction(<<~RUBY)
        {
          foo => 1,
          baz => 3,\s
        bar: "2"}
      RUBY
    end
  end

  it 'registers an offense and corrects when key starts ' \
    'on same line as another' do
    expect_offense(<<~RUBY)
      {foo: 1,
        baz: 3, bar: "2"}
                ^^^^^^^^ Each key in a multi-line hash must start on a separate line.
    RUBY

    expect_correction(<<~RUBY)
      {foo: 1,
        baz: 3,\s
      bar: "2"}
    RUBY
  end

  it 'registers an offense and corrects nested hashes' do
    expect_offense(<<~RUBY)
      {foo: 1,
        baz: {
          as: 12,
        }, bar: "2"}
           ^^^^^^^^ Each key in a multi-line hash must start on a separate line.
    RUBY

    expect_correction(<<~RUBY)
      {foo: 1,
        baz: {
          as: 12,
        },\s
      bar: "2"}
    RUBY
  end
end
