# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ArrayIntersect, :config do
  context 'when TargetRubyVersion <= 3.0', :ruby30, unsupported_on: :prism do
    it 'does not register an offense when using `(array1 & array2).any?`' do
      expect_no_offenses(<<~RUBY)
        (array1 & array2).any?
      RUBY
    end

    it 'does not register an offense when using `array1.any? { |e| array2.member?(e) }`' do
      expect_no_offenses(<<~RUBY)
        array1.any? { |e| array2.member?(e) }
      RUBY
    end

    it 'does not register an offense when using `array1.none? { |e| array2.member?(e) }`' do
      expect_no_offenses(<<~RUBY)
        array1.none? { |e| array2.member?(e) }
      RUBY
    end
  end

  context 'when TargetRubyVersion >= 3.1', :ruby31 do
    context 'with Array#&' do
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

      described_class::ARRAY_SIZE_METHODS.each do |method|
        it "registers an offense when using `.#{method} > 0`" do
          expect_offense(<<~RUBY, method: method)
            (a & b).#{method} > 0
            ^^^^^^^^^{method}^^^^ Use `a.intersect?(b)` instead of `(a & b).#{method} > 0`.
          RUBY

          expect_correction(<<~RUBY)
            a.intersect?(b)
          RUBY
        end

        it "registers an offense when using `.#{method} == 0`" do
          expect_offense(<<~RUBY, method: method)
            (a & b).#{method} == 0
            ^^^^^^^^^{method}^^^^^ Use `!a.intersect?(b)` instead of `(a & b).#{method} == 0`.
          RUBY

          expect_correction(<<~RUBY)
            !a.intersect?(b)
          RUBY
        end

        it "registers an offense when using `.#{method} != 0`" do
          expect_offense(<<~RUBY, method: method)
            (a & b).#{method} != 0
            ^^^^^^^^^{method}^^^^^ Use `a.intersect?(b)` instead of `(a & b).#{method} != 0`.
          RUBY

          expect_correction(<<~RUBY)
            a.intersect?(b)
          RUBY
        end

        it "registers an offense when using `.#{method}.zero?`" do
          expect_offense(<<~RUBY, method: method)
            (a & b).#{method}.zero?
            ^^^^^^^^^{method}^^^^^^ Use `!a.intersect?(b)` instead of `(a & b).#{method}.zero?`.
          RUBY

          expect_correction(<<~RUBY)
            !a.intersect?(b)
          RUBY
        end

        it "registers an offense when using `.#{method}.positive?`" do
          expect_offense(<<~RUBY, method: method)
            (a & b).#{method}.positive?
            ^^^^^^^^^{method}^^^^^^^^^^ Use `a.intersect?(b)` instead of `(a & b).#{method}.positive?`.
          RUBY

          expect_correction(<<~RUBY)
            a.intersect?(b)
          RUBY
        end

        it "does not register an offense when using `.#{method} > 1`" do
          expect_no_offenses(<<~RUBY)
            (a & b).#{method} > 1
          RUBY
        end

        it "does not register an offense when using `.#{method} == 1`" do
          expect_no_offenses(<<~RUBY)
            (a & b).#{method} == 1
          RUBY
        end
      end
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

      described_class::ARRAY_SIZE_METHODS.each do |method|
        it "registers an offense when using `.#{method} > 0`" do
          expect_offense(<<~RUBY, method: method)
            a.intersection(b).#{method} > 0
            ^^^^^^^^^^^^^^^^^^^{method}^^^^ Use `a.intersect?(b)` instead of `a.intersection(b).#{method} > 0`.
          RUBY

          expect_correction(<<~RUBY)
            a.intersect?(b)
          RUBY
        end

        it "registers an offense when using `.#{method} == 0`" do
          expect_offense(<<~RUBY, method: method)
            a.intersection(b).#{method} == 0
            ^^^^^^^^^^^^^^^^^^^{method}^^^^^ Use `!a.intersect?(b)` instead of `a.intersection(b).#{method} == 0`.
          RUBY

          expect_correction(<<~RUBY)
            !a.intersect?(b)
          RUBY
        end

        it "registers an offense when using `.#{method} != 0`" do
          expect_offense(<<~RUBY, method: method)
            a.intersection(b).#{method} != 0
            ^^^^^^^^^^^^^^^^^^^{method}^^^^^ Use `a.intersect?(b)` instead of `a.intersection(b).#{method} != 0`.
          RUBY

          expect_correction(<<~RUBY)
            a.intersect?(b)
          RUBY
        end

        it "registers an offense when using `.#{method}.zero?`" do
          expect_offense(<<~RUBY, method: method)
            a.intersection(b).#{method}.zero?
            ^^^^^^^^^^^^^^^^^^^{method}^^^^^^ Use `!a.intersect?(b)` instead of `a.intersection(b).#{method}.zero?`.
          RUBY

          expect_correction(<<~RUBY)
            !a.intersect?(b)
          RUBY
        end

        it "registers an offense when using `.#{method}.positive?`" do
          expect_offense(<<~RUBY, method: method)
            a.intersection(b).#{method}.positive?
            ^^^^^^^^^^^^^^^^^^^{method}^^^^^^^^^^ Use `a.intersect?(b)` instead of `a.intersection(b).#{method}.positive?`.
          RUBY

          expect_correction(<<~RUBY)
            a.intersect?(b)
          RUBY
        end

        it "registers an offense when using `&.#{method}&.positive?`" do
          expect_offense(<<~RUBY, method: method)
            a&.intersection(b)&.#{method}&.positive?
            ^^^^^^^^^^^^^^^^^^^^^{method}^^^^^^^^^^^ Use `a&.intersect?(b)` instead of `a&.intersection(b)&.#{method}&.positive?`.
          RUBY

          expect_correction(<<~RUBY)
            a&.intersect?(b)
          RUBY
        end

        it "does not register an offense when using `.#{method} > 1`" do
          expect_no_offenses(<<~RUBY)
            a.intersection(b).#{method} > 1
          RUBY
        end

        it "does not register an offense when using `.#{method} == 1`" do
          expect_no_offenses(<<~RUBY)
            a.intersection(b).#{method} == 1
          RUBY
        end
      end
    end

    context 'with Array#any?' do
      it 'registers an offense when using `array1.any? { |e| array2.member?(e) }`' do
        expect_offense(<<~RUBY)
          array1.any? { |e| array2.member?(e) }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `array1.intersect?(array2)` instead of `array1.any? { |e| array2.member?(e) }`.
        RUBY

        expect_correction(<<~RUBY)
          array1.intersect?(array2)
        RUBY
      end

      it 'registers an offense when using `array1&.any? { |e| array2.member?(e) }`' do
        expect_offense(<<~RUBY)
          array1&.any? { |e| array2.member?(e) }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `array1&.intersect?(array2)` instead of `array1&.any? { |e| array2.member?(e) }`.
        RUBY

        expect_correction(<<~RUBY)
          array1&.intersect?(array2)
        RUBY
      end

      it 'registers an offense when using `array1.any? { array2.member?(_1) }`' do
        expect_offense(<<~RUBY)
          array1.any? { array2.member?(_1) }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `array1.intersect?(array2)` instead of `array1.any? { array2.member?(_1) }`.
        RUBY

        expect_correction(<<~RUBY)
          array1.intersect?(array2)
        RUBY
      end

      context '>= Ruby 3.4', :ruby34 do
        it 'registers an offense when using `array1.any? { array2.member?(it) }`' do
          expect_offense(<<~RUBY)
            array1.any? { array2.member?(it) }
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `array1.intersect?(array2)` instead of `array1.any? { array2.member?(it) }`.
          RUBY

          expect_correction(<<~RUBY)
            array1.intersect?(array2)
          RUBY
        end
      end

      context '<= Ruby 3.3', :ruby33 do
        it 'does not register an offense when using `array1.any? { array2.member?(it) }`' do
          expect_no_offenses(<<~RUBY)
            array1.any? { array2.member?(it) }
          RUBY
        end
      end
    end

    context 'with Array#none?' do
      it 'registers an offense when using `array1.none? { |e| array2.member?(e) }`' do
        expect_offense(<<~RUBY)
          array1.none? { |e| array2.member?(e) }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `!array1.intersect?(array2)` instead of `array1.none? { |e| array2.member?(e) }`.
        RUBY

        expect_correction(<<~RUBY)
          !array1.intersect?(array2)
        RUBY
      end

      it 'registers an offense when using `array1&.none? { |e| array2.member?(e) }`' do
        expect_offense(<<~RUBY)
          array1&.none? { |e| array2.member?(e) }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `!array1&.intersect?(array2)` instead of `array1&.none? { |e| array2.member?(e) }`.
        RUBY

        expect_correction(<<~RUBY)
          !array1&.intersect?(array2)
        RUBY
      end

      it 'registers an offense when using `array1.none? { array2.member?(_1) }`' do
        expect_offense(<<~RUBY)
          array1.none? { array2.member?(_1) }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `!array1.intersect?(array2)` instead of `array1.none? { array2.member?(_1) }`.
        RUBY

        expect_correction(<<~RUBY)
          !array1.intersect?(array2)
        RUBY
      end

      context '>= Ruby 3.4', :ruby34 do
        it 'registers an offense when using `array1.none? { array2.member?(it) }`' do
          expect_offense(<<~RUBY)
            array1.none? { array2.member?(it) }
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `!array1.intersect?(array2)` instead of `array1.none? { array2.member?(it) }`.
          RUBY

          expect_correction(<<~RUBY)
            !array1.intersect?(array2)
          RUBY
        end
      end

      context '<= Ruby 3.3', :ruby33 do
        it 'does not register an offense when using `array1.none? { array2.member?(it) }`' do
          expect_no_offenses(<<~RUBY)
            array1.none? { array2.member?(it) }
          RUBY
        end
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
