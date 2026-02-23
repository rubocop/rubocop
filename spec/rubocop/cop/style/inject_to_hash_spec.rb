# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::InjectToHash, :config do
  context 'when targeting Ruby 2.6+', :ruby26 do
    context 'with `each_with_object({})` pattern' do
      it 'registers an offense and corrects with inline block' do
        expect_offense(<<~RUBY)
          array.each_with_object({}) { |elem, hash| hash[elem.id] = elem.name }
                ^^^^^^^^^^^^^^^^ Use `to_h { ... }` instead of `each_with_object`.
        RUBY

        expect_correction(<<~RUBY)
          array.to_h { |elem| [elem.id, elem.name] }
        RUBY
      end

      it 'registers an offense and corrects with do...end block' do
        expect_offense(<<~RUBY)
          array.each_with_object({}) do |elem, hash|
                ^^^^^^^^^^^^^^^^ Use `to_h { ... }` instead of `each_with_object`.
            hash[elem.id] = elem.name
          end
        RUBY

        expect_correction(<<~RUBY)
          array.to_h do |elem|
            [elem.id, elem.name]
          end
        RUBY
      end

      it 'registers an offense and corrects with safe navigation' do
        expect_offense(<<~RUBY)
          array&.each_with_object({}) { |elem, hash| hash[elem.id] = elem.name }
                 ^^^^^^^^^^^^^^^^ Use `to_h { ... }` instead of `each_with_object`.
        RUBY

        expect_correction(<<~RUBY)
          array&.to_h { |elem| [elem.id, elem.name] }
        RUBY
      end

      it 'registers an offense and corrects without receiver' do
        expect_offense(<<~RUBY)
          each_with_object({}) { |elem, hash| hash[elem] = elem.to_s }
          ^^^^^^^^^^^^^^^^ Use `to_h { ... }` instead of `each_with_object`.
        RUBY

        expect_correction(<<~RUBY)
          to_h { |elem| [elem, elem.to_s] }
        RUBY
      end

      it 'registers an offense and corrects with simple element as key' do
        expect_offense(<<~RUBY)
          array.each_with_object({}) { |x, h| h[x] = true }
                ^^^^^^^^^^^^^^^^ Use `to_h { ... }` instead of `each_with_object`.
        RUBY

        expect_correction(<<~RUBY)
          array.to_h { |x| [x, true] }
        RUBY
      end

      it 'does not register an offense when block body has multiple statements' do
        expect_no_offenses(<<~RUBY)
          array.each_with_object({}) do |elem, hash|
            hash[elem.id] = elem.name
            puts elem
          end
        RUBY
      end

      it 'does not register an offense with destructured block arguments' do
        expect_no_offenses(<<~RUBY)
          hash.each_with_object({}) { |(k, v), h| h[k.to_s] = v }
        RUBY
      end

      it 'does not register an offense when initial value is not an empty hash' do
        expect_no_offenses(<<~RUBY)
          array.each_with_object(Hash.new(0)) { |elem, hash| hash[elem] += 1 }
        RUBY
      end

      it 'does not register an offense when using methods other than []=' do
        expect_no_offenses(<<~RUBY)
          array.each_with_object({}) { |elem, hash| hash.merge!(elem => true) }
        RUBY
      end

      it 'does not register an offense when the hash variable is not the one being assigned to' do
        expect_no_offenses(<<~RUBY)
          array.each_with_object({}) { |elem, hash| other[elem] = true }
        RUBY
      end
    end

    context 'with `inject({})` pattern' do
      it 'registers an offense and corrects with inline block' do
        expect_offense(<<~RUBY)
          array.inject({}) { |hash, elem| hash[elem.id] = elem.name; hash }
                ^^^^^^ Use `to_h { ... }` instead of `inject`.
        RUBY

        expect_correction(<<~RUBY)
          array.to_h { |elem| [elem.id, elem.name] }
        RUBY
      end

      it 'registers an offense and corrects with do...end block' do
        expect_offense(<<~RUBY)
          array.inject({}) do |hash, elem|
                ^^^^^^ Use `to_h { ... }` instead of `inject`.
            hash[elem.id] = elem.name
            hash
          end
        RUBY

        expect_correction(<<~RUBY)
          array.to_h do |elem|
            [elem.id, elem.name]
          end
        RUBY
      end

      it 'registers an offense and corrects with safe navigation' do
        expect_offense(<<~RUBY)
          array&.inject({}) { |hash, elem| hash[elem.id] = elem.name; hash }
                 ^^^^^^ Use `to_h { ... }` instead of `inject`.
        RUBY

        expect_correction(<<~RUBY)
          array&.to_h { |elem| [elem.id, elem.name] }
        RUBY
      end

      it 'does not register an offense when the accumulator is not returned' do
        expect_no_offenses(<<~RUBY)
          array.inject({}) { |hash, elem| hash[elem] = true; other }
        RUBY
      end

      it 'does not register an offense when block body has extra statements' do
        expect_no_offenses(<<~RUBY)
          array.inject({}) do |hash, elem|
            puts elem
            hash[elem] = true
            hash
          end
        RUBY
      end
    end

    context 'with `reduce({})` pattern' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          array.reduce({}) { |hash, elem| hash[elem.id] = elem.name; hash }
                ^^^^^^ Use `to_h { ... }` instead of `reduce`.
        RUBY

        expect_correction(<<~RUBY)
          array.to_h { |elem| [elem.id, elem.name] }
        RUBY
      end
    end

    context 'with numbered parameters', :ruby27 do
      it 'registers an offense and corrects each_with_object with numbered params' do
        expect_offense(<<~RUBY)
          array.each_with_object({}) { _2[_1.id] = _1.name }
                ^^^^^^^^^^^^^^^^ Use `to_h { ... }` instead of `each_with_object`.
        RUBY

        expect_correction(<<~RUBY)
          array.to_h { [_1.id, _1.name] }
        RUBY
      end

      it 'registers an offense and corrects inject with numbered params' do
        expect_offense(<<~RUBY)
          array.inject({}) { _1[_2.id] = _2.name; _1 }
                ^^^^^^ Use `to_h { ... }` instead of `inject`.
        RUBY

        expect_correction(<<~RUBY)
          array.to_h { [_1.id, _1.name] }
        RUBY
      end
    end
  end

  context 'when targeting Ruby 2.5', :ruby25, unsupported_on: :prism do
    it 'does not register an offense for each_with_object pattern' do
      expect_no_offenses(<<~RUBY)
        array.each_with_object({}) { |elem, hash| hash[elem.id] = elem.name }
      RUBY
    end

    it 'does not register an offense for inject pattern' do
      expect_no_offenses(<<~RUBY)
        array.inject({}) { |hash, elem| hash[elem.id] = elem.name; hash }
      RUBY
    end
  end
end
