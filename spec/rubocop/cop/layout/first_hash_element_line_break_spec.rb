# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::FirstHashElementLineBreak do
  subject(:cop) { described_class.new }

  context 'elements listed on the first line' do
    let(:source) do
      <<-RUBY.strip_indent
        a = { a: 1,
              b: 2}
      RUBY
    end

    it 'detects the offense' do
      inspect_source(source)

      expect(cop.offenses.length).to eq(1)
      expect(cop.offenses.first.line).to eq(1)
      expect(cop.highlights).to eq(['a: 1'])
    end

    it 'autocorrects the offense' do
      new_source = autocorrect_source(source)

      expect(new_source).to eq([
        'a = { ',
        'a: 1,',
        '      b: 2}',
        ''
      ].join("\n"))
    end
  end

  context 'hash nested in a method call' do
    let(:source) do
      <<-RUBY.strip_indent
        method({ foo: 1,
                 bar: 2 })
      RUBY
    end

    it 'detects the offense' do
      inspect_source(source)

      expect(cop.offenses.length).to eq(1)
      expect(cop.offenses.first.line).to eq(1)
      expect(cop.highlights).to eq(['foo: 1'])
    end

    it 'autocorrects the offense' do
      new_source = autocorrect_source(source)

      expect(new_source).to eq([
        'method({ ',
        'foo: 1,',
        '         bar: 2 })',
        ''
      ].join("\n"))
    end
  end

  it 'ignores implicit hashes in method calls with parens' do
    expect_no_offenses(<<-RUBY.strip_indent)
      method(
        foo: 1,
        bar: 2)
    RUBY
  end

  it 'ignores implicit hashes in method calls without parens' do
    expect_no_offenses(<<-RUBY.strip_indent)
      method foo: 1,
       bar:2
    RUBY
  end

  it 'ignores implicit hashes in method calls that are improperly formatted' do
    # These are covered by Style/FirstMethodArgumentLineBreak
    expect_no_offenses(<<-RUBY.strip_indent)
      method(foo: 1,
        bar: 2)
    RUBY
  end

  it 'ignores elements listed on a single line' do
    expect_no_offenses(<<-RUBY.strip_indent)
      b = {
        a: 1,
        b: 2}
    RUBY
  end
end
