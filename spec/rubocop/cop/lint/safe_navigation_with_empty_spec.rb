# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::SafeNavigationWithEmpty, :config do
  context 'in a conditional' do
    it 'registers an offense and corrects on `&.empty?`' do
      expect_offense(<<~RUBY)
        return unless foo&.empty?
                      ^^^^^^^^^^^ Avoid calling `empty?` with the safe navigation operator in conditionals.
      RUBY

      expect_correction(<<~RUBY)
        return unless foo && foo.empty?
      RUBY
    end

    it 'registers an offense and corrects when the receiver is a local variable' do
      expect_offense(<<~RUBY)
        foo = build_collection
        return if foo&.empty?
                  ^^^^^^^^^^^ Avoid calling `empty?` with the safe navigation operator in conditionals.
      RUBY

      expect_correction(<<~RUBY)
        foo = build_collection
        return if foo && foo.empty?
      RUBY
    end

    it 'registers an offense and corrects when the receiver is an instance variable' do
      expect_offense(<<~RUBY)
        return if @foo&.empty?
                  ^^^^^^^^^^^^ Avoid calling `empty?` with the safe navigation operator in conditionals.
      RUBY

      expect_correction(<<~RUBY)
        return if @foo && @foo.empty?
      RUBY
    end

    it 'registers an offense and corrects when the receiver is a constant' do
      expect_offense(<<~RUBY)
        return if FOO&.empty?
                  ^^^^^^^^^^^ Avoid calling `empty?` with the safe navigation operator in conditionals.
      RUBY

      expect_correction(<<~RUBY)
        return if FOO && FOO.empty?
      RUBY
    end

    it 'does not register an offense on `.empty?`' do
      expect_no_offenses(<<~RUBY)
        return if foo.empty?
      RUBY
    end

    it 'does not register an offense when the receiver uses safe navigation' do
      expect_no_offenses(<<~RUBY)
        return if foo&.bar&.empty?
      RUBY
    end
  end

  context 'outside a conditional' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        bar = foo&.empty?
      RUBY
    end
  end
end
