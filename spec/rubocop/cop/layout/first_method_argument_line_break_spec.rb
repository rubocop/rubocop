# frozen_string_literal: true

describe RuboCop::Cop::Layout::FirstMethodArgumentLineBreak do
  subject(:cop) { described_class.new }

  context 'args listed on the first line' do
    let(:source) do
      <<-RUBY.strip_indent
        foo(bar,
          baz)
      RUBY
    end

    it 'detects the offense' do
      inspect_source(source)

      expect(cop.offenses.length).to eq(1)
      expect(cop.offenses.first.line).to eq(1)
      expect(cop.highlights).to eq(['bar'])
    end

    it 'autocorrects the offense' do
      new_source = autocorrect_source(source)

      expect(new_source).to eq([
        'foo(',
        'bar,',
        '  baz)',
        ''
      ].join("\n"))
    end
  end

  context 'hash arg spanning multiple lines' do
    let(:source) do
      <<-RUBY.strip_indent
        something(3, bar: 1,
        baz: 2)
      RUBY
    end

    it 'detects the offense' do
      inspect_source(source)

      expect(cop.offenses.length).to eq(1)
      expect(cop.offenses.first.line).to eq(1)
      expect(cop.highlights).to eq(['3'])
    end

    it 'autocorrects the offense' do
      new_source = autocorrect_source(source)

      expect(new_source).to eq([
        'something(',
        '3, bar: 1,',
        'baz: 2)',
        ''
      ].join("\n"))
    end
  end

  context 'hash arg without a line break before the first pair' do
    let(:source) do
      <<-RUBY.strip_indent
        something(bar: 1,
        baz: 2)
      RUBY
    end

    it 'detects the offense' do
      inspect_source(source)

      expect(cop.offenses.length).to eq(1)
      expect(cop.offenses.first.line).to eq(1)
      expect(cop.highlights).to eq(['bar: 1'])
    end

    it 'autocorrects the offense' do
      new_source = autocorrect_source(source)

      expect(new_source).to eq([
        'something(',
        'bar: 1,',
        'baz: 2)',
        ''
      ].join("\n"))
    end
  end

  it 'ignores arguments listed on a single line' do
    expect_no_offenses('foo(bar, baz, bing)')
  end

  it 'ignores arguments without parens' do
    expect_no_offenses(<<-RUBY.strip_indent)
      foo bar,
        baz
    RUBY
  end

  it 'ignores methods without arguments' do
    expect_no_offenses('foo')
  end
end
