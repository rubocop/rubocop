# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::TripleQuotes, :config do
  context 'triple quotes' do
    context 'on one line' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          """a string"""
          ^^^^^^^^^^^^^^ Delimiting a string with multiple quotes has no effect, use a single quote instead.
        RUBY

        expect_correction(<<~RUBY)
          "a string"
        RUBY
      end
    end

    context 'on multiple lines' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          """
          ^^^ Delimiting a string with multiple quotes has no effect, use a single quote instead.
            a string
          """
        RUBY

        expect_correction(<<~RUBY)
          "
            a string
          "
        RUBY
      end
    end

    context 'when only quotes' do
      it 'registers an offense and corrects to a single empty quote' do
        expect_offense(<<~RUBY)
          """"""
          ^^^^^^ Delimiting a string with multiple quotes has no effect, use a single quote instead.
        RUBY

        expect_correction(<<~RUBY)
          ""
        RUBY
      end
    end

    context 'with only whitespace' do
      it 'does not register' do
        expect_no_offenses(<<~RUBY)
          " " " " " "
        RUBY
      end
    end
  end

  context 'quintuple quotes' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        """""
        ^^^^^ Delimiting a string with multiple quotes has no effect, use a single quote instead.
          a string
        """""
      RUBY

      expect_correction(<<~RUBY)
        "
          a string
        "
      RUBY
    end
  end

  context 'string interpolation' do
    it 'does not register an offense' do
      expect_no_offenses(<<~'RUBY')
        str = "#{abc}"
      RUBY
    end

    context 'with nested extra quotes' do
      it 'registers an offense and corrects' do
        expect_offense(<<~'RUBY')
          str = "#{'''abc'''}"
                   ^^^^^^^^^ Delimiting a string with multiple quotes has no effect, use a single quote instead.
        RUBY

        expect_correction(<<~'RUBY')
          str = "#{'abc'}"
        RUBY
      end
    end
  end

  context 'heredocs' do
    it 'does not register an offense' do
      expect_no_offenses(<<~'RUBY')
        str = <<~STRING
          a string
          #{interpolation}
        STRING
      RUBY
    end
  end

  it 'does not register an offense for implicit concatenation' do
    expect_no_offenses(<<~RUBY)
      '' ''
      'a''b''c'
      'a''''b'
    RUBY
  end
end
