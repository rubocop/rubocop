# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::CollectionMethods, :config do
  cop_config = {
    'PreferredMethods' => {
      'collect' => 'map',
      'inject' => 'reduce',
      'detect' => 'find',
      'find_all' => 'select',
      'member?' => 'include?'
    }
  }

  let(:cop_config) { cop_config }

  cop_config['PreferredMethods'].each do |method, preferred_method|
    context "#{method} with block" do
      it 'registers an offense' do
        expect_offense(<<~RUBY, method: method)
          [1, 2, 3].%{method} { |e| e + 1 }
                    ^{method} Prefer `#{preferred_method}` over `#{method}`.
        RUBY

        expect_correction(<<~RUBY)
          [1, 2, 3].#{preferred_method} { |e| e + 1 }
        RUBY
      end

      context 'safe navigation' do
        it 'registers an offense' do
          expect_offense(<<~RUBY, method: method)
            [1, 2, 3]&.%{method} { |e| e + 1 }
                       ^{method} Prefer `#{preferred_method}` over `#{method}`.
          RUBY

          expect_correction(<<~RUBY)
            [1, 2, 3]&.#{preferred_method} { |e| e + 1 }
          RUBY
        end
      end
    end

    context 'Ruby 2.7', :ruby27 do
      context "#{method} with numblock" do
        it 'registers an offense' do
          expect_offense(<<~RUBY, method: method)
            [1, 2, 3].%{method} { _1 + 1 }
                      ^{method} Prefer `#{preferred_method}` over `#{method}`.
          RUBY

          expect_correction(<<~RUBY)
            [1, 2, 3].#{preferred_method} { _1 + 1 }
          RUBY
        end

        context 'with safe navigation' do
          it 'registers an offense' do
            expect_offense(<<~RUBY, method: method)
              [1, 2, 3]&.%{method} { _1 + 1 }
                         ^{method} Prefer `#{preferred_method}` over `#{method}`.
            RUBY

            expect_correction(<<~RUBY)
              [1, 2, 3]&.#{preferred_method} { _1 + 1 }
            RUBY
          end
        end
      end
    end

    context 'Ruby 3.4', :ruby34 do
      context "#{method} with itblock" do
        it 'registers an offense' do
          expect_offense(<<~RUBY, method: method)
            [1, 2, 3].%{method} { it + 1 }
                      ^{method} Prefer `#{preferred_method}` over `#{method}`.
          RUBY

          expect_correction(<<~RUBY)
            [1, 2, 3].#{preferred_method} { it + 1 }
          RUBY
        end

        context 'with safe navigation' do
          it 'registers an offense' do
            expect_offense(<<~RUBY, method: method)
              [1, 2, 3]&.%{method} { it + 1 }
                         ^{method} Prefer `#{preferred_method}` over `#{method}`.
            RUBY

            expect_correction(<<~RUBY)
              [1, 2, 3]&.#{preferred_method} { it + 1 }
            RUBY
          end
        end
      end
    end

    context "#{method} with proc param" do
      it 'registers an offense' do
        expect_offense(<<~RUBY, method: method)
          [1, 2, 3].%{method}(&:test)
                    ^{method} Prefer `#{preferred_method}` over `#{method}`.
        RUBY

        expect_correction(<<~RUBY)
          [1, 2, 3].#{preferred_method}(&:test)
        RUBY
      end

      context 'safe navigation' do
        it 'registers an offense' do
          expect_offense(<<~RUBY, method: method)
            [1, 2, 3]&.%{method}(&:test)
                       ^{method} Prefer `#{preferred_method}` over `#{method}`.
          RUBY

          expect_correction(<<~RUBY)
            [1, 2, 3]&.#{preferred_method}(&:test)
          RUBY
        end
      end
    end

    context "#{method} with an argument and proc param" do
      it 'registers an offense' do
        expect_offense(<<~RUBY, method: method)
          [1, 2, 3].%{method}(0, &:test)
                    ^{method} Prefer `#{preferred_method}` over `#{method}`.
        RUBY

        expect_correction(<<~RUBY)
          [1, 2, 3].#{preferred_method}(0, &:test)
        RUBY
      end

      context 'with safe navigation' do
        it 'registers an offense' do
          expect_offense(<<~RUBY, method: method)
            [1, 2, 3]&.%{method}(0, &:test)
                       ^{method} Prefer `#{preferred_method}` over `#{method}`.
          RUBY

          expect_correction(<<~RUBY)
            [1, 2, 3]&.#{preferred_method}(0, &:test)
          RUBY
        end
      end
    end

    context "#{method} without a block" do
      it "accepts #{method} without a block" do
        expect_no_offenses(<<~RUBY)
          [1, 2, 3].#{method}
        RUBY
      end

      context 'with safe navigation' do
        it "accepts #{method} without a block" do
          expect_no_offenses(<<~RUBY)
            [1, 2, 3]&.#{method}
          RUBY
        end
      end
    end
  end

  context 'for methods that accept a symbol as implicit block' do
    context 'with a final symbol param' do
      it 'registers an offense with a final symbol param' do
        expect_offense(<<~RUBY)
          [1, 2, 3].inject(:+)
                    ^^^^^^ Prefer `reduce` over `inject`.
        RUBY

        expect_correction(<<~RUBY)
          [1, 2, 3].reduce(:+)
        RUBY
      end

      context 'with safe navigation' do
        it 'registers an offense with a final symbol param' do
          expect_offense(<<~RUBY)
            [1, 2, 3]&.inject(:+)
                       ^^^^^^ Prefer `reduce` over `inject`.
          RUBY

          expect_correction(<<~RUBY)
            [1, 2, 3]&.reduce(:+)
          RUBY
        end
      end
    end

    context 'with an argument and final symbol param' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          [1, 2, 3].inject(0, :+)
                    ^^^^^^ Prefer `reduce` over `inject`.
        RUBY

        expect_correction(<<~RUBY)
          [1, 2, 3].reduce(0, :+)
        RUBY
      end

      context 'with safe navigation' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            [1, 2, 3]&.inject(0, :+)
                       ^^^^^^ Prefer `reduce` over `inject`.
          RUBY

          expect_correction(<<~RUBY)
            [1, 2, 3]&.reduce(0, :+)
          RUBY
        end
      end
    end
  end

  context 'for methods that do not accept a symbol as implicit block' do
    context 'for a final symbol param' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          [1, 2, 3].collect(:+)
        RUBY
      end

      context 'with safe navigation' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            [1, 2, 3]&.collect(:+)
          RUBY
        end
      end
    end

    context 'for a final symbol param with extra args' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          [1, 2, 3].collect(0, :+)
        RUBY
      end

      context 'with safe navigation' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            [1, 2, 3]&.collect(0, :+)
          RUBY
        end
      end
    end
  end
end
