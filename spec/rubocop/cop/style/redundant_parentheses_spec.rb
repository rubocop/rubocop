# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::RedundantParentheses do
  subject(:cop) { described_class.new }

  shared_examples 'redundant' do |expr, correct, type, highlight = nil|
    it "registers an offense for parentheses around #{type}" do
      inspect_source(cop, expr)
      expect(cop.messages)
        .to eq(["Don't use parentheses around #{type}."])
      expect(cop.highlights).to eq([highlight || expr])
    end

    it 'auto-corrects' do
      expect(autocorrect_source(cop, expr)).to eq correct
    end
  end

  it_behaves_like 'redundant', '("x")', '"x"', 'a literal'
  it_behaves_like 'redundant', '("#{x}")', '"#{x}"', 'a literal'
  it_behaves_like 'redundant', '(:x)', ':x', 'a literal'
  it_behaves_like 'redundant', '(:"#{x}")', ':"#{x}"', 'a literal'
  it_behaves_like 'redundant', '(1)', '1', 'a literal'
  it_behaves_like 'redundant', '(1.2)', '1.2', 'a literal'
  it_behaves_like 'redundant', '({})', '{}', 'a literal'
  it_behaves_like 'redundant', '([])', '[]', 'a literal'
  it_behaves_like 'redundant', '(nil)', 'nil', 'a literal'
  it_behaves_like 'redundant', '(true)', 'true', 'a literal'
  it_behaves_like 'redundant', '(false)', 'false', 'a literal'
  it_behaves_like 'redundant', '(/regexp/)', '/regexp/', 'a literal'
  if RUBY_VERSION >= '2.1'
    it_behaves_like 'redundant', '(1i)', '1i', 'a literal'
    it_behaves_like 'redundant', '(1r)', '1r', 'a literal'
  end

  it_behaves_like 'redundant', 'x = 1; (x)', 'x = 1; x', 'a variable', '(x)'
  it_behaves_like 'redundant', '(@x)', '@x', 'a variable'
  it_behaves_like 'redundant', '(@@x)', '@@x', 'a variable'
  it_behaves_like 'redundant', '($x)', '$x', 'a variable'

  it_behaves_like 'redundant', '(X)', 'X', 'a constant'

  it_behaves_like 'redundant', '(x)', 'x', 'a method call'
  it_behaves_like 'redundant', '(x(1, 2))', 'x(1, 2)', 'a method call'
  it_behaves_like 'redundant', '("x".to_sym)', '"x".to_sym', 'a method call'
  it_behaves_like 'redundant', '(x[:y])', 'x[:y]', 'a method call'

  it 'accepts parentheses around a method call with unparenthesized ' \
     'arguments' do
    inspect_source(cop, '(a 1, 2) && (1 + 1)')
    expect(cop.offenses).to be_empty
  end

  it 'accepts parentheses inside an irange' do
    inspect_source(cop, '(a)..(b)')
    expect(cop.offenses).to be_empty
  end

  it 'accepts parentheses inside an erange' do
    inspect_source(cop, '(a)...(b)')
    expect(cop.offenses).to be_empty
  end

  it 'accepts parentheses around an irange' do
    inspect_source(cop, '(a..b)')
    expect(cop.offenses).to be_empty
  end

  it 'accepts parentheses around an erange' do
    inspect_source(cop, '(a...b)')
    expect(cop.offenses).to be_empty
  end
end
