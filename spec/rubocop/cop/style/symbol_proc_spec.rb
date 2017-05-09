# frozen_string_literal: true

describe RuboCop::Cop::Style::SymbolProc, :config do
  subject(:cop) { described_class.new(config) }

  let(:cop_config) { { 'IgnoredMethods' => %w[respond_to] } }

  it 'registers an offense for a block with parameterless method call on ' \
     'param' do
    inspect_source(cop, 'coll.map { |e| e.upcase }')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages)
      .to eq(['Pass `&:upcase` as an argument to `map` instead of a block.'])
    expect(cop.highlights).to eq(['{ |e| e.upcase }'])
  end

  it 'registers an offense for a block when method in body is unary -/=' do
    expect_offense(<<-RUBY.strip_indent)
      something.map { |x| -x }
                    ^^^^^^^^^^ Pass `&:-@` as an argument to `map` instead of a block.
    RUBY
  end

  it 'accepts block with more than 1 arguments' do
    expect_no_offenses('something { |x, y| x.method }')
  end

  it 'accepts lambda with 1 argument' do
    expect_no_offenses('->(x) { x.method }')
  end

  it 'accepts proc with 1 argument' do
    expect_no_offenses('proc { |x| x.method }')
  end

  it 'accepts Proc.new with 1 argument' do
    expect_no_offenses('Proc.new { |x| x.method }')
  end

  it 'accepts ignored method' do
    expect_no_offenses('respond_to { |format| format.xml }')
  end

  it 'accepts block with no arguments' do
    expect_no_offenses('something { x.method }')
  end

  it 'accepts empty block body' do
    expect_no_offenses('something { |x| }')
  end

  it 'accepts block with more than 1 expression in body' do
    expect_no_offenses('something { |x| x.method; something_else }')
  end

  it 'accepts block when method in body is not called on block arg' do
    expect_no_offenses('something { |x| y.method }')
  end

  it 'accepts block with a block argument ' do
    expect_no_offenses('something { |&x| x.call }')
  end

  it 'accepts block with splat params' do
    expect_no_offenses('something { |*x| x.first }')
  end

  context 'when the method has arguments' do
    let(:source) { 'method(one, 2) { |x| x.test }' }

    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        method(one, 2) { |x| x.test }
                       ^^^^^^^^^^^^^^ Pass `&:test` as an argument to `method` instead of a block.
      RUBY
    end

    it 'auto-corrects' do
      corrected = autocorrect_source(cop, source)
      expect(corrected).to eq 'method(one, 2, &:test)'
    end
  end

  it 'autocorrects alias with symbols as proc' do
    corrected = autocorrect_source(cop, ['coll.map { |s| s.upcase }'])
    expect(corrected).to eq 'coll.map(&:upcase)'
  end

  it 'autocorrects multiple aliases with symbols as proc' do
    corrected = autocorrect_source(cop, ['coll.map { |s| s.upcase }' \
                                         '.map { |s| s.downcase }'])
    expect(corrected).to eq 'coll.map(&:upcase).map(&:downcase)'
  end

  it 'auto-corrects correctly when there are no arguments in parentheses' do
    corrected = autocorrect_source(cop, ['coll.map(   ) { |s| s.upcase }'])
    expect(corrected).to eq 'coll.map(&:upcase)'
  end

  it 'does not crash with a bare method call' do
    run = -> { inspect_source(cop, 'coll.map { |s| bare_method }') }
    expect(&run).not_to raise_error
  end

  context 'when `super` has arguments' do
    let(:source) { 'super(one, two) { |x| x.test }' }

    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        super(one, two) { |x| x.test }
                        ^^^^^^^^^^^^^^ Pass `&:test` as an argument to `super` instead of a block.
      RUBY
    end

    it 'auto-corrects' do
      corrected = autocorrect_source(cop, source)
      expect(corrected).to eq 'super(one, two, &:test)'
    end
  end

  context 'when `super` has no arguments' do
    let(:source) { 'super { |x| x.test }' }

    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        super { |x| x.test }
              ^^^^^^^^^^^^^^ Pass `&:test` as an argument to `super` instead of a block.
      RUBY
    end

    it 'auto-corrects' do
      corrected = autocorrect_source(cop, source)
      expect(corrected).to eq 'super(&:test)'
    end
  end

  it 'auto-corrects correctly when args have a trailing comma' do
    corrected = autocorrect_source(cop, <<-END.strip_indent)
      mail(
        to: 'foo',
        subject: 'bar',
      ) { |format| format.text }
    END
    expect(corrected).to eq(<<-END.strip_indent)
      mail(
        to: 'foo',
        subject: 'bar', &:text
      )
    END
  end
end
