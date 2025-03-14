# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ArrayIntersect, :config do
  context 'when TargetRubyVersion <= 3.0', :ruby30, unsupported_on: :prism do
    it 'does not register an offense when using `(array1 & array2).any?`' do
      expect_no_offenses(<<~RUBY)
        (array1 & array2).any?
      RUBY
    end
  end

  context 'when TargetRubyVersion >= 3.1', :ruby31 do
    it 'registers an offense when using `(array1 & array2).any?`' do
      expect_offense(<<~RUBY)
        (array1 & array2).any?
        ^^^^^^^^^^^^^^^^^^^^^^ Use `array1.intersect?(array2)` instead of `(array1 & array2).any?`.
      RUBY

      expect_correction(<<~RUBY)
        array1.intersect?(array2)
      RUBY
    end

    it 'registers an offense when using `(customer_country_codes & SUPPORTED_COUNTRIES).empty?`' do
      expect_offense(<<~RUBY)
        (customer_country_codes & SUPPORTED_COUNTRIES).empty?
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `!customer_country_codes.intersect?(SUPPORTED_COUNTRIES)` instead of `(customer_country_codes & SUPPORTED_COUNTRIES).empty?`.
      RUBY

      expect_correction(<<~RUBY)
        !customer_country_codes.intersect?(SUPPORTED_COUNTRIES)
      RUBY
    end

    it 'registers an offense when using `none?`' do
      expect_offense(<<~RUBY)
        (a & b).none?
        ^^^^^^^^^^^^^ Use `!a.intersect?(b)` instead of `(a & b).none?`.
      RUBY

      expect_correction(<<~RUBY)
        !a.intersect?(b)
      RUBY
    end

    it 'does not register an offense when using `(array1 & array2).any?` with block' do
      expect_no_offenses(<<~RUBY)
        (array1 & array2).any? { |x| false }
      RUBY
    end

    it 'does not register an offense when using `(array1 & array2).any?` with symbol block' do
      expect_no_offenses(<<~RUBY)
        (array1 & array2).any?(&:block)
      RUBY
    end

    it 'does not register an offense when using `(array1 & array2).any?` with numbered block' do
      expect_no_offenses(<<~RUBY)
        (array1 & array2).any? { do_something(_1) }
      RUBY
    end

    it 'does not register an offense when using `([1, 2, 3] & [4, 5, 6]).present?`' do
      expect_no_offenses(<<~RUBY)
        ([1, 2, 3] & [4, 5, 6]).present?
      RUBY
    end

    it 'does not register an offense when using `([1, 2, 3] & [4, 5, 6]).blank?`' do
      expect_no_offenses(<<~RUBY)
        ([1, 2, 3] & [4, 5, 6]).blank?
      RUBY
    end

    context 'with Array#intersection' do
      it 'registers an offense for `a.intersection(b).any?`' do
        expect_offense(<<~RUBY)
          a.intersection(b).any?
          ^^^^^^^^^^^^^^^^^^^^^^ Use `a.intersect?(b)` instead of `a.intersection(b).any?`.
        RUBY

        expect_correction(<<~RUBY)
          a.intersect?(b)
        RUBY
      end

      it 'registers an offense for `a.intersection(b).none?`' do
        expect_offense(<<~RUBY)
          a.intersection(b).none?
          ^^^^^^^^^^^^^^^^^^^^^^^ Use `!a.intersect?(b)` instead of `a.intersection(b).none?`.
        RUBY

        expect_correction(<<~RUBY)
          !a.intersect?(b)
        RUBY
      end

      it 'registers an offense for `a.intersection(b).empty?`' do
        expect_offense(<<~RUBY)
          a.intersection(b).empty?
          ^^^^^^^^^^^^^^^^^^^^^^^^ Use `!a.intersect?(b)` instead of `a.intersection(b).empty?`.
        RUBY

        expect_correction(<<~RUBY)
          !a.intersect?(b)
        RUBY
      end

      it 'registers an offense when using safe navigation' do
        expect_offense(<<~RUBY)
          a&.intersection(b)&.any?
          ^^^^^^^^^^^^^^^^^^^^^^^^ Use `a&.intersect?(b)` instead of `a&.intersection(b)&.any?`.
        RUBY

        expect_correction(<<~RUBY)
          a&.intersect?(b)
        RUBY
      end

      it 'does not register an offense for `array.intersection` with no arguments' do
        expect_no_offenses(<<~RUBY)
          array1.intersection.any?
        RUBY
      end

      it 'does not register an offense for `array.intersection` with multiple arguments' do
        expect_no_offenses(<<~RUBY)
          array1.intersection(array2, array3).any?
        RUBY
      end
    end

    context 'when `AllCops/ActiveSupportExtensionsEnabled: true`' do
      let(:config) do
        RuboCop::Config.new('AllCops' => {
                              'TargetRubyVersion' => '3.1',
                              'ActiveSupportExtensionsEnabled' => true
                            })
      end

      it 'registers an offense when using `([1, 2, 3] & [4, 5, 6]).present?`' do
        expect_offense(<<~RUBY)
          ([1, 2, 3] & [4, 5, 6]).present?
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `[1, 2, 3].intersect?([4, 5, 6])` instead of `([1, 2, 3] & [4, 5, 6]).present?`.
        RUBY

        expect_correction(<<~RUBY)
          [1, 2, 3].intersect?([4, 5, 6])
        RUBY
      end

      it 'registers an offense when using `(conditions.pluck("type") & %w[customer_country ip_country]).blank?`' do
        expect_offense(<<~RUBY)
          (conditions.pluck("type") & %w[customer_country ip_country]).blank?
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `!conditions.pluck("type").intersect?(%w[customer_country ip_country])` instead of `(conditions.pluck("type") & %w[customer_country ip_country]).blank?`.
        RUBY

        expect_correction(<<~RUBY)
          !conditions.pluck("type").intersect?(%w[customer_country ip_country])
        RUBY
      end

      it 'registers an offense for `a.intersection(b).present?`' do
        expect_offense(<<~RUBY)
          a.intersection(b).present?
          ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `a.intersect?(b)` instead of `a.intersection(b).present?`.
        RUBY

        expect_correction(<<~RUBY)
          a.intersect?(b)
        RUBY
      end

      it 'registers an offense for `a.intersection(b).blank?`' do
        expect_offense(<<~RUBY)
          a.intersection(b).blank?
          ^^^^^^^^^^^^^^^^^^^^^^^^ Use `!a.intersect?(b)` instead of `a.intersection(b).blank?`.
        RUBY

        expect_correction(<<~RUBY)
          !a.intersect?(b)
        RUBY
      end

      it 'does not register an offense when using `alpha & beta`' do
        expect_no_offenses(<<~RUBY)
          alpha & beta
        RUBY
      end
    end
  end
end
