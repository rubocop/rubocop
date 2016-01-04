# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::Lambda, :config do
  subject(:cop) { described_class.new(config) }

  it 'registers an offense for an old single-line lambda call' do
    inspect_source(cop, 'f = lambda { |x| x }')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages)
      .to eq(['Use the new lambda literal syntax `->(params) {...}`.'])
  end

  it 'registers an offense for an old single-line no-argument lambda call' do
    inspect_source(cop, 'f = lambda { x }')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages)
      .to eq(['Use the new lambda literal syntax `-> {...}`.'])
  end

  it 'accepts the new lambda literal with single-line body' do
    inspect_source(cop, ['lambda = ->(x) { x }',
                         'lambda.(1)'])
    expect(cop.offenses).to be_empty
  end

  it 'registers an offense for a new multi-line lambda call' do
    inspect_source(cop, ['f = ->(x) do',
                         '  x',
                         'end'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages)
      .to eq(['Use the `lambda` method for multi-line lambdas.'])
  end

  it 'accepts the old lambda syntax with multi-line body' do
    inspect_source(cop, ['l = lambda do |x|',
                         '  x',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'accepts the lambda call outside of block' do
    inspect_source(cop, 'l = lambda.test')
    expect(cop.offenses).to be_empty
  end

  it 'auto-corrects an old single-line lambda call' do
    new_source = autocorrect_source(cop, 'f = lambda { |x| x }')
    expect(new_source).to eq('f = ->(x) { x }')
  end

  it 'auto-corrects an old single-line no-argument lambda call' do
    new_source = autocorrect_source(cop, 'f = lambda { x }')
    expect(new_source).to eq('f = -> { x }')
  end

  it 'auto-corrects a new multi-line lambda call' do
    new_source = autocorrect_source(cop, ['f = ->(x) do',
                                          '  x',
                                          'end'])
    expect(new_source).to eq(['f = lambda do |x|',
                              '  x',
                              'end'].join("\n"))
  end

  it 'auto-corrects a new multi-line no-argument lambda call' do
    new_source = autocorrect_source(cop, ['f = -> do',
                                          '  x',
                                          'end'])
    expect(new_source).to eq(['f = lambda do',
                              '  x',
                              'end'].join("\n"))
  end

  context 'unusual lack of spacing' do
    # The lack of spacing shown here is valid ruby syntax,
    # and can be the result of previous autocorrects re-writing
    # a multi-line `->(x){ ... }` to `->(x)do ... end`.
    # See rubocop/cop/style/block_delimiters.rb.
    # Tests correction of an issue resulting in `lambdado` syntax errors.
    it 'auto-corrects a multi-line lambda' do
      new_source = autocorrect_source(cop, ['->(x)do',
                                            '  x',
                                            'end'])
      expect(new_source).to eq(['lambda do |x|',
                                '  x',
                                'end'].join("\n"))
    end

    it 'auto-corrects a multi-line lambda with no spacing after args' do
      new_source = autocorrect_source(cop, ['-> (x)do',
                                            '  x',
                                            'end'])
      expect(new_source).to eq(['lambda do |x|',
                                '  x',
                                'end'].join("\n"))
    end

    it 'auto-corrects a multi-line lambda with no spacing before args' do
      new_source = autocorrect_source(cop, ['->(x) do',
                                            '  x',
                                            'end'])
      expect(new_source).to eq(['lambda do |x|',
                                '  x',
                                'end'].join("\n"))
    end

    it 'auto-corrects a multi-line lambda with empty args' do
      new_source = autocorrect_source(cop, ['->()do',
                                            '  x',
                                            'end'])
      expect(new_source).to eq(['lambda do',
                                '  x',
                                'end'].join("\n"))
    end

    it 'auto-corrects a multi-line lambda with empty args and bad spacing' do
      new_source = autocorrect_source(cop, ['-> ()do',
                                            '  x',
                                            'end'])
      expect(new_source).to eq(['lambda do',
                                '  x',
                                'end'].join("\n"))
    end

    it 'auto-corrects a new multi-line lambda with no args' do
      new_source = autocorrect_source(cop, ['->do',
                                            '  x',
                                            'end'])
      expect(new_source).to eq(['lambda do',
                                '  x',
                                'end'].join("\n"))
    end
  end

  context 'new multi-line lambda as an argument' do
    let(:source) do
      ['has_many :kittens, -> do',
       '  where(cats: Cat.young.where_values_hash)',
       'end, source: cats']
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq 1
    end

    it 'does not auto-correct' do
      expect(autocorrect_source(cop, source)).to eq(source.join("\n"))
      expect(cop.offenses.map(&:corrected?)).to eq [false]
    end
  end
end
