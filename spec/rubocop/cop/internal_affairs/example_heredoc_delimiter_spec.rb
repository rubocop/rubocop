# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::ExampleHeredocDelimiter, :config do
  context 'when expected heredoc delimiter is used at RuboCop specific expectation' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY_)
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            example_ruby_code
          RUBY
        end
      RUBY_
    end
  end

  context 'when unexpected heredoc delimiter is used at non RuboCop specific expectation' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        expect_foo(<<~CODE)
          example_text
        CODE
      RUBY
    end
  end

  context 'when unexpected heredoc delimiter is used but heredoc body contains an expected delimiter line' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY_)
        it 'does not register an offense' do
          expect_no_offenses(<<~CODE)
            RUBY
          CODE
        end
      RUBY_
    end
  end

  context 'when unexpected heredoc delimiter is used in single-line heredoc' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        it 'does not register an offense' do
          expect_no_offenses(<<~CODE)
                             ^^^^^^^ Use `RUBY` for heredoc delimiter of example Ruby code.
            example_ruby_code
          CODE
        end
      RUBY

      expect_correction(<<~RUBY_)
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            example_ruby_code
          RUBY
        end
      RUBY_
    end
  end

  context 'when unexpected heredoc delimiter is used in multi-line heredoc' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        it 'does not register an offense' do
          expect_no_offenses(<<~CODE)
                             ^^^^^^^ Use `RUBY` for heredoc delimiter of example Ruby code.
            example_ruby_code1
            example_ruby_code2
          CODE
        end
      RUBY

      expect_correction(<<~RUBY_)
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            example_ruby_code1
            example_ruby_code2
          RUBY
        end
      RUBY_
    end
  end
end
