# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RandomWithOffset do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it 'registers an offense when using rand(int) + offset' do
    expect_offense(<<-RUBY.strip_indent)
      rand(6) + 1
      ^^^^^^^^^^^ Prefer ranges when generating random numbers instead of integers with offsets.
    RUBY
  end

  it 'registers an offense when using offset + rand(int)' do
    expect_offense(<<-RUBY.strip_indent)
      1 + rand(6)
      ^^^^^^^^^^^ Prefer ranges when generating random numbers instead of integers with offsets.
    RUBY
  end

  it 'registers an offense when using rand(int).succ' do
    expect_offense(<<-RUBY.strip_indent)
      rand(6).succ
      ^^^^^^^^^^^^ Prefer ranges when generating random numbers instead of integers with offsets.
    RUBY
  end

  it 'registers an offense when using rand(int) - offset' do
    expect_offense(<<-RUBY.strip_indent)
      rand(6) - 1
      ^^^^^^^^^^^ Prefer ranges when generating random numbers instead of integers with offsets.
    RUBY
  end

  it 'registers an offense when using offset - rand(int)' do
    expect_offense(<<-RUBY.strip_indent)
      1 - rand(6)
      ^^^^^^^^^^^ Prefer ranges when generating random numbers instead of integers with offsets.
    RUBY
  end

  it 'registers an offense when using rand(int).pred' do
    expect_offense(<<-RUBY.strip_indent)
      rand(6).pred
      ^^^^^^^^^^^^ Prefer ranges when generating random numbers instead of integers with offsets.
    RUBY
  end

  it 'registers an offense when using rand(int).next' do
    expect_offense(<<-RUBY.strip_indent)
      rand(6).next
      ^^^^^^^^^^^^ Prefer ranges when generating random numbers instead of integers with offsets.
    RUBY
  end

  it 'registers an offense when using Kernel.rand' do
    expect_offense(<<-RUBY.strip_indent)
      Kernel.rand(6) + 1
      ^^^^^^^^^^^^^^^^^^ Prefer ranges when generating random numbers instead of integers with offsets.
    RUBY
  end

  it 'registers an offense when using Random.rand' do
    expect_offense(<<-RUBY.strip_indent)
      Random.rand(6) + 1
      ^^^^^^^^^^^^^^^^^^ Prefer ranges when generating random numbers instead of integers with offsets.
    RUBY
  end

  it 'registers an offense when using rand(irange) + offset' do
    expect_offense(<<-RUBY.strip_indent)
      rand(0..6) + 1
      ^^^^^^^^^^^^^^ Prefer ranges when generating random numbers instead of integers with offsets.
    RUBY
  end

  it 'registers an offense when using rand(erange) + offset' do
    expect_offense(<<-RUBY.strip_indent)
      rand(0...6) + 1
      ^^^^^^^^^^^^^^^ Prefer ranges when generating random numbers instead of integers with offsets.
    RUBY
  end

  it 'autocorrects rand(int) + offset' do
    new_source = autocorrect_source('rand(6) + 1')
    expect(new_source).to eq 'rand(1..6)'
  end

  it 'autocorrects offset + rand(int)' do
    new_source = autocorrect_source('1 + rand(6)')
    expect(new_source).to eq 'rand(1..6)'
  end

  it 'autocorrects rand(int) - offset' do
    new_source = autocorrect_source('rand(6) - 1')
    expect(new_source).to eq 'rand(-1..4)'
  end

  it 'autocorrects offset - rand(int)' do
    new_source = autocorrect_source('1 - rand(6)')
    expect(new_source).to eq 'rand(-4..1)'
  end

  it 'autocorrects rand(int).succ' do
    new_source = autocorrect_source('rand(6).succ')
    expect(new_source).to eq 'rand(1..6)'
  end

  it 'autocorrects rand(int).pred' do
    new_source = autocorrect_source('rand(6).pred')
    expect(new_source).to eq 'rand(-1..4)'
  end

  it 'autocorrects rand(int).next' do
    new_source = autocorrect_source('rand(6).next')
    expect(new_source).to eq 'rand(1..6)'
  end

  it 'autocorrects the use of Random.rand' do
    new_source = autocorrect_source('Random.rand(6) + 1')
    expect(new_source).to eq 'Random.rand(1..6)'
  end

  it 'autocorrects the use of Kernel.rand' do
    new_source = autocorrect_source('Kernel.rand(6) + 1')
    expect(new_source).to eq 'Kernel.rand(1..6)'
  end

  it 'autocorrects rand(irange) + offset' do
    new_source = autocorrect_source('rand(0..6) + 1')
    expect(new_source).to eq 'rand(1..7)'
  end

  it 'autocorrects rand(3range) + offset' do
    new_source = autocorrect_source('rand(0...6) + 1')
    expect(new_source).to eq 'rand(1..6)'
  end

  it 'autocorrects rand(irange) - offset' do
    new_source = autocorrect_source('rand(0..6) - 1')
    expect(new_source).to eq 'rand(-1..5)'
  end

  it 'autocorrects rand(erange) - offset' do
    new_source = autocorrect_source('rand(0...6) - 1')
    expect(new_source).to eq 'rand(-1..4)'
  end

  it 'autocorrects offset - rand(irange)' do
    new_source = autocorrect_source('1 - rand(0..6)')
    expect(new_source).to eq 'rand(-5..1)'
  end

  it 'autocorrects offset - rand(erange)' do
    new_source = autocorrect_source('1 - rand(0...6)')
    expect(new_source).to eq 'rand(-4..1)'
  end

  it 'autocorrects rand(irange).succ' do
    new_source = autocorrect_source('rand(0..6).succ')
    expect(new_source).to eq 'rand(1..7)'
  end

  it 'autocorrects rand(erange).succ' do
    new_source = autocorrect_source('rand(0...6).succ')
    expect(new_source).to eq 'rand(1..6)'
  end

  it 'does not register an offense when using range with double dots' do
    expect_no_offenses('rand(1..6)')
  end

  it 'does not register an offense when using range with triple dots' do
    expect_no_offenses('rand(1...6)')
  end
end
