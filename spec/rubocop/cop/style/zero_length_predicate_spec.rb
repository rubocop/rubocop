# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ZeroLengthPredicate, :config do
  context 'with arrays' do
    it 'registers an offense for `array.length == 0`' do
      expect_offense(<<~RUBY)
        [1, 2, 3].length == 0
        ^^^^^^^^^^^^^^^^^^^^^ Use `empty?` instead of `length == 0`.
      RUBY

      expect_correction(<<~RUBY)
        [1, 2, 3].empty?
      RUBY
    end

    it 'registers an offense for `array.size == 0`' do
      expect_offense(<<~RUBY)
        [1, 2, 3].size == 0
        ^^^^^^^^^^^^^^^^^^^ Use `empty?` instead of `size == 0`.
      RUBY

      expect_correction(<<~RUBY)
        [1, 2, 3].empty?
      RUBY
    end

    it 'registers an offense for `array.length.zero?`' do
      expect_offense(<<~RUBY)
        [1, 2, 3].length.zero?
                  ^^^^^^^^^^^^ Use `empty?` instead of `length.zero?`.
      RUBY

      expect_correction(<<~RUBY)
        [1, 2, 3].empty?
      RUBY
    end

    it 'registers an offense for `array.size.zero?`' do
      expect_offense(<<~RUBY)
        [1, 2, 3].size.zero?
                  ^^^^^^^^^^ Use `empty?` instead of `size.zero?`.
      RUBY

      expect_correction(<<~RUBY)
        [1, 2, 3].empty?
      RUBY
    end

    it 'registers an offense for `0 == array.length`' do
      expect_offense(<<~RUBY)
        0 == [1, 2, 3].length
        ^^^^^^^^^^^^^^^^^^^^^ Use `empty?` instead of `0 == length`.
      RUBY

      expect_correction(<<~RUBY)
        [1, 2, 3].empty?
      RUBY
    end

    it 'registers an offense for `0 == array.size`' do
      expect_offense(<<~RUBY)
        0 == [1, 2, 3].size
        ^^^^^^^^^^^^^^^^^^^ Use `empty?` instead of `0 == size`.
      RUBY

      expect_correction(<<~RUBY)
        [1, 2, 3].empty?
      RUBY
    end

    it 'registers an offense for `array.length < 1`' do
      expect_offense(<<~RUBY)
        [1, 2, 3].length < 1
        ^^^^^^^^^^^^^^^^^^^^ Use `empty?` instead of `length < 1`.
      RUBY

      expect_correction(<<~RUBY)
        [1, 2, 3].empty?
      RUBY
    end

    it 'registers an offense for `array.size < 1`' do
      expect_offense(<<~RUBY)
        [1, 2, 3].size < 1
        ^^^^^^^^^^^^^^^^^^ Use `empty?` instead of `size < 1`.
      RUBY

      expect_correction(<<~RUBY)
        [1, 2, 3].empty?
      RUBY
    end

    it 'registers an offense for `1 > array.length`' do
      expect_offense(<<~RUBY)
        1 > [1, 2, 3].length
        ^^^^^^^^^^^^^^^^^^^^ Use `empty?` instead of `1 > length`.
      RUBY

      expect_correction(<<~RUBY)
        [1, 2, 3].empty?
      RUBY
    end

    it 'registers an offense for `1 > array.size`' do
      expect_offense(<<~RUBY)
        1 > [1, 2, 3].size
        ^^^^^^^^^^^^^^^^^^ Use `empty?` instead of `1 > size`.
      RUBY

      expect_correction(<<~RUBY)
        [1, 2, 3].empty?
      RUBY
    end

    it 'registers an offense for `array.length > 0`' do
      expect_offense(<<~RUBY)
        [1, 2, 3].length > 0
        ^^^^^^^^^^^^^^^^^^^^ Use `!empty?` instead of `length > 0`.
      RUBY

      expect_correction(<<~RUBY)
        ![1, 2, 3].empty?
      RUBY
    end

    it 'registers an offense for `array.size > 0`' do
      expect_offense(<<~RUBY)
        [1, 2, 3].size > 0
        ^^^^^^^^^^^^^^^^^^ Use `!empty?` instead of `size > 0`.
      RUBY

      expect_correction(<<~RUBY)
        ![1, 2, 3].empty?
      RUBY
    end

    it 'registers an offense for `array.length != 0`' do
      expect_offense(<<~RUBY)
        [1, 2, 3].length != 0
        ^^^^^^^^^^^^^^^^^^^^^ Use `!empty?` instead of `length != 0`.
      RUBY

      expect_correction(<<~RUBY)
        ![1, 2, 3].empty?
      RUBY
    end

    it 'registers an offense for `array.size != 0`' do
      expect_offense(<<~RUBY)
        [1, 2, 3].size != 0
        ^^^^^^^^^^^^^^^^^^^ Use `!empty?` instead of `size != 0`.
      RUBY

      expect_correction(<<~RUBY)
        ![1, 2, 3].empty?
      RUBY
    end

    it 'registers an offense for `!array.length.zero?`' do
      expect_offense(<<~RUBY)
        ![1, 2, 3].length.zero?
                   ^^^^^^^^^^^^ Use `empty?` instead of `length.zero?`.
      RUBY

      expect_correction(<<~RUBY)
        ![1, 2, 3].empty?
      RUBY
    end

    it 'registers an offense for `!array.size.zero?`' do
      expect_offense(<<~RUBY)
        ![1, 2, 3].size.zero?
                   ^^^^^^^^^^ Use `empty?` instead of `size.zero?`.
      RUBY

      expect_correction(<<~RUBY)
        ![1, 2, 3].empty?
      RUBY
    end

    it 'registers an offense for `0 < array.length' do
      expect_offense(<<~RUBY)
        0 < [1, 2, 3].length
        ^^^^^^^^^^^^^^^^^^^^ Use `!empty?` instead of `0 < length`.
      RUBY

      expect_correction(<<~RUBY)
        ![1, 2, 3].empty?
      RUBY
    end

    it 'registers an offense for `0 < array.size`' do
      expect_offense(<<~RUBY)
        0 < [1, 2, 3].size
        ^^^^^^^^^^^^^^^^^^ Use `!empty?` instead of `0 < size`.
      RUBY

      expect_correction(<<~RUBY)
        ![1, 2, 3].empty?
      RUBY
    end

    it 'registers an offense for `0 != array.length`' do
      expect_offense(<<~RUBY)
        0 != [1, 2, 3].length
        ^^^^^^^^^^^^^^^^^^^^^ Use `!empty?` instead of `0 != length`.
      RUBY

      expect_correction(<<~RUBY)
        ![1, 2, 3].empty?
      RUBY
    end

    it 'registers an offense for `0 != array.size`' do
      expect_offense(<<~RUBY)
        0 != [1, 2, 3].size
        ^^^^^^^^^^^^^^^^^^^ Use `!empty?` instead of `0 != size`.
      RUBY

      expect_correction(<<~RUBY)
        ![1, 2, 3].empty?
      RUBY
    end
  end

  context 'with hashes' do
    it 'registers an offense for `hash.size == 0`' do
      expect_offense(<<~RUBY)
        { a: 1, b: 2 }.size == 0
        ^^^^^^^^^^^^^^^^^^^^^^^^ Use `empty?` instead of `size == 0`.
      RUBY

      expect_correction(<<~RUBY)
        { a: 1, b: 2 }.empty?
      RUBY
    end

    it 'registers an offense for `0 == hash.size' do
      expect_offense(<<~RUBY)
        0 == { a: 1, b: 2 }.size
        ^^^^^^^^^^^^^^^^^^^^^^^^ Use `empty?` instead of `0 == size`.
      RUBY

      expect_correction(<<~RUBY)
        { a: 1, b: 2 }.empty?
      RUBY
    end

    it 'registers an offense for `hash.size != 0`' do
      expect_offense(<<~RUBY)
        { a: 1, b: 2 }.size != 0
        ^^^^^^^^^^^^^^^^^^^^^^^^ Use `!empty?` instead of `size != 0`.
      RUBY

      expect_correction(<<~RUBY)
        !{ a: 1, b: 2 }.empty?
      RUBY
    end

    it 'registers an offense for `0 != hash.size`' do
      expect_offense(<<~RUBY)
        0 != { a: 1, b: 2 }.size
        ^^^^^^^^^^^^^^^^^^^^^^^^ Use `!empty?` instead of `0 != size`.
      RUBY

      expect_correction(<<~RUBY)
        !{ a: 1, b: 2 }.empty?
      RUBY
    end
  end

  context 'with strings' do
    it 'registers an offense for `string.size == 0`' do
      expect_offense(<<~RUBY)
        "string".size == 0
        ^^^^^^^^^^^^^^^^^^ Use `empty?` instead of `size == 0`.
      RUBY

      expect_correction(<<~RUBY)
        "string".empty?
      RUBY
    end

    it 'registers an offense for `0 == string.size`' do
      expect_offense(<<~RUBY)
        0 == "string".size
        ^^^^^^^^^^^^^^^^^^ Use `empty?` instead of `0 == size`.
      RUBY

      expect_correction(<<~RUBY)
        "string".empty?
      RUBY
    end

    it 'registers an offense for `string.size != 0`' do
      expect_offense(<<~RUBY)
        "string".size != 0
        ^^^^^^^^^^^^^^^^^^ Use `!empty?` instead of `size != 0`.
      RUBY

      expect_correction(<<~RUBY)
        !"string".empty?
      RUBY
    end

    it 'registers an offense for `0 != string.size`' do
      expect_offense(<<~RUBY)
        0 != "string".size
        ^^^^^^^^^^^^^^^^^^ Use `!empty?` instead of `0 != size`.
      RUBY

      expect_correction(<<~RUBY)
        !"string".empty?
      RUBY
    end
  end

  context 'with collection variables' do
    it 'registers an offense for `collection.size == 0`' do
      expect_offense(<<~RUBY)
        collection.size == 0
        ^^^^^^^^^^^^^^^^^^^^ Use `empty?` instead of `size == 0`.
      RUBY

      expect_correction(<<~RUBY)
        collection.empty?
      RUBY
    end

    it 'registers an offense for `0 == collection.size`' do
      expect_offense(<<~RUBY)
        0 == collection.size
        ^^^^^^^^^^^^^^^^^^^^ Use `empty?` instead of `0 == size`.
      RUBY

      expect_correction(<<~RUBY)
        collection.empty?
      RUBY
    end

    it 'registers an offense for `collection.size != 0`' do
      expect_offense(<<~RUBY)
        collection.size != 0
        ^^^^^^^^^^^^^^^^^^^^ Use `!empty?` instead of `size != 0`.
      RUBY

      expect_correction(<<~RUBY)
        !collection.empty?
      RUBY
    end

    it 'registers an offense for `0 != collection.size`' do
      expect_offense(<<~RUBY)
        0 != collection.size
        ^^^^^^^^^^^^^^^^^^^^ Use `!empty?` instead of `0 != size`.
      RUBY

      expect_correction(<<~RUBY)
        !collection.empty?
      RUBY
    end
  end

  context 'when name of the variable is `size` or `length`' do
    it 'accepts equality check' do
      expect_no_offenses('size == 0')
      expect_no_offenses('length == 0')

      expect_no_offenses('0 == size')
      expect_no_offenses('0 == length')
    end

    it 'accepts comparison' do
      expect_no_offenses('size <= 0')
      expect_no_offenses('length > 0')

      expect_no_offenses('0 <= size')
      expect_no_offenses('0 > length')
    end

    it 'accepts inequality check' do
      expect_no_offenses('size != 0')
      expect_no_offenses('length != 0')

      expect_no_offenses('0 != size')
      expect_no_offenses('0 != length')
    end
  end

  context 'when inspecting a File::Stat object' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        File.stat(foo).size == 0
      RUBY
    end

    it 'does not register an offense with ::File' do
      expect_no_offenses(<<~RUBY)
        ::File.stat(foo).size == 0
      RUBY
    end
  end

  context 'when inspecting a StringIO object' do
    context 'when initialized with a string' do
      it 'does not register an offense using `size == 0`' do
        expect_no_offenses(<<~RUBY)
          StringIO.new('foo').size == 0
        RUBY
      end

      it 'does not register an offense with top-level ::StringIO using `size == 0`' do
        expect_no_offenses(<<~RUBY)
          ::StringIO.new('foo').size == 0
        RUBY
      end

      it 'does not register an offense using `size.zero?`' do
        expect_no_offenses(<<~RUBY)
          StringIO.new('foo').size.zero?
        RUBY
      end

      it 'does not register an offense with top-level ::StringIO using `size.zero?`' do
        expect_no_offenses(<<~RUBY)
          ::StringIO.new('foo').size.zero?
        RUBY
      end
    end

    context 'when initialized without arguments' do
      it 'does not register an offense using `size == 0`' do
        expect_no_offenses(<<~RUBY)
          StringIO.new.size == 0
        RUBY
      end

      it 'does not register an offense with top-level ::StringIO using `size == 0`' do
        expect_no_offenses(<<~RUBY)
          ::StringIO.new.size == 0
        RUBY
      end

      it 'does not register an offense using `size.zero?`' do
        expect_no_offenses(<<~RUBY)
          StringIO.new.size.zero?
        RUBY
      end

      it 'does not register an offense with top-level ::StringIO using `size.zero?`' do
        expect_no_offenses(<<~RUBY)
          ::StringIO.new.size.zero?
        RUBY
      end
    end
  end

  context 'when inspecting a File object' do
    it 'does not register an offense using `size == 0`' do
      expect_no_offenses(<<~RUBY)
        File.new('foo').size == 0
      RUBY
    end

    it 'does not register an offense with top-level ::File using `size == 0`' do
      expect_no_offenses(<<~RUBY)
        ::File.new('foo').size == 0
      RUBY
    end

    it 'does not register an offense using `size.zero?`' do
      expect_no_offenses(<<~RUBY)
        File.new('foo').size.zero?
      RUBY
    end

    it 'does not register an offense with top-level ::File using `size.zero?`' do
      expect_no_offenses(<<~RUBY)
        ::File.new('foo').size.zero?
      RUBY
    end
  end

  context 'when inspecting a Tempfile object' do
    it 'does not register an offense using `size == 0`' do
      expect_no_offenses(<<~RUBY)
        Tempfile.new('foo').size == 0
      RUBY
    end

    it 'does not register an offense with top-level ::Tempfile using `size == 0`' do
      expect_no_offenses(<<~RUBY)
        ::Tempfile.new('foo').size == 0
      RUBY
    end

    it 'does not register an offense using `size.zero?`' do
      expect_no_offenses(<<~RUBY)
        Tempfile.new('foo').size.zero?
      RUBY
    end

    it 'does not register an offense with top-level ::Tempfile using `size.zero?`' do
      expect_no_offenses(<<~RUBY)
        ::Tempfile.new('foo').size.zero?
      RUBY
    end
  end
end
