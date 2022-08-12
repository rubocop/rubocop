# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::MethodCalledOnDoEndBlock, :config do
  context 'with a multi-line do..end block' do
    it 'registers an offense for a chained call' do
      expect_offense(<<~RUBY)
        a do
          b
        end.c
        ^^^^^ Avoid chaining a method call on a do...end block.
      RUBY
    end

    context 'when using safe navigation operator' do
      it 'registers an offense for a chained call' do
        expect_offense(<<~RUBY)
          a do
            b
          end&.c
          ^^^^^^ Avoid chaining a method call on a do...end block.
        RUBY
      end
    end

    it 'accepts it if there is no chained call' do
      expect_no_offenses(<<~RUBY)
        a do
          b
        end
      RUBY
    end

    it 'accepts a chained block' do
      expect_no_offenses(<<~RUBY)
        a do
          b
        end.c do
          d
        end
      RUBY
    end
  end

  context 'with a single-line do..end block' do
    it 'registers an offense for a chained call' do
      expect_offense(<<~RUBY)
        a do b end.c
               ^^^^^ Avoid chaining a method call on a do...end block.
      RUBY
    end

    it 'accepts a single-line do..end block with a chained block' do
      expect_no_offenses('a do b end.c do d end')
    end
  end

  context 'with a {} block' do
    it 'accepts a multi-line block with a chained call' do
      expect_no_offenses(<<~RUBY)
        a {
          b
        }.c
      RUBY
    end

    it 'accepts a single-line block with a chained call' do
      expect_no_offenses('a { b }.c')
    end
  end

  context 'Ruby 2.7', :ruby27 do
    it 'registers an offense for a chained call' do
      expect_offense(<<~RUBY)
        a do
          _1
        end.c
        ^^^^^ Avoid chaining a method call on a do...end block.
      RUBY
    end
  end
end
