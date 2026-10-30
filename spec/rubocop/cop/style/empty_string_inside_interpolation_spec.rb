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

      it "registers an offense when #{empty} is the false outcome of a ternary and another value is a non-string literal" do
        expect_offense(<<~'RUBY', empty: empty)
          "#{condition ? 42 : %{empty}}"
             ^^^^^^^^^^^^^^^^^^{empty} Do not return empty strings in string interpolation.
        RUBY

        expect_correction(<<~'RUBY')
          "#{42 if condition}"
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

      it 'does not register an offense (or crash) for a trailing if with an empty string' do
        expect_no_offenses(<<~'RUBY')
          "#{'' if condition}"
        RUBY
      end

      it 'does not register an offense (or crash) for a trailing unless with an empty string' do
        expect_no_offenses(<<~'RUBY')
          "#{'' unless condition}"
        RUBY
      end
    end

    it 'registers an offense when ternaries with an empty false outcome are used in nested string interpolations' do
      expect_offense(<<~'RUBY')
        "#{outer ? "foo#{inner ? 'bar' : ''}" : ''}"
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not return empty strings in string interpolation.
                         ^^^^^^^^^^^^^^^^^^ Do not return empty strings in string interpolation.
      RUBY

      expect_correction(<<~'RUBY')
        "#{"foo#{'bar' if inner}" if outer}"
      RUBY
    end

    it 'registers an offense when ternaries with an empty true outcome are used in nested string interpolations' do
      expect_offense(<<~'RUBY')
        "#{outer ? '' : "foo#{inner ? '' : 'bar'}"}"
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not return empty strings in string interpolation.
                              ^^^^^^^^^^^^^^^^^^ Do not return empty strings in string interpolation.
      RUBY

      expect_correction(<<~'RUBY')
        "#{"foo#{'bar' unless inner}" unless outer}"
      RUBY
    end

    it 'registers an offense when a ternary with an empty outcome is used in the condition of another one' do
      expect_offense(<<~'RUBY')
        "#{"#{inner ? 'bar' : ''}".empty? ? 'foo' : ''}"
              ^^^^^^^^^^^^^^^^^^ Do not return empty strings in string interpolation.
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not return empty strings in string interpolation.
      RUBY

      expect_correction(<<~'RUBY')
        "#{'foo' if "#{'bar' if inner}".empty?}"
      RUBY
    end

    it 'registers an offense when a ternary without an empty outcome is used in the condition of another one' do
      expect_offense(<<~'RUBY')
        "#{"#{inner ? 'bar' : 'baz'}".empty? ? 'foo' : ''}"
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not return empty strings in string interpolation.
      RUBY

      expect_correction(<<~'RUBY')
        "#{'foo' if "#{inner ? 'bar' : 'baz'}".empty?}"
      RUBY
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

    it 'registers an offense when a trailing if is used with a method call without parentheses' do
      expect_offense(<<~'RUBY')
        "#{do_something 'foo', bar if condition}"
         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use trailing conditionals in string interpolation.
      RUBY

      expect_correction(<<~'RUBY')
        "#{condition ? do_something('foo', bar) : ''}"
      RUBY
    end

    it 'registers an offense when a trailing unless is used with a method call with a receiver and without parentheses' do
      expect_offense(<<~'RUBY')
        "#{obj.do_something 'foo' unless condition}"
         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use trailing conditionals in string interpolation.
      RUBY

      expect_correction(<<~'RUBY')
        "#{condition ? '' : obj.do_something('foo')}"
      RUBY
    end

    it 'registers an offense when a trailing if is used with `yield` without parentheses' do
      expect_offense(<<~'RUBY')
        "#{yield 'foo' if condition}"
         ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use trailing conditionals in string interpolation.
      RUBY

      expect_correction(<<~'RUBY')
        "#{condition ? yield('foo') : ''}"
      RUBY
    end

    it 'registers an offense when a trailing if is used with an operator method' do
      expect_offense(<<~'RUBY')
        "#{foo + bar if condition}"
         ^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use trailing conditionals in string interpolation.
      RUBY

      expect_correction(<<~'RUBY')
        "#{condition ? foo + bar : ''}"
      RUBY
    end

    it 'registers an offense when trailing conditionals are used in nested string interpolations' do
      expect_offense(<<~'RUBY')
        "#{"foo#{'bar' if inner}" if outer}"
         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use trailing conditionals in string interpolation.
               ^^^^^^^^^^^^^^^^^ Do not use trailing conditionals in string interpolation.
      RUBY

      expect_correction(<<~'RUBY')
        "#{outer ? "foo#{inner ? 'bar' : ''}" : ''}"
      RUBY
    end

    it 'registers an offense when trailing unless is used in nested string interpolations' do
      expect_offense(<<~'RUBY')
        "#{"foo#{'bar' unless inner}" unless outer}"
         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use trailing conditionals in string interpolation.
               ^^^^^^^^^^^^^^^^^^^^^ Do not use trailing conditionals in string interpolation.
      RUBY

      expect_correction(<<~'RUBY')
        "#{outer ? '' : "foo#{inner ? '' : 'bar'}"}"
      RUBY
    end

    it 'registers an offense when a trailing conditional is used in the condition of another one' do
      expect_offense(<<~'RUBY')
        "#{'foo' if "#{'bar' if inner}".empty?}"
                     ^^^^^^^^^^^^^^^^^ Do not use trailing conditionals in string interpolation.
         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use trailing conditionals in string interpolation.
      RUBY

      expect_correction(<<~'RUBY')
        "#{"#{inner ? 'bar' : ''}".empty? ? 'foo' : ''}"
      RUBY
    end

    it 'does not register an offense when empty string is the false outcome of a ternary' do
      expect_no_offenses(<<~'RUBY')
        "#{condition ? 'foo' : ''}"
      RUBY
    end
  end
end
