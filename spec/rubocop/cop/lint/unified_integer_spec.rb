# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::UnifiedInteger, :config do
  shared_examples 'registers an offense' do |klass|
    context 'target ruby version < 2.4', :ruby23 do
      context "when #{klass}" do
        context 'without any decorations' do
          it 'registers an offense and autocorrects' do
            expect_offense(<<~RUBY, klass: klass)
              1.is_a?(%{klass})
                      ^{klass} Use `Integer` instead of `#{klass}`.
            RUBY

            expect_no_corrections
          end
        end

        context 'when explicitly specified as toplevel constant' do
          it 'registers an offense' do
            expect_offense(<<~RUBY, klass: klass)
              1.is_a?(::%{klass})
                      ^^^{klass} Use `Integer` instead of `#{klass}`.
            RUBY

            expect_no_corrections
          end
        end

        context 'with MyNamespace' do
          it 'does not register an offense' do
            expect_no_offenses("1.is_a?(MyNamespace::#{klass})")
          end
        end
      end
    end

    context 'target ruby version >= 2.4', :ruby24 do
      context "when #{klass}" do
        context 'without any decorations' do
          it 'registers an offense' do
            expect_offense(<<~RUBY, klass: klass)
              1.is_a?(#{klass})
                      ^{klass} Use `Integer` instead of `#{klass}`.
            RUBY

            expect_correction(<<~RUBY)
              1.is_a?(Integer)
            RUBY
          end
        end

        context 'when explicitly specified as toplevel constant' do
          it 'registers an offense' do
            expect_offense(<<~RUBY, klass: klass)
              1.is_a?(::#{klass})
                      ^^^{klass} Use `Integer` instead of `#{klass}`.
            RUBY

            expect_correction(<<~RUBY)
              1.is_a?(::Integer)
            RUBY
          end
        end

        context 'with MyNamespace' do
          it 'does not register an offense' do
            expect_no_offenses("1.is_a?(MyNamespace::#{klass})")
          end
        end
      end
    end
  end

  include_examples 'registers an offense', 'Fixnum'
  include_examples 'registers an offense', 'Bignum'

  context 'when Integer' do
    context 'without any decorations' do
      it 'does not register an offense' do
        expect_no_offenses('1.is_a?(Integer)')
      end
    end

    context 'when explicitly specified as toplevel constant' do
      it 'does not register an offense' do
        expect_no_offenses('1.is_a?(::Integer)')
      end
    end

    context 'with MyNamespace' do
      it 'does not register an offense' do
        expect_no_offenses('1.is_a?(MyNamespace::Integer)')
      end
    end
  end
end
