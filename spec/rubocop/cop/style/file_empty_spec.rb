# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::FileEmpty, :config do
  context 'target ruby version >= 2.4', :ruby24 do
    it 'registers an offense for `File.zero?`' do
      expect_offense(<<~RUBY)
        File.zero?('path/to/file')
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `File.empty?('path/to/file')` instead.
      RUBY

      expect_correction(<<~RUBY)
        File.empty?('path/to/file')
      RUBY
    end

    it 'registers an offense for `!File.zero?`' do
      expect_offense(<<~RUBY)
        !File.zero?('path/to/file')
         ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `File.empty?('path/to/file')` instead.
      RUBY

      expect_correction(<<~RUBY)
        !File.empty?('path/to/file')
      RUBY
    end

    it 'registers an offense for `File.zero?` with line break' do
      expect_offense(<<~RUBY)
        File.
        ^^^^^ Use `File.empty?('path/to/file')` instead.
          zero?('path/to/file')
      RUBY

      expect_correction(<<~RUBY)
        File.empty?('path/to/file')
      RUBY
    end

    it 'registers an offense for `FileTest.zero?`' do
      expect_offense(<<~RUBY)
        FileTest.zero?('path/to/file')
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `FileTest.empty?('path/to/file')` instead.
      RUBY

      expect_correction(<<~RUBY)
        FileTest.empty?('path/to/file')
      RUBY
    end

    it 'registers an offense for `File.size == 0`' do
      expect_offense(<<~RUBY)
        File.size('path/to/file') == 0
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `File.empty?('path/to/file')` instead.
      RUBY

      expect_correction(<<~RUBY)
        File.empty?('path/to/file')
      RUBY
    end

    it 'registers an offense for `!File.size == 0`' do
      expect_offense(<<~RUBY)
        !File.size('path/to/file') == 0
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `File.empty?('path/to/file')` instead.
      RUBY

      expect_correction(<<~RUBY)
        !File.empty?('path/to/file')
      RUBY
    end

    it 'registers an offense for `File.size >= 0`' do
      expect_offense(<<~RUBY)
        File.size('path/to/file') >= 0
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `File.empty?('path/to/file')` instead.
      RUBY

      expect_correction(<<~RUBY)
        !File.empty?('path/to/file')
      RUBY
    end

    it 'registers an offense for `!File.size >= 0`' do
      expect_offense(<<~RUBY)
        !File.size('path/to/file') >= 0
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `File.empty?('path/to/file')` instead.
      RUBY

      expect_correction(<<~RUBY)
        File.empty?('path/to/file')
      RUBY
    end

    it 'registers an offense for `File.size.zero?`' do
      expect_offense(<<~RUBY)
        File.size('path/to/file').zero?
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `File.empty?('path/to/file')` instead.
      RUBY

      expect_correction(<<~RUBY)
        File.empty?('path/to/file')
      RUBY
    end

    it 'registers an offense for `File.read.empty?`' do
      expect_offense(<<~RUBY)
        File.read('path/to/file').empty?
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `File.empty?('path/to/file')` instead.
      RUBY

      expect_correction(<<~RUBY)
        File.empty?('path/to/file')
      RUBY
    end

    it 'registers an offense for `File.binread.empty?`' do
      expect_offense(<<~RUBY)
        File.binread('path/to/file').empty?
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `File.empty?('path/to/file')` instead.
      RUBY

      expect_correction(<<~RUBY)
        File.empty?('path/to/file')
      RUBY
    end

    it 'registers an offense for `File.read == ""`' do
      expect_offense(<<~RUBY)
        File.read('path/to/file') == ''
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `File.empty?('path/to/file')` instead.
      RUBY

      expect_correction(<<~RUBY)
        File.empty?('path/to/file')
      RUBY
    end

    it 'registers an offense for `File.binread == ""`' do
      expect_offense(<<~RUBY)
        File.binread('path/to/file') == ''
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `File.empty?('path/to/file')` instead.
      RUBY

      expect_correction(<<~RUBY)
        File.empty?('path/to/file')
      RUBY
    end

    it 'registers an offense for `File.read != ""`' do
      expect_offense(<<~RUBY)
        File.read('path/to/file') != ''
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `File.empty?('path/to/file')` instead.
      RUBY

      expect_correction(<<~RUBY)
        !File.empty?('path/to/file')
      RUBY
    end

    it 'registers an offense for `File.binread != ""`' do
      expect_offense(<<~RUBY)
        File.binread('path/to/file') != ''
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `File.empty?('path/to/file')` instead.
      RUBY

      expect_correction(<<~RUBY)
        !File.empty?('path/to/file')
      RUBY
    end

    it 'does not register an offense for `File.empty?`' do
      expect_no_offenses('File.empty?("path/to/file")')
    end

    it 'does not register an offense for non-offending methods' do
      expect_no_offenses('File.exist?("path/to/file")')
    end
  end

  context 'target ruby version < 2.4', :ruby23 do
    it 'does not register an offense for `File.zero?`' do
      expect_no_offenses("File.zero?('path/to/file')")
    end

    it 'does not register an offense for `FileTest.zero?`' do
      expect_no_offenses("FileTest.zero?('path/to/file')")
    end

    it 'does not register an offense for `File.size == 0`' do
      expect_no_offenses("File.size('path/to/file') == 0")
    end

    it 'does not register an offense for `File.size.zero?`' do
      expect_no_offenses("File.size('path/to/file').zero?")
    end

    it 'does not register an offense for `File.read.empty?`' do
      expect_no_offenses("File.read('path/to/file').empty?")
    end

    it 'does not register an offense for `File.binread.empty?`' do
      expect_no_offenses("File.binread('path/to/file').empty?")
    end

    it 'does not register an offense for `File.read == ""`' do
      expect_no_offenses("File.read('path/to/file') == ''")
    end

    it 'does not register an offense for `File.binread == ""`' do
      expect_no_offenses("File.binread('path/to/file') == ''")
    end

    it 'does not register an offense for `File.empty?`' do
      expect_no_offenses('File.empty?("path/to/file")')
    end

    it 'does not register an offense for non-offending methods' do
      expect_no_offenses('File.exist?("path/to/file")')
    end
  end
end
