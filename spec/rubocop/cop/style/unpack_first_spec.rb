# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::UnpackFirst, :config do
  context 'ruby version >= 2.4', :ruby24 do
    context 'registers offense' do
      it 'when using `#unpack` with `#first`' do
        expect_offense(<<~RUBY)
          x.unpack('h*').first
          ^^^^^^^^^^^^^^^^^^^^ Use `x.unpack1('h*')` instead of `x.unpack('h*').first`.
        RUBY

        expect_correction(<<~RUBY)
          x.unpack1('h*')
        RUBY
      end

      it 'when using `#unpack` with square brackets' do
        expect_offense(<<~RUBY)
          ''.unpack(y)[0]
          ^^^^^^^^^^^^^^^ Use `''.unpack1(y)` instead of `''.unpack(y)[0]`.
        RUBY

        expect_correction(<<~RUBY)
          ''.unpack1(y)
        RUBY
      end

      it 'when using `#unpack` with dot and square brackets' do
        expect_offense(<<~RUBY)
          ''.unpack(y).[](0)
          ^^^^^^^^^^^^^^^^^^ Use `''.unpack1(y)` instead of `''.unpack(y).[](0)`.
        RUBY

        expect_correction(<<~RUBY)
          ''.unpack1(y)
        RUBY
      end

      it 'when using `#unpack` with `#slice`' do
        expect_offense(<<~RUBY)
          ''.unpack(y).slice(0)
          ^^^^^^^^^^^^^^^^^^^^^ Use `''.unpack1(y)` instead of `''.unpack(y).slice(0)`.
        RUBY

        expect_correction(<<~RUBY)
          ''.unpack1(y)
        RUBY
      end

      it 'when using `#unpack` with `#at`' do
        expect_offense(<<~RUBY)
          ''.unpack(y).at(0)
          ^^^^^^^^^^^^^^^^^^ Use `''.unpack1(y)` instead of `''.unpack(y).at(0)`.
        RUBY

        expect_correction(<<~RUBY)
          ''.unpack1(y)
        RUBY
      end
    end

    context 'does not register offense' do
      it 'when using `#unpack1`' do
        expect_no_offenses(<<~RUBY)
          x.unpack1(y)
        RUBY
      end

      it 'when using `#unpack` accessing second element' do
        expect_no_offenses(<<~RUBY)
          ''.unpack('h*')[1]
        RUBY
      end
    end
  end
end
