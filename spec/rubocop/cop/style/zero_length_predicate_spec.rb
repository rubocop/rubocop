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

    it 'registers an offense for `array&.length == 0`' do
      expect_offense(<<~RUBY)
        [1, 2, 3]&.length == 0
        ^^^^^^^^^^^^^^^^^^^^^^ Use `empty?` instead of `length == 0`.
      RUBY

      expect_correction(<<~RUBY)
        [1, 2, 3]&.empty?
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

    it 'registers an offense for `array&.length.zero?`' do
      expect_offense(<<~RUBY)
        [1, 2, 3]&.length.zero?
                   ^^^^^^^^^^^^ Use `empty?` instead of `length.zero?`.
      RUBY

      expect_correction(<<~RUBY)
        [1, 2, 3]&.empty?
      RUBY
    end

    it 'registers an offense for `array&.length&.zero?`' do
      expect_offense(<<~RUBY)
        [1, 2, 3]&.length&.zero?
                   ^^^^^^^^^^^^^ Use `empty?` instead of `length&.zero?`.
      RUBY

      expect_correction(<<~RUBY)
        [1, 2, 3]&.empty?
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

    it 'registers an offense for `array&.length < 1`' do
      expect_offense(<<~RUBY)
        array&.length < 1
        ^^^^^^^^^^^^^^^^^ Use `empty?` instead of `length < 1`.
      RUBY

      expect_correction(<<~RUBY)
        array&.empty?
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

    it 'registers an offense for `1 > array&.length`' do
      expect_offense(<<~RUBY)
        1 > array&.length
        ^^^^^^^^^^^^^^^^^ Use `empty?` instead of `1 > length`.
      RUBY

      expect_correction(<<~RUBY)
        array&.empty?
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

    it 'does not register an offense for `array&.length > 0`' do
      expect_no_offenses(<<~RUBY)
        [1, 2, 3]&.length > 0
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

  context 'when the receiver is a local variable assigned from a non-polymorphic source' do
    it 'does not register an offense for `lvar.size.zero?` assigned from `File.stat`' do
      expect_no_offenses(<<~RUBY)
        stat = File.stat('foo')
        stat.size.zero?
      RUBY
    end

    it 'does not register an offense for `lvar.size == 0` assigned from `File.stat`' do
      expect_no_offenses(<<~RUBY)
        stat = File.stat('foo')
        stat.size == 0
      RUBY
    end

    it 'does not register an offense for `0 == lvar.size` assigned from `File.stat`' do
      expect_no_offenses(<<~RUBY)
        stat = File.stat('foo')
        0 == stat.size
      RUBY
    end

    it 'does not register an offense for `lvar.size != 0` assigned from `File.stat`' do
      expect_no_offenses(<<~RUBY)
        stat = File.stat('foo')
        stat.size != 0
      RUBY
    end

    it 'does not register an offense when assigned from `File.new`' do
      expect_no_offenses(<<~RUBY)
        f = File.new('foo')
        f.size.zero?
      RUBY
    end

    it 'does not register an offense when assigned from `Tempfile.new`' do
      expect_no_offenses(<<~RUBY)
        t = Tempfile.new('foo')
        t.size.zero?
      RUBY
    end

    it 'does not register an offense when assigned from `Tempfile.open`' do
      expect_no_offenses(<<~RUBY)
        t = Tempfile.open('foo')
        t.size.zero?
      RUBY
    end

    it 'does not register an offense when assigned from `StringIO.new`' do
      expect_no_offenses(<<~RUBY)
        io = StringIO.new('foo')
        io.size.zero?
      RUBY
    end

    it 'does not register an offense with top-level `::File.stat`' do
      expect_no_offenses(<<~RUBY)
        stat = ::File.stat('foo')
        stat.size.zero?
      RUBY
    end

    it 'does not register an offense when the assignment is inside a method' do
      expect_no_offenses(<<~RUBY)
        def empty_file?(path)
          stat = File.stat(path)
          stat.size.zero?
        end
      RUBY
    end

    it 'still registers an offense for an array lvar' do
      expect_offense(<<~RUBY)
        arr = [1, 2, 3]
        arr.size.zero?
            ^^^^^^^^^^ Use `empty?` instead of `size.zero?`.
      RUBY

      expect_correction(<<~RUBY)
        arr = [1, 2, 3]
        arr.empty?
      RUBY
    end

    it 'still registers an offense when the only preceding assignment is non-polymorphic-incompatible' do
      expect_offense(<<~RUBY)
        stat = [1, 2, 3]
        stat.size.zero?
             ^^^^^^^^^^ Use `empty?` instead of `size.zero?`.
      RUBY
    end
  end
end
