# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::DeprecatedClassMethods do
  subject(:cop) { described_class.new }

  context 'prefer `File.exist?` over `File.exists?`' do
    it 'registers an offense for File.exists?' do
      expect_offense(<<-RUBY.strip_indent)
        File.exists?(o)
             ^^^^^^^ `File.exists?` is deprecated in favor of `File.exist?`.
      RUBY
    end

    it 'registers an offense for ::File.exists?' do
      expect_offense(<<-RUBY.strip_indent)
        ::File.exists?(o)
               ^^^^^^^ `File.exists?` is deprecated in favor of `File.exist?`.
      RUBY
    end

    it 'does not register an offense for File.exist?' do
      expect_no_offenses('File.exist?(o)')
    end

    it 'auto-corrects File.exists? with File.exist?' do
      new_source = autocorrect_source('File.exists?(something)')
      expect(new_source).to eq('File.exist?(something)')
    end
  end

  context 'prefer `Dir.exist?` over `Dir.exists?`' do
    it 'registers an offense for Dir.exists?' do
      expect_offense(<<-RUBY.strip_indent)
        Dir.exists?(o)
            ^^^^^^^ `Dir.exists?` is deprecated in favor of `Dir.exist?`.
      RUBY
    end

    it 'registers an offense for ::Dir.exists?' do
      expect_offense(<<-RUBY.strip_indent)
        ::Dir.exists?(o)
              ^^^^^^^ `Dir.exists?` is deprecated in favor of `Dir.exist?`.
      RUBY
    end

    it 'does not register an offense for Dir.exist?' do
      expect_no_offenses('Dir.exist?(o)')
    end

    it 'auto-corrects Dir.exists? with Dir.exist?' do
      new_source = autocorrect_source('Dir.exists?(something)')
      expect(new_source).to eq('Dir.exist?(something)')
    end

    it 'does not register an offense for offensive method `exists?`'\
       'on other receivers' do
      expect_no_offenses('Foo.exists?(o)')
    end
  end

  context 'prefer `block_given?` over `iterator?`' do
    it 'registers an offense for iterator?' do
      expect_offense(<<-RUBY.strip_indent)
        iterator?
        ^^^^^^^^^ `iterator?` is deprecated in favor of `block_given?`.
      RUBY
    end

    it 'does not register an offense for block_given?' do
      expect_no_offenses('block_given?')
    end

    it 'autocorrects `iterator?` to `block_given?`' do
      new_source = autocorrect_source('iterator?')
      expect(new_source).to eq('block_given?')
    end

    it 'does not register an offense for offensive method `iterator?`'\
       'on other receivers' do
      expect_no_offenses('Foo.iterator?')
    end
  end
end
