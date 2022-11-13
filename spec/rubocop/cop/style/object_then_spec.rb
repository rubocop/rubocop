# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ObjectThen, :config do
  context 'EnforcedStyle: then' do
    let(:cop_config) { { 'EnforcedStyle' => 'then' } }

    context 'Ruby 2.5', :ruby25 do
      it 'accepts yield_self with block' do
        expect_no_offenses(<<~RUBY)
          obj.yield_self { |e| e.test }
        RUBY
      end
    end

    context 'Ruby 2.6', :ruby26 do
      it 'registers an offense for yield_self with block' do
        expect_offense(<<~RUBY)
          obj.yield_self { |e| e.test }
              ^^^^^^^^^^ Prefer `then` over `yield_self`.
        RUBY

        expect_correction(<<~RUBY)
          obj.then { |e| e.test }
        RUBY
      end
    end

    context 'Ruby 2.7', :ruby27 do
      it 'registers an offense for yield_self with block' do
        expect_offense(<<~RUBY)
          obj.yield_self { _1.test }
              ^^^^^^^^^^ Prefer `then` over `yield_self`.
        RUBY

        expect_correction(<<~RUBY)
          obj.then { _1.test }
        RUBY
      end
    end

    it 'registers an offense for yield_self with proc param' do
      expect_offense(<<~RUBY)
        obj.yield_self(&:test)
            ^^^^^^^^^^ Prefer `then` over `yield_self`.
      RUBY

      expect_correction(<<~RUBY)
        obj.then(&:test)
      RUBY
    end

    it 'accepts yield_self with more than 1 param' do
      expect_no_offenses(<<~RUBY)
        obj.yield_self(other, &:test)
      RUBY
    end

    it 'accepts yield_self without a block' do
      expect_no_offenses(<<~RUBY)
        obj.yield_self
      RUBY
    end
  end

  context 'EnforcedStyle: yield_self' do
    let(:cop_config) { { 'EnforcedStyle' => 'yield_self' } }

    it 'registers an offense for then with block' do
      expect_offense(<<~RUBY)
        obj.then { |e| e.test }
            ^^^^ Prefer `yield_self` over `then`.
      RUBY

      expect_correction(<<~RUBY)
        obj.yield_self { |e| e.test }
      RUBY
    end

    it 'registers an offense for then with proc param' do
      expect_offense(<<~RUBY)
        obj.then(&:test)
            ^^^^ Prefer `yield_self` over `then`.
      RUBY

      expect_correction(<<~RUBY)
        obj.yield_self(&:test)
      RUBY
    end

    it 'accepts then with more than 1 param' do
      expect_no_offenses(<<~RUBY)
        obj.then(other, &:test)
      RUBY
    end

    it 'accepts then without a block' do
      expect_no_offenses(<<~RUBY)
        obj.then
      RUBY
    end
  end
end
