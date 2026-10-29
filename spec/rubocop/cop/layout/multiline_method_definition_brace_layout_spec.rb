# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::MultilineMethodDefinitionBraceLayout, :config do
  let(:cop_config) { { 'EnforcedStyle' => 'symmetrical' } }

  it 'ignores implicit defs' do
    expect_no_offenses(<<~RUBY)
      def foo a: 1,
      b: 2
      end
    RUBY
  end

  it 'ignores single-line defs' do
    expect_no_offenses(<<~RUBY)
      def foo(a,b)
      end
    RUBY
  end

  it 'ignores defs without params' do
    expect_no_offenses(<<~RUBY)
      def foo
      end
    RUBY
  end

  it_behaves_like 'multiline literal brace layout' do
    let(:prefix) { 'def foo' }
    let(:suffix) { 'end' }
    let(:open) { '(' }
    let(:close) { ')' }
    let(:multi_prefix) { 'b: ' }
    let(:after_heredoc) { 'c: 1' }
  end

  context 'when EnforcedStyle is same_line' do
    let(:cop_config) { { 'EnforcedStyle' => 'same_line' } }

    it 'registers an offense and corrects a closing brace followed by an endless method body after a comment line', :ruby30 do
      expect_offense(<<~RUBY)
        def foo(
          bar
          # comment
        ) = bar
        ^ Closing method definition brace must be on the same line as the last parameter.
      RUBY

      expect_correction(<<~RUBY)
        def foo(
          bar) = bar
          # comment
      RUBY
    end
  end
end
