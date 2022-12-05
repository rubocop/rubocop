# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ArrayIntersect, :config do
  context 'when TargetRubyVersion <= 3.0', :ruby30 do
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

      it 'does not register an offense when using `alpha & beta`' do
        expect_no_offenses(<<~RUBY)
          alpha & beta
        RUBY
      end
    end
  end
end
