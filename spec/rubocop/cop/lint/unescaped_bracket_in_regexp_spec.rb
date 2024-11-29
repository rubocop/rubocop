# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::UnescapedBracketInRegexp, :config do
  around { |example| RuboCop::Util.silence_warnings(&example) }

  context 'literal Regexp' do
    context 'when unescaped bracket is the first character' do
      it 'does not register an offense' do
        # this does not register a Ruby warning
        expect_no_offenses(<<~RUBY)
          /]/
        RUBY
      end
    end

    context 'unescaped bracket in regexp' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          /abc]123/
              ^ Regular expression has `]` without escape.
        RUBY

        expect_correction(<<~'RUBY')
          /abc\]123/
        RUBY
      end
    end

    context 'unescaped bracket in regexp with regexp options' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          /abc]123/i
              ^ Regular expression has `]` without escape.
        RUBY

        expect_correction(<<~'RUBY')
          /abc\]123/i
        RUBY
      end
    end

    context 'multiple unescaped brackets in regexp' do
      it 'registers an offense for each bracket' do
        expect_offense(<<~RUBY)
          /abc]123]/
              ^ Regular expression has `]` without escape.
                  ^ Regular expression has `]` without escape.
        RUBY

        expect_correction(<<~'RUBY')
          /abc\]123\]/
        RUBY
      end
    end

    context 'escaped bracket in regexp' do
      it 'does not register an offense' do
        expect_no_offenses(<<~'RUBY')
          /abc\]123/
        RUBY
      end
    end

    context 'character class' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          /[abc]/
        RUBY
      end
    end

    context 'character class in lookbehind' do
      # See https://github.com/ammar/regexp_parser/issues/93
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          /(?<=[<>=:])/
        RUBY
      end
    end
  end

  context '%r{} Regexp' do
    context 'when unescaped bracket is the first character' do
      it 'does not register an offense' do
        # this does not register a Ruby warning
        expect_no_offenses(<<~RUBY)
          %r{]}
        RUBY
      end
    end

    context 'unescaped bracket in regexp' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          %r{abc]123}
                ^ Regular expression has `]` without escape.
        RUBY

        expect_correction(<<~'RUBY')
          %r{abc\]123}
        RUBY
      end
    end

    context 'unescaped bracket in regexp with regexp options' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          %r{abc]123}i
                ^ Regular expression has `]` without escape.
        RUBY

        expect_correction(<<~'RUBY')
          %r{abc\]123}i
        RUBY
      end
    end

    context 'multiple unescaped brackets in regexp' do
      it 'registers an offense for each bracket' do
        expect_offense(<<~RUBY)
          %r{abc]123]}
                ^ Regular expression has `]` without escape.
                    ^ Regular expression has `]` without escape.
        RUBY

        expect_correction(<<~'RUBY')
          %r{abc\]123\]}
        RUBY
      end
    end

    context 'escaped bracket in regexp' do
      it 'does not register an offense' do
        expect_no_offenses(<<~'RUBY')
          %r{abc\]123}
        RUBY
      end
    end

    context 'character class' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          %r{[abc]}
        RUBY
      end
    end

    context 'character class in lookbehind' do
      # See https://github.com/ammar/regexp_parser/issues/93
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          %r{(?<=[<>=:])}
        RUBY
      end
    end
  end

  %i[new compile].each do |method|
    context "Regexp.#{method}" do
      context 'when unescaped bracket is the first character' do
        it 'does not register an offense' do
          # this does not register a Ruby warning
          expect_no_offenses(<<~RUBY)
            Regexp.#{method}(']')
          RUBY
        end
      end

      context 'unescaped bracket in regexp' do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY, method: method)
            Regexp.#{method}('abc]123')
                   _{method}     ^ Regular expression has `]` without escape.
          RUBY

          expect_correction(<<~RUBY)
            Regexp.#{method}('abc\\]123')
          RUBY
        end
      end

      context 'unescaped bracket in regexp with regexp options' do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY, method: method)
            Regexp.#{method}('abc]123', 'i')
                   _{method}     ^ Regular expression has `]` without escape.
          RUBY

          expect_correction(<<~RUBY)
            Regexp.#{method}('abc\\]123', 'i')
          RUBY
        end
      end

      context 'multiple unescaped brackets in regexp' do
        it 'registers an offense for each bracket' do
          expect_offense(<<~RUBY, method: method)
            Regexp.#{method}('abc]123]')
                   _{method}     ^ Regular expression has `]` without escape.
                   _{method}         ^ Regular expression has `]` without escape.
          RUBY

          expect_correction(<<~RUBY)
            Regexp.#{method}('abc\\]123\\]')
          RUBY
        end
      end

      context 'escaped bracket in regexp' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            Regexp.#{method}('abc\\]123')
          RUBY
        end
      end

      context 'character class' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            Regexp.#{method}('[abc]')
          RUBY
        end
      end

      context 'containing `dstr` node' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            Regexp.#{method}("(?:\#{arr[1]}:\\s*)")
          RUBY
        end
      end
    end
  end
end
