# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::HashLikeCase, :config do
  context 'MinBranchesCount: 2' do
    let(:cop_config) { { 'MinBranchesCount' => 2 } }

    it 'registers an offense when using `case-when` with string conditions and literal bodies of the same type' do
      expect_offense(<<~RUBY)
        case x
        ^^^^^^ Consider replacing `case-when` with a hash lookup.
        when 'foo'
          'FOO'
        when 'bar'
          'BAR'
        end
      RUBY
    end

    it 'registers an offense when using `case-when` with symbol conditions and literal bodies of the same type' do
      expect_offense(<<~RUBY)
        case x
        ^^^^^^ Consider replacing `case-when` with a hash lookup.
        when :foo
          'FOO'
        when :bar
          'BAR'
        end
      RUBY
    end

    it 'does not register an offense when using `case-when` with literals of different types as conditions' do
      expect_no_offenses(<<~RUBY)
        case x
        when 'foo'
          'FOO'
        when :bar
          'BAR'
        end
      RUBY
    end

    it 'does not register an offense when using `case-when` with non-literals in conditions' do
      expect_no_offenses(<<~RUBY)
        case x
        when y
          'FOO'
        when z
          'BAR'
        end
      RUBY
    end

    it 'does not register an offense when using `case-when` with literal bodies of different types' do
      expect_no_offenses(<<~RUBY)
        case x
        when 'foo'
          'FOO'
        when 'bar'
          2
        end
      RUBY
    end

    it 'does not register an offense when using `case-when` with non-literal bodies' do
      expect_no_offenses(<<~RUBY)
        case x
        when 'foo'
          y
        when 'bar'
          z
        end
      RUBY
    end

    it 'does not register an offense when `case` has an `else` branch' do
      expect_no_offenses(<<~RUBY)
        case x
        when 'foo'
          'FOO'
        when 'bar'
          'BAR'
        else
          'BAZ'
        end
      RUBY
    end
  end

  context 'MinBranchesCount: 3' do
    let(:cop_config) { { 'MinBranchesCount' => 3 } }

    it 'does not register an offense when branches count is less than required' do
      expect_no_offenses(<<~RUBY)
        case x
        when 'foo'
          'FOO'
        when 'bar'
          'BAR'
        end
      RUBY
    end
  end
end
