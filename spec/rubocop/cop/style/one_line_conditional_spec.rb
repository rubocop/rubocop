# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::OneLineConditional do
  subject(:cop) { described_class.new }

  shared_examples 'offense' do |condition|
    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.messages)
        .to eq(['Favor the ternary operator (`?:`)' \
                " over `#{condition}/then/else/end` constructs."])
    end
  end

  shared_examples 'no offense' do
    it 'does not register an offense' do
      inspect_source(cop, source)
      expect(cop.messages).to be_empty
    end
  end

  shared_examples 'autocorrect' do |correct_code|
    it 'auto-corrects' do
      corrected = autocorrect_source(cop, source)
      expect(corrected).to eq(correct_code)
    end
  end

  context 'one line if/then/else/end' do
    let(:source) { 'if cond then run else dont end' }

    include_examples 'offense', 'if'
    include_examples 'autocorrect', 'cond ? run : dont'

    context 'empty else' do
      let(:source) { 'if cond then run else end' }

      include_examples 'no offense'
    end
  end

  context 'one line if/then/end' do
    let(:source) { 'if cond then run end' }

    include_examples 'no offense'
  end

  context 'one line unless/then/else/end' do
    let(:source) { 'unless cond then run else dont end' }

    include_examples 'offense', 'unless'
    include_examples 'autocorrect', 'cond ? dont : run'

    context 'empty else' do
      let(:source) { 'unless cond then run else end' }

      include_examples 'no offense'
    end
  end

  context 'one line unless/then/end' do
    let(:source) { 'unless cond then run end' }

    include_examples 'no offense'
  end

  %w(| ^ & <=> == === =~ > >= < <= << >> + - * / % ** ~ ! != !~
     && ||).each do |operator|
    it 'parenthesizes the expression if it is preceded by an operator' do
      corrected =
        autocorrect_source(cop, "a #{operator} if cond then run else dont end")
      expect(corrected).to eq("a #{operator} (cond ? run : dont)")
    end
  end

  shared_examples 'changed precedence' do |expr|
    it "adds parentheses around `#{expr}`" do
      corrected = autocorrect_source(cop,
                                     "if #{expr} then #{expr} else #{expr} end")
      expect(corrected).to eq("(#{expr}) ? (#{expr}) : (#{expr})")
    end
  end

  it_behaves_like 'changed precedence', 'puts 1'
  it_behaves_like 'changed precedence', 'defined? :A'
  it_behaves_like 'changed precedence', 'yield a'
  it_behaves_like 'changed precedence', 'super b'
  it_behaves_like 'changed precedence', 'not a'
  it_behaves_like 'changed precedence', 'a and b'
  it_behaves_like 'changed precedence', 'a or b'
  it_behaves_like 'changed precedence', 'a = b'
  it_behaves_like 'changed precedence', 'a ? b : c'

  it 'does not parenthesize expressions when they do not contain method ' \
     'calls with unparenthesized arguments' do
    corrected =
      autocorrect_source(cop, 'if a(0) then puts(1) else yield(2) end')
    expect(corrected).to eq('a(0) ? puts(1) : yield(2)')
  end

  it 'does not parenthesize expressions when they contain unparenthesized ' \
     'operator method calls' do
    corrected = autocorrect_source(cop, 'if 0 + 0 then 1 + 1 else 2 + 2 end')
    expect(corrected).to eq('0 + 0 ? 1 + 1 : 2 + 2')
  end
end
