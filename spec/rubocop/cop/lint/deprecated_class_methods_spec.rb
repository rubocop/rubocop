# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::DeprecatedClassMethods, :config do
  context 'prefer `File.exist?` over `File.exists?`' do
    it 'registers an offense and corrects File.exists?' do
      expect_offense(<<~RUBY)
        File.exists?(o)
        ^^^^^^^^^^^^ `File.exists?` is deprecated in favor of `File.exist?`.
      RUBY

      expect_correction(<<~RUBY)
        File.exist?(o)
      RUBY
    end

    it 'registers an offense and corrects ::File.exists?' do
      expect_offense(<<~RUBY)
        ::File.exists?(o)
        ^^^^^^^^^^^^^^ `::File.exists?` is deprecated in favor of `::File.exist?`.
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
        ^^^^^^^^^^^ `Dir.exists?` is deprecated in favor of `Dir.exist?`.
      RUBY

      expect_correction(<<~RUBY)
        Dir.exist?(o)
      RUBY
    end

    it 'registers an offense and corrects ::Dir.exists?' do
      expect_offense(<<~RUBY)
        ::Dir.exists?(o)
        ^^^^^^^^^^^^^ `::Dir.exists?` is deprecated in favor of `::Dir.exist?`.
      RUBY

      expect_correction(<<~RUBY)
        ::Dir.exist?(o)
      RUBY
    end

    it 'does not register an offense for Dir.exist?' do
      expect_no_offenses('Dir.exist?(o)')
    end

    it 'does not register an offense for offensive method `exists?`on other receivers' do
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

    it 'does not register an offense for offensive method `iterator?`on other receivers' do
      expect_no_offenses('Foo.iterator?')
    end
  end

  context 'prefer `attr_accessor :name` over `attr :name, true`' do
    it 'registers an offense and corrects `attr :name` with boolean argument' do
      expect_offense(<<~RUBY)
        attr :name, true
        ^^^^^^^^^^^^^^^^ `attr :name, true` is deprecated in favor of `attr_accessor :name`.
      RUBY

      expect_correction(<<~RUBY)
        attr_accessor :name
      RUBY
    end

    it "registers an offense and corrects `attr 'name'` with boolean argument" do
      expect_offense(<<~RUBY)
        attr 'name', true
        ^^^^^^^^^^^^^^^^^ `attr 'name', true` is deprecated in favor of `attr_accessor 'name'`.
      RUBY

      expect_correction(<<~RUBY)
        attr_accessor 'name'
      RUBY
    end

    it 'does not register an offense for `attr` without boolean argument' do
      expect_no_offenses('attr :name')
    end

    it 'does not register an offense for `attr` with variable argument' do
      expect_no_offenses('attr :name, attribute')
    end

    it 'does not register an offense for `attr_accessor`' do
      expect_no_offenses('attr_accessor :name')
    end
  end

  context 'prefer `attr_reader :name` over `attr :name, false`' do
    it 'registers an offense and corrects `attr :name` with boolean argument' do
      expect_offense(<<~RUBY)
        attr :name, false
        ^^^^^^^^^^^^^^^^^ `attr :name, false` is deprecated in favor of `attr_reader :name`.
      RUBY

      expect_correction(<<~RUBY)
        attr_reader :name
      RUBY
    end

    it "registers an offense and corrects `attr 'name'` with boolean argument" do
      expect_offense(<<~RUBY)
        attr 'name', false
        ^^^^^^^^^^^^^^^^^^ `attr 'name', false` is deprecated in favor of `attr_reader 'name'`.
      RUBY

      expect_correction(<<~RUBY)
        attr_reader 'name'
      RUBY
    end

    it 'does not register an offense for `attr_reader` without boolean argument' do
      expect_no_offenses('attr_reader :name')
    end
  end

  context 'when using `ENV.freeze`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        ENV.freeze
        ^^^^^^^^^^ `ENV.freeze` is deprecated in favor of `ENV`.
      RUBY

      expect_correction(<<~RUBY)
        ENV
      RUBY
    end

    it 'does not register an offense for method calls to `ENV` other than `freeze`' do
      expect_no_offenses('ENV.values')
    end
  end

  context 'when using `ENV.clone`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        ENV.clone
        ^^^^^^^^^ `ENV.clone` is deprecated in favor of `ENV.to_h`.
      RUBY

      expect_correction(<<~RUBY)
        ENV.to_h
      RUBY
    end

    it 'does not register an offense for method calls to `ENV` other than `clone`' do
      expect_no_offenses('ENV.values')
    end
  end

  context 'when using `ENV.dup`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        ENV.dup
        ^^^^^^^ `ENV.dup` is deprecated in favor of `ENV.to_h`.
      RUBY

      expect_correction(<<~RUBY)
        ENV.to_h
      RUBY
    end

    it 'does not register an offense for method calls to `ENV` other than `dup`' do
      expect_no_offenses('ENV.values')
    end
  end

  context 'prefer `Addrinfo#getnameinfo` over `Socket.gethostbyaddr`' do
    it 'registers an offense for Socket.gethostbyaddr' do
      expect_offense(<<~RUBY)
        Socket.gethostbyaddr([221,186,184,68].pack("CCCC"))
        ^^^^^^^^^^^^^^^^^^^^ `Socket.gethostbyaddr` is deprecated in favor of `Addrinfo#getnameinfo`.
      RUBY

      expect_no_corrections
    end

    it 'registers an offense for ::Socket.gethostbyaddr' do
      expect_offense(<<~RUBY)
        ::Socket.gethostbyaddr([221,186,184,68].pack("CCCC"))
        ^^^^^^^^^^^^^^^^^^^^^^ `::Socket.gethostbyaddr` is deprecated in favor of `Addrinfo#getnameinfo`.
      RUBY

      expect_no_corrections
    end

    it 'registers an offense for Socket.gethostbyaddr with address type argument' do
      expect_offense(<<~RUBY)
        Socket.gethostbyaddr([221,186,184,68].pack("CCCC"), Socket::AF_INET)
        ^^^^^^^^^^^^^^^^^^^^ `Socket.gethostbyaddr` is deprecated in favor of `Addrinfo#getnameinfo`.
      RUBY

      expect_no_corrections
    end

    it 'does not register an offense for method `gethostbyaddr` on other receivers' do
      expect_no_offenses('Foo.gethostbyaddr')
    end
  end

  context 'prefer `Addrinfo#getaddrinfo` over `Socket.gethostbyname`' do
    it 'registers an offense for Socket.gethostbyname' do
      expect_offense(<<~RUBY)
        Socket.gethostbyname("hal")
        ^^^^^^^^^^^^^^^^^^^^ `Socket.gethostbyname` is deprecated in favor of `Addrinfo#getaddrinfo`.
      RUBY

      expect_no_corrections
    end

    it 'registers an offense for ::Socket.gethostbyname' do
      expect_offense(<<~RUBY)
        ::Socket.gethostbyname("hal")
        ^^^^^^^^^^^^^^^^^^^^^^ `::Socket.gethostbyname` is deprecated in favor of `Addrinfo#getaddrinfo`.
      RUBY

      expect_no_corrections
    end

    it 'does not register an offense for method `gethostbyname` on other receivers' do
      expect_no_offenses('Foo.gethostbyname')
    end
  end
end
