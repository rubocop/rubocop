# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::DirEmpty, :config do
  context 'target ruby version >= 2.4', :ruby24 do
    it 'registers an offense for `Dir.entries.size == 2`' do
      expect_offense(<<~RUBY)
        Dir.entries('path/to/dir').size == 2
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Dir.empty?('path/to/dir')` instead.
      RUBY

      expect_correction(<<~RUBY)
        Dir.empty?('path/to/dir')
      RUBY
    end

    it 'registers an offense for `!Dir.entries.size == 2`' do
      expect_offense(<<~RUBY)
        !Dir.entries('path/to/dir').size == 2
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Dir.empty?('path/to/dir')` instead.
      RUBY

      expect_correction(<<~RUBY)
        !Dir.empty?('path/to/dir')
      RUBY
    end

    it 'registers an offense for `Dir.entries.size > 2`' do
      expect_offense(<<~RUBY)
        Dir.entries('path/to/dir').size > 2
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Dir.empty?('path/to/dir')` instead.
      RUBY

      expect_correction(<<~RUBY)
        !Dir.empty?('path/to/dir')
      RUBY
    end

    it 'registers an offense for `Dir.entries.size == 2` with line break' do
      expect_offense(<<~RUBY)
        Dir.
        ^^^^ Use `Dir.empty?('path/to/dir')` instead.
          entries('path/to/dir').size == 2
      RUBY

      expect_correction(<<~RUBY)
        Dir.empty?('path/to/dir')
      RUBY
    end

    it 'registers an offense for `Dir.children.empty?`' do
      expect_offense(<<~RUBY)
        Dir.children('path/to/dir').empty?
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Dir.empty?('path/to/dir')` instead.
      RUBY

      expect_correction(<<~RUBY)
        Dir.empty?('path/to/dir')
      RUBY
    end

    it 'registers an offense for `Dir.children == 0`' do
      expect_offense(<<~RUBY)
        Dir.children('path/to/dir').size == 0
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Dir.empty?('path/to/dir')` instead.
      RUBY

      expect_correction(<<~RUBY)
        Dir.empty?('path/to/dir')
      RUBY
    end

    it 'registers an offense for `Dir.each_child.none?`' do
      expect_offense(<<~RUBY)
        Dir.each_child('path/to/dir').none?
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Dir.empty?('path/to/dir')` instead.
      RUBY

      expect_correction(<<~RUBY)
        Dir.empty?('path/to/dir')
      RUBY
    end

    it 'registers an offense for `!Dir.each_child.none?`' do
      expect_offense(<<~RUBY)
        !Dir.each_child('path/to/dir').none?
         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Dir.empty?('path/to/dir')` instead.
      RUBY

      expect_correction(<<~RUBY)
        !Dir.empty?('path/to/dir')
      RUBY
    end

    it 'does not register an offense for `Dir.empty?`' do
      expect_no_offenses('Dir.empty?("path/to/dir")')
    end

    it 'does not register an offense for non-offending methods' do
      expect_no_offenses('Dir.exist?("path/to/dir")')
    end
  end

  context 'target ruby version < 2.4', :ruby23 do
    it 'does not register an offense for `Dir.entries.size == 2`' do
      expect_no_offenses('Dir.entries("path/to/dir").size == 2')
    end

    it 'does not register an offense for `Dir.children.empty?`' do
      expect_no_offenses('Dir.children("path/to/dir").empty?')
    end

    it 'does not register an offense for `Dir.children == 0`' do
      expect_no_offenses('Dir.children("path/to/dir") == 0')
    end

    it 'does not register an offense for `Dir.each_child.none?`' do
      expect_no_offenses('Dir.each_child("path/to/dir").none?')
    end

    it 'does not register an offense for `Dir.empty?`' do
      expect_no_offenses('Dir.empty?("path/to/dir")')
    end

    it 'does not register an offense for non-offending methods' do
      expect_no_offenses('Dir.exist?("path/to/dir")')
    end
  end
end
