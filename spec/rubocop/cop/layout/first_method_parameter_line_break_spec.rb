# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::FirstMethodParameterLineBreak do
  subject(:cop) { described_class.new }

  context 'params listed on the first line' do
    let(:source) do
      <<-RUBY.strip_indent
        def foo(bar,
          baz)
          do_something
        end
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
        'def foo(',
        'bar,',
        '  baz)',
        '  do_something',
        'end',
        ''
      ].join("\n"))
    end
  end

  context 'params on first line of singleton method' do
    let(:source) do
      <<-RUBY.strip_indent
        def self.foo(bar,
          baz)
          do_something
        end
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
        'def self.foo(',
        'bar,',
        '  baz)',
        '  do_something',
        'end',
        ''
      ].join("\n"))
    end
  end

  it 'ignores params listed on a single line' do
    expect_no_offenses(<<-RUBY.strip_indent)
        def foo(bar, baz, bing)
          do_something
        end
      RUBY
  end

  it 'ignores params without parens' do
    expect_no_offenses(<<-RUBY.strip_indent)
        def foo bar,
          baz
          do_something
        end
      RUBY
  end

  it 'ignores single-line methods' do
    expect_no_offenses('def foo(bar, baz) ; bing ; end')
  end

  it 'ignores methods without params' do
    expect_no_offenses(<<-RUBY.strip_indent)
        def foo
          bing
        end
      RUBY
  end

  context 'params with default values' do
    let(:source) do
      <<-RUBY.strip_indent
        def foo(bar = [],
          baz = 2)
          do_something
        end
      RUBY
    end

    it 'detects the offense' do
      inspect_source(source)

      expect(cop.offenses.length).to eq(1)
      expect(cop.offenses.first.line).to eq(1)
      expect(cop.highlights).to eq(['bar = []'])
    end

    it 'autocorrects the offense' do
      new_source = autocorrect_source(source)

      expect(new_source).to eq([
        'def foo(',
        'bar = [],',
        '  baz = 2)',
        '  do_something',
        'end',
        ''
      ].join("\n"))
    end
  end
end
