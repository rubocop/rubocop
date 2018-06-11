# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::MethodDefParentheses, :config do
  subject(:cop) { described_class.new(config) }

  context 'require_parentheses' do
    let(:cop_config) { { 'EnforcedStyle' => 'require_parentheses' } }

    it 'reports an offense for def with parameters but no parens' do
      expect_offense(<<-RUBY.strip_indent)
        def func a, b
                 ^^^^ Use def with parentheses when there are parameters.
        end
      RUBY
    end

    it 'reports an offense for correct + opposite' do
      expect_offense(<<-RUBY.strip_indent)
        def func(a, b)
        end
        def func a, b
                 ^^^^ Use def with parentheses when there are parameters.
        end
      RUBY
    end

    it 'reports an offense for class def with parameters but no parens' do
      expect_offense(<<-RUBY.strip_indent)
        def Test.func a, b
                      ^^^^ Use def with parentheses when there are parameters.
        end
      RUBY
    end

    it 'accepts def with no args and no parens' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def func
        end
      RUBY
    end

    it 'auto-adds required parens for a def' do
      new_source = autocorrect_source('def test param; end')
      expect(new_source).to eq('def test(param); end')
    end

    it 'auto-adds required parens for a defs' do
      new_source = autocorrect_source('def self.test param; end')
      expect(new_source).to eq('def self.test(param); end')
    end

    it 'auto-adds required parens to argument lists on multiple lines' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        def test one,
        two
        end
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        def test(one,
        two)
        end
      RUBY
    end
  end

  shared_examples 'no parentheses' do
    # common to require_no_parentheses and
    # require_no_parentheses_except_multiline
    it 'reports an offense for def with parameters with parens' do
      expect_offense(<<-RUBY.strip_indent)
        def func(a, b)
                ^^^^^^ Use def without parentheses.
        end
      RUBY
    end

    it 'accepts a def with parameters but no parens' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def func a, b
        end
      RUBY
    end

    it 'reports an offense for opposite + correct' do
      expect_offense(<<-RUBY.strip_indent)
        def func(a, b)
                ^^^^^^ Use def without parentheses.
        end
        def func a, b
        end
      RUBY
    end

    it 'reports an offense for class def with parameters with parens' do
      expect_offense(<<-RUBY.strip_indent)
        def Test.func(a, b)
                     ^^^^^^ Use def without parentheses.
        end
      RUBY
    end

    it 'accepts a class def with parameters with parens' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def Test.func a, b
        end
      RUBY
    end

    it 'reports an offense for def with no args and parens' do
      expect_offense(<<-RUBY.strip_indent)
        def func()
                ^^ Use def without parentheses.
        end
      RUBY
    end

    it 'accepts def with no args and no parens' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def func
        end
      RUBY
    end

    it 'auto-removes the parens' do
      new_source = autocorrect_source('def test(param); end')
      expect(new_source).to eq('def test param; end')
    end

    it 'auto-removes the parens for defs' do
      new_source = autocorrect_source('def self.test(param); end')
      expect(new_source).to eq('def self.test param; end')
    end
  end

  context 'require_no_parentheses' do
    let(:cop_config) { { 'EnforcedStyle' => 'require_no_parentheses' } }

    it_behaves_like 'no parentheses'
  end

  context 'require_no_parentheses_except_multiline' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'require_no_parentheses_except_multiline' }
    end

    context 'when args are all on a single line' do
      it_behaves_like 'no parentheses'
    end

    context 'when args span multiple lines' do
      it 'reports an offense for correct + opposite' do
        expect_offense(<<-RUBY.strip_indent)
          def func(a,
                   b)
          end
          def func a,
                   ^^ Use def with parentheses when there are parameters.
                   b
          end
        RUBY
      end

      it 'auto-adds required parens to argument lists on multiple lines' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          def test one,
          two
          end
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          def test(one,
          two)
          end
        RUBY
      end
    end
  end
end
