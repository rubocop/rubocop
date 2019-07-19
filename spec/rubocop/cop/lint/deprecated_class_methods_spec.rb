# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::DeprecatedClassMethods do
  subject(:cop) { described_class.new }

  context 'prefer `File.exist?` over `File.exists?`' do
    it 'registers an offense and corrects File.exists?' do
      expect_offense(<<~RUBY)
        File.exists?(o)
             ^^^^^^^ `File.exists?` is deprecated in favor of `File.exist?`.
      RUBY

      expect_correction(<<~RUBY)
        File.exist?(o)
      RUBY
    end

    it 'registers an offense and corrects ::File.exists?' do
      expect_offense(<<~RUBY)
        ::File.exists?(o)
               ^^^^^^^ `File.exists?` is deprecated in favor of `File.exist?`.
      RUBY

      expect_correction(<<~RUBY)
        ::File.exist?(o)
      RUBY
    end

    it 'does not register an offense for File.exist?' do
      expect_no_offenses('File.exist?(o)')
    end
  end

  context 'prefer `Dir.exist?` over `Dir.exists?`' do
    it 'registers an offense and corrects Dir.exists?' do
      expect_offense(<<~RUBY)
        Dir.exists?(o)
            ^^^^^^^ `Dir.exists?` is deprecated in favor of `Dir.exist?`.
      RUBY

      expect_correction(<<~RUBY)
        Dir.exist?(o)
      RUBY
    end

    it 'registers an offense and corrects ::Dir.exists?' do
      expect_offense(<<~RUBY)
        ::Dir.exists?(o)
              ^^^^^^^ `Dir.exists?` is deprecated in favor of `Dir.exist?`.
      RUBY

      expect_correction(<<~RUBY)
        ::Dir.exist?(o)
      RUBY
    end

    it 'does not register an offense for Dir.exist?' do
      expect_no_offenses('Dir.exist?(o)')
    end

    it 'does not register an offense for offensive method `exists?`'\
       'on other receivers' do
      expect_no_offenses('Foo.exists?(o)')
    end
  end

  context 'prefer `block_given?` over `iterator?`' do
    it 'registers an offense and corrects iterator?' do
      expect_offense(<<~RUBY)
        iterator?
        ^^^^^^^^^ `iterator?` is deprecated in favor of `block_given?`.
      RUBY

      expect_correction(<<~RUBY)
        block_given?
      RUBY
    end

    it 'does not register an offense for block_given?' do
      expect_no_offenses('block_given?')
    end

    it 'does not register an offense for offensive method `iterator?`'\
       'on other receivers' do
      expect_no_offenses('Foo.iterator?')
    end
  end
end
