# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::BigDecimalNew do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it 'registers an offense when using `BigDecimal.new()`' do
    expect_offense(<<-RUBY.strip_indent)
      BigDecimal.new(123.456, 3)
                 ^^^ `BigDecimal.new()` is deprecated. Use `BigDecimal()` instead.
    RUBY
  end

  it 'registers an offense when using `::BigDecimal.new()`' do
    expect_offense(<<-RUBY.strip_indent)
      ::BigDecimal.new(123.456, 3)
                   ^^^ `::BigDecimal.new()` is deprecated. Use `::BigDecimal()` instead.
    RUBY
  end

  it 'does not register an offense when using `BigDecimal()`' do
    expect_no_offenses(<<-RUBY.strip_indent)
      BigDecimal(123.456, 3)
    RUBY
  end

  it 'autocorrects `BigDecimal()`' do
    new_source = autocorrect_source('BigDecimal.new(123.456, 3)')

    expect(new_source).to eq 'BigDecimal(123.456, 3)'
  end
end
