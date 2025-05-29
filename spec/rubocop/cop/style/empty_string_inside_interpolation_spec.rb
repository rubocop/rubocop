# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::EmptyStringInsideInterpolation, :config do
  context 'when EnforcedStyle is trailing_conditional' do
    let(:cop_config) { { 'EnforcedStyle' => 'trailing_conditional' } }

    it 'does not register an offense when if branch is not a literal' do
      expect_no_offenses(<<~'RUBY')
        "#{condition ? send_node : 'foo'}"
      RUBY
    end

    it 'does not register an offense when else branch is not a literal' do
      expect_no_offenses(<<~'RUBY')
        "#{condition ? 'foo' : send_node}"
      RUBY
    end

    it 'does not register an offense when both if and else branches are not literals' do
      expect_no_offenses(<<~'RUBY')
        "#{condition ? send_node : another_send_node}"
      RUBY
    end

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

      it 'does not register an offense when a trailing if is used inside string interpolation' do
        expect_no_offenses(<<~'RUBY')
          "#{'foo' if condition}"
        RUBY
      end
    end
  end

  context 'when EnforcedStyle is ternary' do
    let(:cop_config) { { 'EnforcedStyle' => 'ternary' } }

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

    it 'does not register an offense when empty string is the false outcome of a ternary' do
      expect_no_offenses(<<~'RUBY')
        "#{condition ? 'foo' : ''}"
      RUBY
    end
  end
end
