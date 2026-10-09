# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::ImplicitTypeCoercion, :config do
  { '0.0' => '.to_f', '0r' => '.to_r', '0i' => '.to_c' }.each do |zero, type|
    it "registers an offense on x + #{zero}" do
      expect_offense(<<~RUBY, zero: zero, type: type)
        x + #{zero}
        ^^^^^{zero} This operation is mathematically inconsequential, but it implicitly changes the type of the receiver. Use #{type} instead.
      RUBY

      expect_correction(<<~RUBY)
        x#{type}
      RUBY
    end

    it "registers an offense on x - #{zero}" do
      expect_offense(<<~RUBY, zero: zero, type: type)
        x - #{zero}
        ^^^^^{zero} This operation is mathematically inconsequential, but it implicitly changes the type of the receiver. Use #{type} instead.
      RUBY

      expect_correction(<<~RUBY)
        x#{type}
      RUBY
    end
  end

  { '1.0' => '.to_f', '1r' => '.to_r' }.each do |one, type|
    it "registers an offense on x * #{one}" do
      expect_offense(<<~RUBY, one: one, type: type)
        x * #{one}
        ^^^^^{one} This operation is mathematically inconsequential, but it implicitly changes the type of the receiver. Use #{type} instead.
      RUBY

      expect_correction(<<~RUBY)
        x#{type}
      RUBY
    end

    it "registers an offense on x / #{one}" do
      expect_offense(<<~RUBY, one: one, type: type)
        x / #{one}
        ^^^^^{one} This operation is mathematically inconsequential, but it implicitly changes the type of the receiver. Use #{type} instead.
      RUBY

      expect_correction(<<~RUBY)
        x#{type}
      RUBY
    end

    it "registers an offense on x ** #{one}" do
      expect_offense(<<~RUBY, one: one, type: type)
        x ** #{one}
        ^^^^^^{one} This operation is mathematically inconsequential, but it implicitly changes the type of the receiver. Use #{type} instead.
      RUBY

      expect_correction(<<~RUBY)
        x#{type}
      RUBY
    end
  end
end
