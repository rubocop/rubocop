# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::TallyMethod, :config do
  context 'when targeting Ruby 2.7+', :ruby27 do
    context 'with `each_with_object(Hash.new(0))` pattern' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          array.each_with_object(Hash.new(0)) { |item, counts| counts[item] += 1 }
                ^^^^^^^^^^^^^^^^ Use `tally` instead of `each_with_object`.
        RUBY

        expect_correction(<<~RUBY)
          array.tally
        RUBY
      end

      it 'registers an offense and corrects with safe navigation' do
        expect_offense(<<~RUBY)
          array&.each_with_object(Hash.new(0)) { |item, counts| counts[item] += 1 }
                 ^^^^^^^^^^^^^^^^ Use `tally` instead of `each_with_object`.
        RUBY

        expect_correction(<<~RUBY)
          array&.tally
        RUBY
      end

      it 'registers an offense and corrects with do...end block' do
        expect_offense(<<~RUBY)
          array.each_with_object(Hash.new(0)) do |item, counts|
                ^^^^^^^^^^^^^^^^ Use `tally` instead of `each_with_object`.
            counts[item] += 1
          end
        RUBY

        expect_correction(<<~RUBY)
          array.tally
        RUBY
      end

      it 'registers an offense and corrects without receiver' do
        expect_offense(<<~RUBY)
          each_with_object(Hash.new(0)) { |item, counts| counts[item] += 1 }
          ^^^^^^^^^^^^^^^^ Use `tally` instead of `each_with_object`.
        RUBY

        expect_correction(<<~RUBY)
          tally
        RUBY
      end

      it 'registers an offense and corrects with ::Hash' do
        expect_offense(<<~RUBY)
          array.each_with_object(::Hash.new(0)) { |x, h| h[x] += 1 }
                ^^^^^^^^^^^^^^^^ Use `tally` instead of `each_with_object`.
        RUBY

        expect_correction(<<~RUBY)
          array.tally
        RUBY
      end

      it 'registers an offense and corrects with numbered parameters' do
        expect_offense(<<~RUBY)
          array.each_with_object(Hash.new(0)) { _2[_1] += 1 }
                ^^^^^^^^^^^^^^^^ Use `tally` instead of `each_with_object`.
        RUBY

        expect_correction(<<~RUBY)
          array.tally
        RUBY
      end

      it 'does not register an offense when incrementing by a value other than 1' do
        expect_no_offenses(<<~RUBY)
          array.each_with_object(Hash.new(0)) { |item, counts| counts[item] += 2 }
        RUBY
      end

      it 'does not register an offense when keying by a transformation' do
        expect_no_offenses(<<~RUBY)
          array.each_with_object(Hash.new(0)) { |item, counts| counts[item.to_s] += 1 }
        RUBY
      end

      it 'does not register an offense with a different initial value' do
        expect_no_offenses(<<~RUBY)
          array.each_with_object({}) { |item, counts| counts[item] = true }
        RUBY
      end

      it 'does not register an offense when the block body has extra logic' do
        expect_no_offenses(<<~RUBY)
          array.each_with_object(Hash.new(0)) do |item, counts|
            counts[item] += 1
            puts item
          end
        RUBY
      end

      it 'does not register an offense when keying by a transformation with numbered parameters' do
        expect_no_offenses(<<~RUBY)
          array.each_with_object(Hash.new(0)) { _2[_1.to_s] += 1 }
        RUBY
      end
    end

    context 'with `group_by(&:itself).transform_values(&:count)` pattern' do
      %i[count size length].each do |method|
        it "registers an offense and corrects with `&:#{method}`" do
          expect_offense(<<~RUBY, method: method)
            array.group_by(&:itself).transform_values(&:#{method})
                  ^^^^^^^^ Use `tally` instead of `group_by` and `transform_values`.
          RUBY

          expect_correction(<<~RUBY)
            array.tally
          RUBY
        end
      end

      it 'registers an offense and corrects with safe navigation' do
        expect_offense(<<~RUBY)
          array&.group_by(&:itself)&.transform_values(&:count)
                 ^^^^^^^^ Use `tally` instead of `group_by` and `transform_values`.
        RUBY

        expect_correction(<<~RUBY)
          array&.tally
        RUBY
      end

      it 'registers an offense and corrects without receiver' do
        expect_offense(<<~RUBY)
          group_by(&:itself).transform_values(&:count)
          ^^^^^^^^ Use `tally` instead of `group_by` and `transform_values`.
        RUBY

        expect_correction(<<~RUBY)
          tally
        RUBY
      end

      it 'does not register an offense when group_by uses a different key' do
        expect_no_offenses(<<~RUBY)
          array.group_by(&:name).transform_values(&:count)
        RUBY
      end

      it 'does not register an offense when transform_values uses a different method' do
        expect_no_offenses(<<~RUBY)
          array.group_by(&:itself).transform_values(&:sum)
        RUBY
      end
    end

    context 'with `group_by { |x| x }.transform_values(&:count)` pattern' do
      it 'registers an offense and corrects with identity block' do
        expect_offense(<<~RUBY)
          array.group_by { |x| x }.transform_values(&:count)
                ^^^^^^^^ Use `tally` instead of `group_by` and `transform_values`.
        RUBY

        expect_correction(<<~RUBY)
          array.tally
        RUBY
      end

      it 'registers an offense and corrects with identity numblock' do
        expect_offense(<<~RUBY)
          array.group_by { _1 }.transform_values(&:count)
                ^^^^^^^^ Use `tally` instead of `group_by` and `transform_values`.
        RUBY

        expect_correction(<<~RUBY)
          array.tally
        RUBY
      end

      context 'Ruby >= 3.4', :ruby34 do
        it 'registers an offense and corrects with identity itblock' do
          expect_offense(<<~RUBY)
            array.group_by { it }.transform_values(&:count)
                  ^^^^^^^^ Use `tally` instead of `group_by` and `transform_values`.
          RUBY

          expect_correction(<<~RUBY)
            array.tally
          RUBY
        end
      end

      it 'does not register an offense when group_by block transforms the element' do
        expect_no_offenses(<<~RUBY)
          array.group_by { |x| x.name }.transform_values(&:count)
        RUBY
      end
    end

    context 'with `group_by { |x| x }.transform_values { |v| v.count }` pattern' do
      %i[count size length].each do |method|
        it "registers an offense and corrects with `#{method}`" do
          expect_offense(<<~RUBY, method: method)
            array.group_by { |x| x }.transform_values { |v| v.#{method} }
                  ^^^^^^^^ Use `tally` instead of `group_by` and `transform_values`.
          RUBY

          expect_correction(<<~RUBY)
            array.tally
          RUBY
        end
      end

      it 'registers an offense and corrects with group_by(&:itself) and transform_values block' do
        expect_offense(<<~RUBY)
          array.group_by(&:itself).transform_values { |v| v.count }
                ^^^^^^^^ Use `tally` instead of `group_by` and `transform_values`.
        RUBY

        expect_correction(<<~RUBY)
          array.tally
        RUBY
      end

      it 'registers an offense and corrects with transform_values numblock' do
        expect_offense(<<~RUBY)
          array.group_by(&:itself).transform_values { _1.count }
                ^^^^^^^^ Use `tally` instead of `group_by` and `transform_values`.
        RUBY

        expect_correction(<<~RUBY)
          array.tally
        RUBY
      end

      context 'Ruby >= 3.4', :ruby34 do
        it 'registers an offense and corrects with transform_values itblock' do
          expect_offense(<<~RUBY)
            array.group_by(&:itself).transform_values { it.count }
                  ^^^^^^^^ Use `tally` instead of `group_by` and `transform_values`.
          RUBY

          expect_correction(<<~RUBY)
            array.tally
          RUBY
        end
      end

      it 'does not register an offense when transform_values block does something else' do
        expect_no_offenses(<<~RUBY)
          array.group_by { |x| x }.transform_values { |v| v.sum }
        RUBY
      end

      it 'does not register an offense when transform_values block has complex logic' do
        expect_no_offenses(<<~RUBY)
          array.group_by { |x| x }.transform_values { |v| v.count * 2 }
        RUBY
      end
    end
  end

  context 'when targeting Ruby 2.6', :ruby26, unsupported_on: :prism do
    it 'does not register an offense for each_with_object tally pattern' do
      expect_no_offenses(<<~RUBY)
        array.each_with_object(Hash.new(0)) { |item, counts| counts[item] += 1 }
      RUBY
    end

    it 'does not register an offense for group_by.transform_values tally pattern' do
      expect_no_offenses(<<~RUBY)
        array.group_by(&:itself).transform_values(&:count)
      RUBY
    end
  end
end
