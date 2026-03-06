# frozen_string_literal: true

RSpec.shared_examples 'chained negative conditions' do |offense_keyword, corrected_keyword|
  context 'when `AllowChainedConditions: false` (default)' do
    it "registers an offense for `#{offense_keyword}` with exclamation point conditions chained with `&&`" do
      expect_offense(<<~RUBY, offense_keyword: offense_keyword)
        #{offense_keyword} !foo && !bar && !baz
        ^{offense_keyword}^^^^^^^^^^^^^^^^^^^^^ Favor `#{corrected_keyword}` over `#{offense_keyword}` for negative conditions.
          some_method
        end
        some_method #{offense_keyword} !foo && !bar && !baz
        ^^^^^^^^^^^^^{offense_keyword}^^^^^^^^^^^^^^^^^^^^^ Favor `#{corrected_keyword}` over `#{offense_keyword}` for negative conditions.
      RUBY

      expect_correction(<<~RUBY)
        #{corrected_keyword} foo || bar || baz
          some_method
        end
        some_method #{corrected_keyword} foo || bar || baz
      RUBY
    end

    it "registers an offense for `#{offense_keyword}` with exclamation point conditions chained with `and`" do
      expect_offense(<<~RUBY, offense_keyword: offense_keyword)
        #{offense_keyword} !foo and !bar and !baz
        ^{offense_keyword}^^^^^^^^^^^^^^^^^^^^^^^ Favor `#{corrected_keyword}` over `#{offense_keyword}` for negative conditions.
          some_method
        end
        some_method #{offense_keyword} !foo and !bar and !baz
        ^^^^^^^^^^^^^{offense_keyword}^^^^^^^^^^^^^^^^^^^^^^^ Favor `#{corrected_keyword}` over `#{offense_keyword}` for negative conditions.
      RUBY

      expect_correction(<<~RUBY)
        #{corrected_keyword} foo or bar or baz
          some_method
        end
        some_method #{corrected_keyword} foo or bar or baz
      RUBY
    end

    it "registers an offense for `#{offense_keyword}` with exclamation point conditions chained with `||`" do
      expect_offense(<<~RUBY, offense_keyword: offense_keyword)
        #{offense_keyword} !foo || !bar || !baz
        ^{offense_keyword}^^^^^^^^^^^^^^^^^^^^^ Favor `#{corrected_keyword}` over `#{offense_keyword}` for negative conditions.
          some_method
        end
        some_method #{offense_keyword} !foo || !bar || !baz
        ^^^^^^^^^^^^^{offense_keyword}^^^^^^^^^^^^^^^^^^^^^ Favor `#{corrected_keyword}` over `#{offense_keyword}` for negative conditions.
      RUBY

      expect_correction(<<~RUBY)
        #{corrected_keyword} foo && bar && baz
          some_method
        end
        some_method #{corrected_keyword} foo && bar && baz
      RUBY
    end

    it "registers an offense for `#{offense_keyword}` with exclamation point conditions chained with `or`" do
      expect_offense(<<~RUBY, offense_keyword: offense_keyword)
        #{offense_keyword} !foo or !bar or !baz
        ^{offense_keyword}^^^^^^^^^^^^^^^^^^^^^ Favor `#{corrected_keyword}` over `#{offense_keyword}` for negative conditions.
          some_method
        end
        some_method #{offense_keyword} !foo or !bar or !baz
        ^^^^^^^^^^^^^{offense_keyword}^^^^^^^^^^^^^^^^^^^^^ Favor `#{corrected_keyword}` over `#{offense_keyword}` for negative conditions.
      RUBY

      expect_correction(<<~RUBY)
        #{corrected_keyword} foo and bar and baz
          some_method
        end
        some_method #{corrected_keyword} foo and bar and baz
      RUBY
    end

    it "does not register an offense for `#{offense_keyword}` with conditions chained with different operators" do
      expect_no_offenses(<<~RUBY)
        some_method #{offense_keyword} !foo || !bar && !baz
      RUBY
    end

    it "does not register an offense for `#{offense_keyword}` with chained conditions when LHS condition isn't negated" do
      expect_no_offenses(<<~RUBY)
        some_method #{offense_keyword} foo && !bar && !baz
      RUBY
    end

    it "does not register an offense for `#{offense_keyword}` with chained conditions when RHS condition isn't negated" do
      expect_no_offenses(<<~RUBY)
        some_method #{offense_keyword} !foo && bar && !baz
      RUBY
    end
  end

  context 'when `AllowChainedConditions: true`' do
    let(:cop_config) { { 'AllowChainedConditions' => true } }

    it "accepts `#{offense_keyword}` with chained exclamation point conditions" do
      expect_no_offenses(<<~RUBY)
        #{offense_keyword} !foo && !bar && !baz
          some_method
        end
        some_method #{offense_keyword} !foo && !bar && !baz
      RUBY
    end
  end
end
