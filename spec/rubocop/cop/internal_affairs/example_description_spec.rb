# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::ExampleDescription, :config do
  context 'with `expect_offense`' do
    it 'registers an offense when given an improper description' do
      expect_offense(<<~RUBY)
        it 'does not register an offense' do
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Description does not match use of `expect_offense`.
          expect_offense('code')
        end
      RUBY

      expect_correction(<<~RUBY)
        it 'registers an offense' do
          expect_offense('code')
        end
      RUBY
    end

    it 'registers an offense when given an improper description for `registers no offense`' do
      expect_offense(<<~RUBY)
        it 'registers no offense' do
           ^^^^^^^^^^^^^^^^^^^^^^ Description does not match use of `expect_offense`.
          expect_offense('code')
        end
      RUBY

      expect_correction(<<~RUBY)
        it 'registers an offense' do
          expect_offense('code')
        end
      RUBY
    end

    it 'registers an offense when given an improper description with single option' do
      expect_offense(<<~RUBY)
        it 'does not register an offense', :ruby30 do
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Description does not match use of `expect_offense`.
          expect_offense('code')
        end
      RUBY

      expect_correction(<<~RUBY)
        it 'registers an offense', :ruby30 do
          expect_offense('code')
        end
      RUBY
    end

    it 'registers an offense when given an improper description with multiple options' do
      expect_offense(<<~RUBY)
        it 'does not register an offense', :ruby30, :rails70 do
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Description does not match use of `expect_offense`.
          expect_offense('code')
        end
      RUBY

      expect_correction(<<~RUBY)
        it 'registers an offense', :ruby30, :rails70 do
          expect_offense('code')
        end
      RUBY
    end

    it 'registers an offense when given an improper description for `accepts`' do
      expect_offense(<<~RUBY)
        it 'accepts the case' do
           ^^^^^^^^^^^^^^^^^^ Description does not match use of `expect_offense`.
          expect_offense('code')
        end
      RUBY

      expect_correction(<<~RUBY)
        it 'registers the case' do
          expect_offense('code')
        end
      RUBY
    end

    it 'registers an offense when given an improper description for `register`' do
      expect_offense(<<~RUBY)
        it 'register the case' do
           ^^^^^^^^^^^^^^^^^^^ Description does not match use of `expect_offense`.
          expect_offense('code')
        end
      RUBY

      expect_correction(<<~RUBY)
        it 'registers the case' do
          expect_offense('code')
        end
      RUBY
    end

    it 'does not register an offense when given a proper description' do
      expect_no_offenses(<<~RUBY)
        it 'finds an offense' do
          expect_offense('code')
        end
      RUBY
    end

    it 'does not register an offense when given an unexpected description' do
      expect_no_offenses(<<~RUBY)
        it 'foo bar baz' do
          expect_offense('code')
        end
      RUBY
    end
  end

  context 'with `expect_no_offenses`' do
    it 'registers an offense when given an improper description for `registers`' do
      expect_offense(<<~RUBY)
        it 'registers an offense' do
           ^^^^^^^^^^^^^^^^^^^^^^ Description does not match use of `expect_no_offenses`.
          expect_no_offenses('code')
        end
      RUBY

      expect_correction(<<~RUBY)
        it 'does not register an offense' do
          expect_no_offenses('code')
        end
      RUBY
    end

    it 'registers an offense when given an improper description for `handles`' do
      expect_offense(<<~RUBY)
        it 'handles the case' do
           ^^^^^^^^^^^^^^^^^^ Description does not match use of `expect_no_offenses`.
          expect_no_offenses('code')
        end
      RUBY

      expect_correction(<<~RUBY)
        it 'does not register the case' do
          expect_no_offenses('code')
        end
      RUBY
    end

    it 'does not register an offense when given a proper description' do
      expect_no_offenses(<<~RUBY)
        it 'does not flag' do
          expect_no_offense('code')
        end
      RUBY
    end

    it 'does not crash when given a proper description that is split with +' do
      expect_no_offenses(<<~RUBY)
        it "does " + 'not register an offense' do
          expect_no_offense('code')
        end
      RUBY
    end

    it 'does not register an offense when given an unexpected description' do
      expect_no_offenses(<<~RUBY)
        it 'foo bar baz' do
          expect_offense('code')
        end
      RUBY
    end
  end

  context 'with `expect_correction`' do
    it 'registers an offense when given an improper description' do
      expect_offense(<<~RUBY)
        it 'does not autocorrect' do
           ^^^^^^^^^^^^^^^^^^^^^^ Description does not match use of `expect_correction`.
          expect_correction('code', source: 'new code')
        end
      RUBY
    end

    context 'in conjunction with expect_offense' do
      it 'registers an offense when given an improper description' do
        expect_offense(<<~RUBY)
          it 'registers an offense but does not autocorrect' do
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Description does not match use of `expect_correction`.
            expect_offense('code')
            expect_correction('code')
          end
        RUBY
      end

      context 'when the description is invalid for both methods' do
        it 'registers an offense for the first method encountered' do
          expect_offense(<<~RUBY)
            it 'does not register an offense and does not autocorrect' do
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Description does not match use of `expect_offense`.
              expect_offense('code')
              expect_correction('code')
            end
          RUBY
        end
      end
    end
  end

  context 'with `expect_no_corrections`' do
    it 'registers an offense when given an improper description' do
      expect_offense(<<~RUBY)
        it 'autocorrects' do
           ^^^^^^^^^^^^^^ Description does not match use of `expect_no_corrections`.
          expect_no_corrections
        end
      RUBY
    end

    context 'in conjunction with expect_offense' do
      it 'registers an offense when given an improper description' do
        expect_offense(<<~RUBY)
          it 'autocorrects' do
             ^^^^^^^^^^^^^^ Description does not match use of `expect_no_corrections`.
            expect_offense('code')
            expect_no_corrections
          end
        RUBY
      end
    end
  end

  context 'when not making an expectation on offenses' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        it 'registers an offense' do
        end
      RUBY
    end
  end

  context 'when given a proper description in `aggregate_failures` block' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        it 'does not register an offense' do
          aggregate_failures do
            expect_no_offenses(code)
          end
        end
      RUBY
    end
  end
end
