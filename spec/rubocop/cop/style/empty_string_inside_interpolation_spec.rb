# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::EmptyStringInsideInterpolation, :config do
  context 'when EnforcedStyle is ternary' do
    let(:cop_config) { { 'EnforcedStyle' => 'ternary' } }

    %w['' "" nil].each do |empty|
      it "registers an offense when #{empty} is the false outcome of a ternary" do
        expect_offense(<<~'RUBY', empty: empty)
          "#{condition ? 'foo' : %{empty}}"
             ^^^^^^^^^^^^^^^^^^^^^{empty} Do not return empty strings in string interpolation.
        RUBY

        expect_correction(<<~'RUBY')
          "#{'foo' if condition}"
        RUBY
      end

      it "registers an offense when #{empty} is the false outcome of a single-line conditional" do
        expect_offense(<<~'RUBY', empty: empty)
          "#{if condition; 'foo' else %{empty} end}"
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^{empty} Do not return empty strings in string interpolation.
        RUBY

        expect_correction(<<~'RUBY')
          "#{'foo' if condition}"
        RUBY
      end

      it "registers an offense when #{empty} is the true outcome of a ternary" do
        expect_offense(<<~'RUBY', empty: empty)
          "#{condition ? %{empty} : 'foo'}"
             ^^^^^^^^^^^^^^^^^^^^^{empty} Do not return empty strings in string interpolation.
        RUBY

        expect_correction(<<~'RUBY')
          "#{'foo' unless condition}"
        RUBY
      end

      it "registers an offense when #{empty} is the true outcome of a single-line conditional" do
        expect_offense(<<~'RUBY', empty: empty)
          "#{if condition; %{empty} else 'foo' end}"
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^{empty} Do not return empty strings in string interpolation.
        RUBY

        expect_correction(<<~'RUBY')
          "#{'foo' unless condition}"
        RUBY
      end
    end
  end

  context 'when EnforcedStyle is trailing_conditional' do
    let(:cop_config) { { 'EnforcedStyle' => 'trailing_conditional' } }

    it 'registers an offense when a trailing if is used inside string interpolation' do
      expect_offense(<<~'RUBY')
        "#{'foo' if condition}"
         ^^^^^^^^^^^^^^^^^^^^^ Do not use trailing conditionals in string interpolation.
      RUBY

      expect_correction(<<~'RUBY')
        "#{condition ? 'foo' : ''}"
      RUBY
    end

    it 'registers an offense when a trailing unless is used inside string interpolation' do
      expect_offense(<<~'RUBY')
        "#{'foo' unless condition}"
         ^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use trailing conditionals in string interpolation.
      RUBY

      expect_correction(<<~'RUBY')
        "#{condition ? '' : 'foo'}"
      RUBY
    end
  end
end
