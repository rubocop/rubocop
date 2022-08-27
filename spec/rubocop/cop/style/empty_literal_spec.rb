# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::EmptyLiteral, :config do
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

    it 'autocorrects Array.new in block in block' do
      expect_offense(<<~RUBY)
        puts { Array.new }
               ^^^^^^^^^ Use array literal `[]` instead of `Array.new`.
      RUBY

      expect_correction(<<~RUBY)
        puts { [] }
      RUBY
    end

    it 'does not register an offense Array.new with block' do
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

    context 'Ruby 2.7', :ruby27 do
      it 'does not register an offense for Hash.new { _1[_2] = [] }' do
        expect_no_offenses('test = Hash.new { _1[_2] = [] }')
      end

      it 'does not register an offense for ::Hash.new { _1[_2] = [] }' do
        expect_no_offenses('test = ::Hash.new { _1[_2] = [] }')
      end
    end

    it 'autocorrects Hash.new in block' do
      expect_offense(<<~RUBY)
        puts { Hash.new }
               ^^^^^^^^ Use hash literal `{}` instead of `Hash.new`.
      RUBY

      expect_correction(<<~RUBY)
        puts { {} }
      RUBY
    end

    it 'autocorrects Hash.new to {} in various contexts' do
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

    it 'autocorrects Hash.new to {} as the only parameter to a method' do
      expect_offense(<<~RUBY)
        yadayada.map { a }.reduce Hash.new
                                  ^^^^^^^^ Use hash literal `{}` instead of `Hash.new`.
      RUBY

      expect_correction(<<~RUBY)
        yadayada.map { a }.reduce({})
      RUBY
    end

    it 'autocorrects Hash.new to {} as the first parameter to a method' do
      expect_offense(<<~RUBY)
        yadayada.map { a }.reduce Hash.new, :merge
                                  ^^^^^^^^ Use hash literal `{}` instead of `Hash.new`.
      RUBY

      expect_correction(<<~RUBY)
        yadayada.map { a }.reduce({}, :merge)
      RUBY
    end

    it 'autocorrects Hash.new to {} and wraps it in parentheses ' \
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

    it 'autocorrects Hash.new to {} and wraps all arguments in ' \
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

  describe 'Empty String', :config do
    let(:other_cops) { { 'Style/FrozenStringLiteral' => { 'Enabled' => false } } }

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
      let(:other_cops) do
        super().merge('Style/StringLiterals' => { 'EnforcedStyle' => 'double_quotes' })
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

    context 'when frozen string literals is enabled', :ruby23 do
      it 'does not register an offense for String.new' do
        expect_no_offenses(<<~RUBY)
          # frozen_string_literal: true
          test = String.new
        RUBY
      end
    end

    context 'when Style/FrozenStringLiteral is enabled' do
      let(:other_cops) { { 'Style/FrozenStringLiteral' => { 'Enabled' => true } } }

      context 'and there is no magic comment' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            test = String.new
          RUBY
        end
      end

      context 'and there is a frozen_string_literal: false comment' do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY)
            # frozen_string_literal: false
            test = String.new
                   ^^^^^^^^^^ Use string literal `''` instead of `String.new`.
          RUBY

          expect_correction(<<~RUBY)
            # frozen_string_literal: false
            test = ''
          RUBY
        end
      end
    end
  end
end
