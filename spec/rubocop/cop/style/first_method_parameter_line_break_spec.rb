# frozen_string_literal: true

describe RuboCop::Cop::Style::FirstMethodParameterLineBreak do
  subject(:cop) { described_class.new }

  context 'params listed on the first line' do
    let(:source) do
      <<-END.strip_indent
        def foo(bar,
          baz)
          do_something
        end
      END
    end

    it 'detects the offense' do
      inspect_source(cop, source)

      expect(cop.offenses.length).to eq(1)
      expect(cop.offenses.first.line).to eq(1)
      expect(cop.highlights).to eq(['bar'])
    end

    it 'autocorrects the offense' do
      new_source = autocorrect_source(cop, source)

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
      <<-END.strip_indent
        def self.foo(bar,
          baz)
          do_something
        end
      END
    end

    it 'detects the offense' do
      inspect_source(cop, source)

      expect(cop.offenses.length).to eq(1)
      expect(cop.offenses.first.line).to eq(1)
      expect(cop.highlights).to eq(['bar'])
    end

    it 'autocorrects the offense' do
      new_source = autocorrect_source(cop, source)

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
    inspect_source(
      cop,
      <<-END.strip_indent
        def foo(bar, baz, bing)
          do_something
        end
      END
    )

    expect(cop.offenses).to be_empty
  end

  it 'ignores params without parens' do
    inspect_source(
      cop,
      <<-END.strip_indent
        def foo bar,
          baz
          do_something
        end
      END
    )

    expect(cop.offenses).to be_empty
  end

  it 'ignores single-line methods' do
    inspect_source(
      cop,
      'def foo(bar, baz) ; bing ; end'
    )

    expect(cop.offenses).to be_empty
  end

  it 'ignores methods without params' do
    inspect_source(
      cop,
      <<-END.strip_indent
        def foo
          bing
        end
      END
    )

    expect(cop.offenses).to be_empty
  end

  context 'params with default values' do
    let(:source) do
      <<-END.strip_indent
        def foo(bar = [],
          baz = 2)
          do_something
        end
      END
    end

    it 'detects the offense' do
      inspect_source(cop, source)

      expect(cop.offenses.length).to eq(1)
      expect(cop.offenses.first.line).to eq(1)
      expect(cop.highlights).to eq(['bar = []'])
    end

    it 'autocorrects the offense' do
      new_source = autocorrect_source(cop, source)

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
