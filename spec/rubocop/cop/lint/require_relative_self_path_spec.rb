# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::RequireRelativeSelfPath, :config do
  it 'registers an offense when using `require_relative` with self file path argument' do
    expect_offense(<<~RUBY, 'foo.rb')
      require_relative 'foo'
      ^^^^^^^^^^^^^^^^^^^^^^ Remove the `require_relative` that requires itself.
      require_relative 'bar'
    RUBY

    expect_correction(<<~RUBY)
      require_relative 'bar'
    RUBY
  end

  it 'registers an offense when using `require_relative` with self file path argument (with ext)' do
    expect_offense(<<~RUBY, 'foo.rb')
      require_relative 'foo.rb'
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Remove the `require_relative` that requires itself.
      require_relative 'bar'
    RUBY

    expect_correction(<<~RUBY)
      require_relative 'bar'
    RUBY
  end

  it 'does not register an offense when using `require_relative` without self file path argument' do
    expect_no_offenses(<<~RUBY, 'foo.rb')
      require_relative 'bar'
    RUBY
  end

  it 'does not register an offense when using `require_relative` without argument' do
    expect_no_offenses(<<~RUBY, 'foo.rb')
      require_relative
    RUBY
  end

  it 'does not register an offense when the filename is the same but the extension does not match' do
    expect_no_offenses(<<~RUBY, 'foo.rb')
      require_relative 'foo.racc'
    RUBY
  end

  it 'preserves the statement after the self-require' do
    expect_offense(<<~RUBY, 'foo.rb')
      require_relative 'foo'; register_handlers
      ^^^^^^^^^^^^^^^^^^^^^^ Remove the `require_relative` that requires itself.
    RUBY

    expect_correction(<<~RUBY)
      ; register_handlers
    RUBY
  end

  it 'preserves the statement and comment before and after the self-require' do
    expect_offense(<<~RUBY, 'foo.rb')
      prepare; require_relative 'foo' # keep
               ^^^^^^^^^^^^^^^^^^^^^^ Remove the `require_relative` that requires itself.
    RUBY

    expect_correction(<<~RUBY)
      prepare; # keep
    RUBY
  end

  it 'does not remove a self-require used as an argument' do
    expect_offense(<<~RUBY, 'foo.rb')
      register(require_relative 'foo')
               ^^^^^^^^^^^^^^^^^^^^^^ Remove the `require_relative` that requires itself.
    RUBY

    expect_no_corrections
  end

  it 'does not remove the condition of a modifier' do
    expect_offense(<<~RUBY, 'foo.rb')
      register if require_relative 'foo'
                  ^^^^^^^^^^^^^^^^^^^^^^ Remove the `require_relative` that requires itself.
    RUBY

    expect_no_corrections
  end

  it 'does not remove a self-require on its own line that is the last argument' do
    expect_offense(<<~RUBY, 'foo.rb')
      register handler,
        require_relative('foo')
        ^^^^^^^^^^^^^^^^^^^^^^^ Remove the `require_relative` that requires itself.
      prepare
    RUBY

    expect_no_corrections
  end

  it 'does not remove a self-require on its own line that is the only argument' do
    expect_offense(<<~RUBY, 'foo.rb')
      register(
        require_relative 'foo'
        ^^^^^^^^^^^^^^^^^^^^^^ Remove the `require_relative` that requires itself.
      )
    RUBY

    expect_no_corrections
  end

  it 'does not remove a self-require on its own line that is assigned' do
    expect_offense(<<~RUBY, 'foo.rb')
      loaded =
        require_relative 'foo'
        ^^^^^^^^^^^^^^^^^^^^^^ Remove the `require_relative` that requires itself.
      prepare
    RUBY

    expect_no_corrections
  end

  it 'does not remove a self-require on its own line that is assigned with an operator' do
    expect_offense(<<~RUBY, 'foo.rb')
      loaded ||=
        require_relative('foo')
        ^^^^^^^^^^^^^^^^^^^^^^^ Remove the `require_relative` that requires itself.
      prepare
    RUBY

    expect_no_corrections
  end

  it 'does not remove a self-require on its own line that is an operand of `||`' do
    expect_offense(<<~RUBY, 'foo.rb')
      loaded = cached ||
        require_relative('foo')
        ^^^^^^^^^^^^^^^^^^^^^^^ Remove the `require_relative` that requires itself.
      prepare
    RUBY

    expect_no_corrections
  end

  it 'does not remove a self-require on its own line that is the condition of a modifier' do
    expect_offense(<<~RUBY, 'foo.rb')
      return unless
        require_relative 'foo'
        ^^^^^^^^^^^^^^^^^^^^^^ Remove the `require_relative` that requires itself.
      prepare
    RUBY

    expect_no_corrections
  end

  it 'does not remove a self-require on its own line that is a hash value' do
    expect_offense(<<~RUBY, 'foo.rb')
      {
        loaded:
          require_relative('foo')
          ^^^^^^^^^^^^^^^^^^^^^^^ Remove the `require_relative` that requires itself.
      }
    RUBY

    expect_no_corrections
  end

  it 'does not remove a self-require on its own line that is an array element' do
    expect_offense(<<~RUBY, 'foo.rb')
      [
        require_relative('foo')
        ^^^^^^^^^^^^^^^^^^^^^^^ Remove the `require_relative` that requires itself.
      ]
    RUBY

    expect_no_corrections
  end

  it 'does not remove a self-require on its own line whose value is used through parentheses' do
    expect_offense(<<~RUBY, 'foo.rb')
      loaded = (
        require_relative 'foo'
        ^^^^^^^^^^^^^^^^^^^^^^ Remove the `require_relative` that requires itself.
      )
    RUBY

    expect_no_corrections
  end

  it 'does not remove a self-require on its own line that is the body of an endless method', :ruby30 do
    expect_offense(<<~RUBY, 'foo.rb')
      def load_self =
        require_relative('foo')
        ^^^^^^^^^^^^^^^^^^^^^^^ Remove the `require_relative` that requires itself.
      prepare
    RUBY

    expect_no_corrections
  end

  it 'does not remove a self-require on its own line that follows a modifier `rescue`' do
    expect_offense(<<~RUBY, 'foo.rb')
      loaded = prepare rescue
        require_relative('foo')
        ^^^^^^^^^^^^^^^^^^^^^^^ Remove the `require_relative` that requires itself.
      register_handlers
    RUBY

    expect_no_corrections
  end

  it 'does not remove a self-require on its own line that is the condition of a loop or a branch of a ternary' do
    expect_offense(<<~RUBY, 'foo.rb')
      while
        require_relative 'foo'
        ^^^^^^^^^^^^^^^^^^^^^^ Remove the `require_relative` that requires itself.
        prepare
      end
      loaded = cached ?
        require_relative('foo')
        ^^^^^^^^^^^^^^^^^^^^^^^ Remove the `require_relative` that requires itself.
        : false
    RUBY

    expect_no_corrections
  end

  it 'removes a self-require that is the body of a conditional' do
    expect_offense(<<~RUBY, 'foo.rb')
      if standalone
        require_relative 'foo'
        ^^^^^^^^^^^^^^^^^^^^^^ Remove the `require_relative` that requires itself.
      else
        require_relative 'foo'
        ^^^^^^^^^^^^^^^^^^^^^^ Remove the `require_relative` that requires itself.
      end
    RUBY

    expect_correction(<<~RUBY)
      if standalone
      else
      end
    RUBY
  end

  it 'removes a self-require from the bodies of `begin`, `rescue` and `ensure`' do
    expect_offense(<<~RUBY, 'foo.rb')
      begin
        require_relative 'foo'
        ^^^^^^^^^^^^^^^^^^^^^^ Remove the `require_relative` that requires itself.
      rescue LoadError
        require_relative 'foo'
        ^^^^^^^^^^^^^^^^^^^^^^ Remove the `require_relative` that requires itself.
      ensure
        require_relative 'foo'
        ^^^^^^^^^^^^^^^^^^^^^^ Remove the `require_relative` that requires itself.
      end
    RUBY

    expect_correction(<<~RUBY)
      begin
      rescue LoadError
      ensure
      end
    RUBY
  end

  it 'removes a self-require from the body of a block' do
    expect_offense(<<~RUBY, 'foo.rb')
      configure do
        require_relative 'foo'
        ^^^^^^^^^^^^^^^^^^^^^^ Remove the `require_relative` that requires itself.
      end
      configure do |config|
        config.prepare
        require_relative 'foo'
        ^^^^^^^^^^^^^^^^^^^^^^ Remove the `require_relative` that requires itself.
      end
    RUBY

    expect_correction(<<~RUBY)
      configure do
      end
      configure do |config|
        config.prepare
      end
    RUBY
  end

  it 'removes a self-require from the body of a method, a class and a `when` branch' do
    expect_offense(<<~RUBY, 'foo.rb')
      class Loader
        require_relative 'foo'
        ^^^^^^^^^^^^^^^^^^^^^^ Remove the `require_relative` that requires itself.

        def load_self(kind)
          require_relative 'foo'
          ^^^^^^^^^^^^^^^^^^^^^^ Remove the `require_relative` that requires itself.
          case kind
          when :self
            require_relative 'foo'
            ^^^^^^^^^^^^^^^^^^^^^^ Remove the `require_relative` that requires itself.
          end
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      class Loader

        def load_self(kind)
          case kind
          when :self
          end
        end
      end
    RUBY
  end

  it 'does not register an offense when using a variable as an argument of `require_relative`' do
    expect_no_offenses(<<~RUBY, 'foo.rb')
      Dir['test/**/test_*.rb'].each { |f| require_relative f }
    RUBY
  end

  it 'does not register an offense when a `.rake` file requires a file with the same basename' do
    expect_no_offenses(<<~RUBY, 'foo.rake')
      require_relative 'foo'
    RUBY
  end

  it 'does not register an offense when a file without an extension requires a file with the same basename' do
    expect_no_offenses(<<~RUBY, 'Rakefile')
      require_relative 'Rakefile'
    RUBY
  end

  context 'when the file path is absolute' do
    it 'registers an offense for the with-extension form' do
      expect_offense(<<~RUBY, '/path/to/foo.rb')
        require_relative 'foo.rb'
        ^^^^^^^^^^^^^^^^^^^^^^^^^ Remove the `require_relative` that requires itself.
        require_relative 'bar'
      RUBY

      expect_correction(<<~RUBY)
        require_relative 'bar'
      RUBY
    end

    it 'registers an offense for the without-extension form' do
      expect_offense(<<~RUBY, '/path/to/foo.rb')
        require_relative 'foo'
        ^^^^^^^^^^^^^^^^^^^^^^ Remove the `require_relative` that requires itself.
      RUBY

      expect_correction('')
    end

    it 'does not register an offense for a different file with the same basename in another directory' do
      expect_no_offenses(<<~RUBY, '/path/to/foo.rb')
        require_relative 'sub/foo'
      RUBY
    end
  end
end
