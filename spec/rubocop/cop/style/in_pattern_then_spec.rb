# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::InPatternThen, :config do
  context '>= Ruby 2.7', :ruby27 do
    it 'registers an offense for `in b;`' do
      expect_offense(<<~RUBY)
        case a
        in b; c
            ^ Do not use `in b;`. Use `in b then` instead.
        end
      RUBY

      expect_correction(<<~RUBY)
        case a
        in b then c
        end
      RUBY
    end

    it 'registers an offense for `in b, c, d;` (array pattern)' do
      expect_offense(<<~RUBY)
        case a
        in b, c, d; e
                  ^ Do not use `in b, c, d;`. Use `in b, c, d then` instead.
        end
      RUBY

      expect_correction(<<~RUBY)
        case a
        in b, c, d then e
        end
      RUBY
    end

    it 'registers an offense for `in b | c | d;` (alternative pattern)' do
      expect_offense(<<~RUBY)
        case a
        in b | c | d; e
                    ^ Do not use `in b | c | d;`. Use `in b | c | d then` instead.
        end
      RUBY

      expect_correction(<<~RUBY)
        case a
        in b | c | d then e
        end
      RUBY
    end

    it 'registers an offense for `in b, c | d;`' do
      expect_offense(<<~RUBY)
        case a
        in b, c | d; e
                   ^ Do not use `in b, c | d;`. Use `in b, c | d then` instead.
        end
      RUBY

      expect_correction(<<~RUBY)
        case a
        in b, c | d then e
        end
      RUBY
    end

    it 'accepts `;` separating statements in the body of `in`' do
      expect_no_offenses(<<~RUBY)
        case a
        in b then c; d
        end

        case e
        in f
          g; h
        end
      RUBY
    end

    context 'when inspecting a case statement with an empty branch' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          case condition
          in pattern
          end
        RUBY
      end
    end
  end
end
