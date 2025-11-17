# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::UselessOr, :config do
  described_class::TRUTHY_RETURN_VALUE_METHODS.each do |method|
    it "registers an offense with `x.#{method} || fallback`" do
      expect_offense(<<~RUBY, method: method)
        x.#{method} || fallback
          _{method} ^^^^^^^^^^^ `fallback` will never evaluate because `x.#{method}` always returns a truthy value.
      RUBY

      expect_correction(<<~RUBY)
        x.#{method}
      RUBY
    end

    it "registers an offense with `x.#{method} or fallback`" do
      expect_offense(<<~RUBY, method: method)
        x.#{method} or fallback
          _{method} ^^^^^^^^^^^ `fallback` will never evaluate because `x.#{method}` always returns a truthy value.
      RUBY

      expect_correction(<<~RUBY)
        x.#{method}
      RUBY
    end

    it "registers an offense with `x.#{method} || fallback || other_fallback`" do
      expect_offense(<<~RUBY, method: method)
        x.#{method} || fallback || other_fallback
          _{method} ^^^^^^^^^^^ `fallback` will never evaluate because `x.#{method}` always returns a truthy value.
      RUBY

      expect_correction(<<~RUBY)
        x.#{method}
      RUBY
    end

    it "registers an offense with `foo || x.#{method} || fallback`" do
      expect_offense(<<~RUBY, method: method)
        foo || x.#{method} || fallback
                 _{method} ^^^^^^^^^^^ `fallback` will never evaluate because `x.#{method}` always returns a truthy value.
      RUBY

      expect_correction(<<~RUBY)
        foo || x.#{method}
      RUBY
    end

    it "registers an offense with `(foo || x.#{method}) || fallback`" do
      expect_offense(<<~RUBY, method: method)
        (foo || x.#{method}) || fallback
                  _{method}  ^^^^^^^^^^^ `fallback` will never evaluate because `x.#{method}` always returns a truthy value.
      RUBY

      expect_correction(<<~RUBY)
        (foo || x.#{method})
      RUBY
    end

    it "does not register an offense with `(foo || x.#{method}) && operand`" do
      expect_no_offenses(<<~RUBY)
        (foo || x.#{method}) && operand
      RUBY
    end

    it "does not register an offense with `foo || x.#{method}`" do
      expect_no_offenses(<<~RUBY)
        foo || x.#{method}
      RUBY
    end

    it "does not register an offense with `x&.#{method} || fallback`" do
      expect_no_offenses(<<~RUBY)
        x&.#{method} || fallback
      RUBY
    end

    it "does not register an offense with `x.#{method}`" do
      expect_no_offenses(<<~RUBY)
        x.#{method}
      RUBY
    end
  end

  it 'does not register an offense with `x.foo || fallback`' do
    expect_no_offenses(<<~RUBY)
      x.foo || fallback
    RUBY
  end
end
