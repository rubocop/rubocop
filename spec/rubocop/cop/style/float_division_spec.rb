# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::FloatDivision, :config do
  subject(:cop) { described_class.new(config) }

  context 'EnforcedStyle is left_coerce' do
    let(:cop_config) { { 'EnforcedStyle' => 'left_coerce' } }

    it 'registers offense for right coerce' do
      expect_offense(<<~RUBY)
        a / b.to_f
        ^^^^^^^^^^ Prefer using `.to_f` on the left side.
      RUBY
    end

    it 'registers offense for both coerce' do
      expect_offense(<<~RUBY)
        a.to_f / b.to_f
        ^^^^^^^^^^^^^^^ Prefer using `.to_f` on the left side.
      RUBY
    end

    it 'registers offense for right coerce with calculations' do
      expect_offense(<<~RUBY)
        (a * b) / (c - d / 2).to_f
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `.to_f` on the left side.
      RUBY
    end

    it 'does not register offense for left coerce' do
      expect_no_offenses('a.to_f / b')
    end
  end

  context 'EnforcedStyle is right_coerce' do
    let(:cop_config) { { 'EnforcedStyle' => 'right_coerce' } }

    it 'registers offense for left coerce' do
      expect_offense(<<~RUBY)
        a.to_f / b
        ^^^^^^^^^^ Prefer using `.to_f` on the right side.
      RUBY
    end

    it 'registers offense for both coerce' do
      expect_offense(<<~RUBY)
        a.to_f / b.to_f
        ^^^^^^^^^^^^^^^ Prefer using `.to_f` on the right side.
      RUBY
    end

    it 'registers offense for left coerce with calculations' do
      expect_offense(<<~RUBY)
        (a - b).to_f / (c * 3 * d / 2)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `.to_f` on the right side.
      RUBY
    end

    it 'does not register offense for right coerce' do
      expect_no_offenses('a / b.to_f')
    end
  end

  context 'EnforcedStyle is single_coerce' do
    let(:cop_config) { { 'EnforcedStyle' => 'single_coerce' } }

    it 'registers offense for both coerce' do
      expect_offense(<<~RUBY)
        a.to_f / b.to_f
        ^^^^^^^^^^^^^^^ Prefer using `.to_f` on one side only.
      RUBY
    end

    it 'registers offense for left coerce with calculations' do
      expect_offense(<<~RUBY)
        (a - b).to_f / (3 * d / 2).to_f
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `.to_f` on one side only.
      RUBY
    end

    it 'does not register offense for left coerce only' do
      expect_no_offenses('a.to_f / b')
    end

    it 'does not register offense for right coerce only' do
      expect_no_offenses('a / b.to_f')
    end
  end

  context 'EnforcedStyle is fdiv' do
    let(:cop_config) { { 'EnforcedStyle' => 'fdiv' } }

    it 'registers offense for right coerce' do
      expect_offense(<<~RUBY)
        a / b.to_f
        ^^^^^^^^^^ Prefer using `fdiv` for float divisions.
      RUBY
    end

    it 'registers offense for both coerce' do
      expect_offense(<<~RUBY)
        a.to_f / b.to_f
        ^^^^^^^^^^^^^^^ Prefer using `fdiv` for float divisions.
      RUBY
    end

    it 'registers offense for left coerce' do
      expect_offense(<<~RUBY)
        a.to_f / b
        ^^^^^^^^^^ Prefer using `fdiv` for float divisions.
      RUBY
    end

    it 'registers offense for left coerce with calculations' do
      expect_offense(<<~RUBY)
        (a - b).to_f / (c * 3 * d / 2)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `fdiv` for float divisions.
      RUBY
    end

    it 'does not register offense on usage of fdiv' do
      expect_no_offenses('a.fdiv(b)')
    end
  end
end
