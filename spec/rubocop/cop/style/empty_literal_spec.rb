# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::EmptyLiteral do
  subject(:cop) { described_class.new }

  describe 'Empty Array' do
    it 'registers an offense for Array.new()' do
      expect_offense(<<~RUBY)
        test = Array.new()
               ^^^^^^^^^^^ Use array literal `[]` instead of `Array.new`.
      RUBY
      expect_correction(<<~RUBY)
        test = []
      RUBY
    end

    it 'registers an offense for Array.new' do
      expect_offense(<<~RUBY)
        test = Array.new
               ^^^^^^^^^ Use array literal `[]` instead of `Array.new`.
      RUBY
      expect_correction(<<~RUBY)
        test = []
      RUBY
    end

    it 'registers an offense for ::Array.new' do
      expect_offense(<<~RUBY)
        test = ::Array.new
               ^^^^^^^^^^^ Use array literal `[]` instead of `Array.new`.
      RUBY
      expect_correction(<<~RUBY)
        test = []
      RUBY
    end

    it 'does not register an offense for Array.new(3)' do
      expect_no_offenses('test = Array.new(3)')
    end

    it 'auto-corrects Array.new in block in block' do
      expect_offense(<<~RUBY)
        puts { Array.new }
               ^^^^^^^^^ Use array literal `[]` instead of `Array.new`.
      RUBY
      expect_correction(<<~RUBY)
        puts { [] }
      RUBY
    end

    it 'does not registers an offense Array.new with block' do
      expect_no_offenses('test = Array.new { 1 }')
    end

    it 'does not register an offense for ::Array.new with block' do
      expect_no_offenses('test = ::Array.new { 1 }')
    end

    it 'does not register Array.new with block in other block' do
      expect_no_offenses('puts { Array.new { 1 } }')
    end
  end

  describe 'Empty Hash' do
    it 'registers an offense for Hash.new()' do
      expect_offense(<<~RUBY)
        test = Hash.new()
               ^^^^^^^^^^ Use hash literal `{}` instead of `Hash.new`.
      RUBY
      expect_correction(<<~RUBY)
        test = {}
      RUBY
    end

    it 'registers an offense for Hash.new' do
      expect_offense(<<~RUBY)
        test = Hash.new
               ^^^^^^^^ Use hash literal `{}` instead of `Hash.new`.
      RUBY
      expect_correction(<<~RUBY)
        test = {}
      RUBY
    end

    it 'registers an offense for ::Hash.new' do
      expect_offense(<<~RUBY)
        test = ::Hash.new
               ^^^^^^^^^^ Use hash literal `{}` instead of `Hash.new`.
      RUBY
      expect_correction(<<~RUBY)
        test = {}
      RUBY
    end

    it 'does not register an offense for Hash.new(3)' do
      expect_no_offenses('test = Hash.new(3)')
    end

    it 'does not register an offense for ::Hash.new(3)' do
      expect_no_offenses('test = ::Hash.new(3)')
    end

    it 'does not register an offense for Hash.new { block }' do
      expect_no_offenses('test = Hash.new { block }')
    end

    it 'does not register an offense for ::Hash.new { block }' do
      expect_no_offenses('test = ::Hash.new { block }')
    end

    it 'auto-corrects Hash.new in block ' do
      expect_offense(<<~RUBY)
        puts { Hash.new }
               ^^^^^^^^ Use hash literal `{}` instead of `Hash.new`.
      RUBY
      expect_correction(<<~RUBY)
        puts { {} }
      RUBY
    end

    it 'auto-corrects Hash.new to {} in various contexts' do
      expect_offense(<<~RUBY)
        test = Hash.new
               ^^^^^^^^ Use hash literal `{}` instead of `Hash.new`.
        Hash.new.merge("a" => 3)
        ^^^^^^^^ Use hash literal `{}` instead of `Hash.new`.
        yadayada.map { a }.reduce(Hash.new, :merge)
                                  ^^^^^^^^ Use hash literal `{}` instead of `Hash.new`.
      RUBY
      expect_correction(<<~RUBY)
        test = {}
        {}.merge("a" => 3)
        yadayada.map { a }.reduce({}, :merge)
      RUBY
    end

    it 'auto-correct Hash.new to {} as the only parameter to a method' do
      expect_offense(<<~RUBY)
        yadayada.map { a }.reduce Hash.new
                                  ^^^^^^^^ Use hash literal `{}` instead of `Hash.new`.
      RUBY
      expect_correction(<<~RUBY)
        yadayada.map { a }.reduce({})
      RUBY
    end

    it 'auto-correct Hash.new to {} as the first parameter to a method' do
      expect_offense(<<~RUBY)
        yadayada.map { a }.reduce Hash.new, :merge
                                  ^^^^^^^^ Use hash literal `{}` instead of `Hash.new`.
      RUBY
      expect_correction(<<~RUBY)
        yadayada.map { a }.reduce({}, :merge)
      RUBY
    end

    it 'auto-correct changes Hash.new to {} and wraps it in parentheses ' \
      'when it is the only argument to super' do
      expect_offense(<<~RUBY)
        def foo
          super Hash.new
                ^^^^^^^^ Use hash literal `{}` instead of `Hash.new`.
        end
      RUBY
      expect_correction(<<~RUBY)
        def foo
          super({})
        end
      RUBY
    end

    it 'auto-correct changes Hash.new to {} and wraps all arguments in ' \
      'parentheses when it is the first argument to super' do
      expect_offense(<<~RUBY)
        def foo
          super Hash.new, something
                ^^^^^^^^ Use hash literal `{}` instead of `Hash.new`.
        end
      RUBY
      expect_correction(<<~RUBY)
        def foo
          super({}, something)
        end
      RUBY
    end
  end

  describe 'Empty String' do
    it 'registers an offense for String.new()' do
      expect_offense(<<~RUBY)
        test = String.new()
               ^^^^^^^^^^^^ Use string literal `''` instead of `String.new`.
      RUBY
      expect_correction(<<~RUBY)
        test = ''
      RUBY
    end

    it 'registers an offense for String.new' do
      expect_offense(<<~RUBY)
        test = String.new
               ^^^^^^^^^^ Use string literal `''` instead of `String.new`.
      RUBY
      expect_correction(<<~RUBY)
        test = ''
      RUBY
    end

    it 'registers an offense for ::String.new' do
      expect_offense(<<~RUBY)
        test = ::String.new
               ^^^^^^^^^^^^ Use string literal `''` instead of `String.new`.
      RUBY
      expect_correction(<<~RUBY)
        test = ''
      RUBY
    end

    it 'does not register an offense for String.new("top")' do
      expect_no_offenses('test = String.new("top")')
    end

    it 'does not register an offense for ::String.new("top")' do
      expect_no_offenses('test = ::String.new("top")')
    end

    context 'when double-quoted string literals are preferred' do
      subject(:cop) { described_class.new(config) }

      let(:config) do
        RuboCop::Config.new(
          'Style/StringLiterals' =>
            {
              'EnforcedStyle' => 'double_quotes'
            }
        )
      end

      it 'registers an offense for String.new' do
        expect_offense(<<~RUBY)
          test = String.new
                 ^^^^^^^^^^ Use string literal `""` instead of `String.new`.
        RUBY
        expect_correction(<<~RUBY)
          test = ""
        RUBY
      end

      it 'registers an offense for ::String.new' do
        expect_offense(<<~RUBY)
          test = ::String.new
                 ^^^^^^^^^^^^ Use string literal `""` instead of `String.new`.
        RUBY
        expect_correction(<<~RUBY)
          test = ""
        RUBY
      end
    end

    context 'when frozen string literals is enabled' do
      it 'does not register an offense for String.new' do
        expect_no_offenses(<<~RUBY)
          # frozen_string_literal: true
          test = String.new
        RUBY
      end
    end
  end
end
