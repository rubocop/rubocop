# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::MapJoin, :config do
  %i[map collect].each do |method|
    context "with `#{method}(&:to_s).join`" do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY, method: method)
          array.#{method}(&:to_s).join(', ')
                ^{method} Remove redundant `#{method}(&:to_s)` before `join`.
        RUBY

        expect_correction(<<~RUBY)
          array.join(', ')
        RUBY
      end
    end

    context "with `#{method}(&:to_s).join` without arguments" do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY, method: method)
          array.#{method}(&:to_s).join
                ^{method} Remove redundant `#{method}(&:to_s)` before `join`.
        RUBY

        expect_correction(<<~RUBY)
          array.join
        RUBY
      end
    end

    context "with `#{method} { |x| x.to_s }.join`" do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY, method: method)
          array.#{method} { |x| x.to_s }.join(', ')
                ^{method} Remove redundant `#{method}(&:to_s)` before `join`.
        RUBY

        expect_correction(<<~RUBY)
          array.join(', ')
        RUBY
      end
    end

    context "with `#{method}(&:to_s).join` using safe navigation" do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY, method: method)
          array&.#{method}(&:to_s)&.join(', ')
                 ^{method} Remove redundant `#{method}(&:to_s)` before `join`.
        RUBY

        expect_correction(<<~RUBY)
          array&.join(', ')
        RUBY
      end
    end

    context "with `#{method}(&:to_s).join` without receiver" do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY, method: method)
          #{method}(&:to_s).join(', ')
          ^{method} Remove redundant `#{method}(&:to_s)` before `join`.
        RUBY

        expect_correction(<<~RUBY)
          join(', ')
        RUBY
      end
    end

    context "with `#{method} { |x| x.to_s }.join` without receiver" do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY, method: method)
          #{method} { |x| x.to_s }.join(', ')
          ^{method} Remove redundant `#{method}(&:to_s)` before `join`.
        RUBY

        expect_correction(<<~RUBY)
          join(', ')
        RUBY
      end
    end

    context "with `#{method}` doing something other than `to_s`" do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          array.#{method}(&:to_i).join(', ')
        RUBY
      end
    end

    context "with `#{method}` with a block doing something other than `to_s`" do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          array.#{method} { |x| x.to_i }.join(', ')
        RUBY
      end
    end

    context "with `#{method}(&:to_s)` without `join`" do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          array.#{method}(&:to_s)
        RUBY
      end
    end
  end

  context 'with numbered parameters', :ruby27 do
    it 'registers an offense and corrects `map { _1.to_s }.join`' do
      expect_offense(<<~RUBY)
        array.map { _1.to_s }.join(', ')
              ^^^ Remove redundant `map(&:to_s)` before `join`.
      RUBY

      expect_correction(<<~RUBY)
        array.join(', ')
      RUBY
    end
  end

  context 'with `it` parameter', :ruby34, unsupported_on: :prism do
    it 'registers an offense and corrects `map { it.to_s }.join`' do
      expect_offense(<<~RUBY)
        array.map { it.to_s }.join(', ')
              ^^^ Remove redundant `map(&:to_s)` before `join`.
      RUBY

      expect_correction(<<~RUBY)
        array.join(', ')
      RUBY
    end
  end

  context 'with multiline' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        array
          .map(&:to_s)
           ^^^ Remove redundant `map(&:to_s)` before `join`.
          .join(', ')
      RUBY

      expect_correction(<<~RUBY)
        array
          .join(', ')
      RUBY
    end
  end

  context 'with `map` followed by something other than `join`' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        array.map(&:to_s).compact
      RUBY
    end
  end

  context 'with `join` without preceding `map`' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        array.join(', ')
      RUBY
    end
  end

  context 'with `map` block that calls `to_s` with arguments' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        array.map { |x| x.to_s(16) }.join(', ')
      RUBY
    end
  end
end
