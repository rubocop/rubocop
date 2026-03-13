# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::ThreadUnsafePattern, :config do
  let(:cop_config) { { 'AllowedGlobalVariables' => [] } }

  context 'when reading a class variable inside Thread.new' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Thread.new { @@count }
                     ^^^^^^^ Class variable `@@count` is thread-unsafe. Consider using a class instance variable, a mutex, or `Thread::local` instead.
      RUBY
    end

    it 'registers an offense with do..end syntax' do
      expect_offense(<<~RUBY)
        Thread.new do
          @@count
          ^^^^^^^ Class variable `@@count` is thread-unsafe. Consider using a class instance variable, a mutex, or `Thread::local` instead.
        end
      RUBY
    end
  end

  context 'when writing a class variable inside Thread.new' do
    it 'registers an offense for direct assignment' do
      expect_offense(<<~RUBY)
        Thread.new { @@count = 0 }
                     ^^^^^^^ Class variable `@@count` is thread-unsafe. Consider using a class instance variable, a mutex, or `Thread::local` instead.
      RUBY
    end

    it 'registers an offense for compound assignment' do
      expect_offense(<<~RUBY)
        Thread.new { @@count += 1 }
                     ^^^^^^^ Class variable `@@count` is thread-unsafe. Consider using a class instance variable, a mutex, or `Thread::local` instead.
      RUBY
    end

    it 'registers an offense for or-assignment' do
      expect_offense(<<~RUBY)
        Thread.new { @@count ||= 0 }
                     ^^^^^^^ Class variable `@@count` is thread-unsafe. Consider using a class instance variable, a mutex, or `Thread::local` instead.
      RUBY
    end

    it 'registers an offense for and-assignment' do
      expect_offense(<<~RUBY)
        Thread.new { @@count &&= false }
                     ^^^^^^^ Class variable `@@count` is thread-unsafe. Consider using a class instance variable, a mutex, or `Thread::local` instead.
      RUBY
    end
  end

  context 'when mutating a global variable inside Thread.new' do
    it 'registers an offense for direct assignment' do
      expect_offense(<<~RUBY)
        Thread.new { $output = StringIO.new }
                     ^^^^^^^ Mutating global variable `$output` is thread-unsafe.
      RUBY
    end

    it 'registers an offense for compound assignment' do
      expect_offense(<<~RUBY)
        Thread.new { $counter += 1 }
                     ^^^^^^^^ Mutating global variable `$counter` is thread-unsafe.
      RUBY
    end

    it 'registers an offense for or-assignment' do
      expect_offense(<<~RUBY)
        Thread.new { $default ||= 'value' }
                     ^^^^^^^^ Mutating global variable `$default` is thread-unsafe.
      RUBY
    end
  end

  context 'when using Thread.start' do
    it 'registers an offense for class variable access' do
      expect_offense(<<~RUBY)
        Thread.start { @@count }
                       ^^^^^^^ Class variable `@@count` is thread-unsafe. Consider using a class instance variable, a mutex, or `Thread::local` instead.
      RUBY
    end

    it 'registers an offense for global variable mutation' do
      expect_offense(<<~RUBY)
        Thread.start { $output = StringIO.new }
                       ^^^^^^^ Mutating global variable `$output` is thread-unsafe.
      RUBY
    end
  end

  context 'when using Thread.fork' do
    it 'registers an offense for class variable access' do
      expect_offense(<<~RUBY)
        Thread.fork { @@count }
                      ^^^^^^^ Class variable `@@count` is thread-unsafe. Consider using a class instance variable, a mutex, or `Thread::local` instead.
      RUBY
    end
  end

  context 'when using Ractor.new' do
    it 'registers an offense for class variable access' do
      expect_offense(<<~RUBY)
        Ractor.new { @@count }
                     ^^^^^^^ Class variable `@@count` is thread-unsafe. Consider using a class instance variable, a mutex, or `Thread::local` instead.
      RUBY
    end

    it 'registers an offense for global variable mutation' do
      expect_offense(<<~RUBY)
        Ractor.new { $output = StringIO.new }
                     ^^^^^^^ Mutating global variable `$output` is thread-unsafe.
      RUBY
    end
  end

  context 'when inside a nested block within Thread.new' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Thread.new do
          items.each { @@count += 1 }
                       ^^^^^^^ Class variable `@@count` is thread-unsafe. Consider using a class instance variable, a mutex, or `Thread::local` instead.
        end
      RUBY
    end

    it 'registers an offense for global mutation in nested block' do
      expect_offense(<<~RUBY)
        Thread.new do
          3.times { $counter += 1 }
                    ^^^^^^^^ Mutating global variable `$counter` is thread-unsafe.
        end
      RUBY
    end
  end

  context 'when outside a thread block' do
    it 'does not register an offense for class variable read' do
      expect_no_offenses(<<~RUBY)
        @@count
      RUBY
    end

    it 'does not register an offense for class variable write' do
      expect_no_offenses(<<~RUBY)
        @@count = 0
      RUBY
    end

    it 'does not register an offense for class variable in a method' do
      expect_no_offenses(<<~RUBY)
        class Counter
          def increment
            @@count += 1
          end
        end
      RUBY
    end

    it 'does not register an offense for global variable mutation' do
      expect_no_offenses(<<~RUBY)
        $stdout = StringIO.new
      RUBY
    end

    it 'does not register an offense for global variable read' do
      expect_no_offenses(<<~RUBY)
        puts $LOAD_PATH
      RUBY
    end

    it 'does not register an offense inside a non-thread block' do
      expect_no_offenses(<<~RUBY)
        items.each { @@count += 1 }
      RUBY
    end
  end

  context 'when AllowedGlobalVariables is configured' do
    let(:cop_config) { { 'AllowedGlobalVariables' => %w[$stdout $stderr] } }

    it 'does not register an offense for allowed global writes' do
      expect_no_offenses(<<~RUBY)
        Thread.new { $stdout = StringIO.new }
      RUBY
    end

    it 'does not register an offense for another allowed global' do
      expect_no_offenses(<<~RUBY)
        Thread.new { $stderr = StringIO.new }
      RUBY
    end

    it 'still registers an offense for non-allowed global writes' do
      expect_offense(<<~RUBY)
        Thread.new { $output = StringIO.new }
                     ^^^^^^^ Mutating global variable `$output` is thread-unsafe.
      RUBY
    end

    it 'still registers an offense for class variable access' do
      expect_offense(<<~RUBY)
        Thread.new { @@count = 0 }
                     ^^^^^^^ Class variable `@@count` is thread-unsafe. Consider using a class instance variable, a mutex, or `Thread::local` instead.
      RUBY
    end
  end

  it 'does not autocorrect' do
    expect_offense(<<~RUBY)
      Thread.new { @@count = 0 }
                   ^^^^^^^ Class variable `@@count` is thread-unsafe. Consider using a class instance variable, a mutex, or `Thread::local` instead.
    RUBY

    expect_no_corrections
  end
end
