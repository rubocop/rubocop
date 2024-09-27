# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::EmptyStringInsideInterpolation, :config do
  %w('' "" nil).each do |empty|
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
