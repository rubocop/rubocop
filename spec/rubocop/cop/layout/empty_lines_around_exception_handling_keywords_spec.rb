# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::EmptyLinesAroundExceptionHandlingKeywords, :config do
  let(:message) { '^{} Extra empty line detected' }

  shared_examples 'accepts' do |name, code|
    it "accepts #{name}" do
      expect_no_offenses(code)
    end
  end

  it 'registers an offense for above rescue keyword with a blank' do
    expect_offense(<<~RUBY)
      begin
        f1

      #{message} before the `rescue`.
      rescue
        f2
      end
    RUBY

    expect_correction(<<~RUBY)
      begin
        f1
      rescue
        f2
      end
    RUBY
  end

  it 'registers an offense for rescue section starting with a blank' do
    expect_offense(<<~RUBY)
      begin
        f1
      rescue

      #{message} after the `rescue`.
        f2
      end
    RUBY

    expect_correction(<<~RUBY)
      begin
        f1
      rescue
        f2
      end
    RUBY
  end

  it 'registers an offense for rescue section ending with a blank' do
    expect_offense(<<~RUBY)
      begin
        f1
      rescue
        f2

      #{message} before the `else`.
      else
        f3
      end
    RUBY

    expect_correction(<<~RUBY)
      begin
        f1
      rescue
        f2
      else
        f3
      end
    RUBY
  end

  it 'registers an offense for rescue section ending for method definition a blank' do
    expect_offense(<<~RUBY)
      def foo
        f1
      rescue
        f2

      #{message} before the `else`.
      else
        f3
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo
        f1
      rescue
        f2
      else
        f3
      end
    RUBY
  end

  include_examples 'accepts', 'no empty line', <<~RUBY
    begin
      f1
    rescue
      f2
    else
      f3
    ensure
      f4
    end
  RUBY

  include_examples 'accepts', 'empty lines around begin body', <<~RUBY
    begin

      f1

    end
  RUBY

  include_examples 'accepts', 'empty begin', <<~RUBY
    begin
    end
  RUBY

  include_examples 'accepts', 'empty method definition', <<~RUBY
    def foo
    end
  RUBY

  include_examples 'accepts', '`begin` and `rescue` are on the same line', <<~RUBY
    begin; foo; rescue => e; end
  RUBY

  include_examples 'accepts', '`rescue` and `end` are on the same line', <<~RUBY
    begin
      foo
    rescue => e; end
  RUBY

  include_examples 'accepts', 'last `rescue` and `end` are on the same line', <<~RUBY
    begin
      foo
    rescue => x
    rescue => y; end
  RUBY

  include_examples 'accepts', '`def` and `rescue` are on the same line', <<~RUBY
    def do_something; foo; rescue => e; end
  RUBY

  it 'with complex begin-end - registers many offenses' do
    expect_offense(<<~RUBY)
      begin

        do_something1

      #{message} before the `rescue`.
      rescue RuntimeError

      #{message} after the `rescue`.
        do_something2

      #{message} before the `rescue`.
      rescue ArgumentError => ex

      #{message} after the `rescue`.
        do_something3

      #{message} before the `rescue`.
      rescue

      #{message} after the `rescue`.
        do_something3

      #{message} before the `else`.
      else

      #{message} after the `else`.
        do_something4

      #{message} before the `ensure`.
      ensure

      #{message} after the `ensure`.
        do_something4

      end
    RUBY

    expect_correction(<<~RUBY)
      begin

        do_something1
      rescue RuntimeError
        do_something2
      rescue ArgumentError => ex
        do_something3
      rescue
        do_something3
      else
        do_something4
      ensure
        do_something4

      end
    RUBY
  end

  it 'with complex method definition - registers many offenses' do
    expect_offense(<<~RUBY)
      def foo

        do_something1

      #{message} before the `rescue`.
      rescue RuntimeError

      #{message} after the `rescue`.
        do_something2

      #{message} before the `rescue`.
      rescue ArgumentError => ex

      #{message} after the `rescue`.
        do_something3

      #{message} before the `rescue`.
      rescue

      #{message} after the `rescue`.
        do_something3

      #{message} before the `else`.
      else

      #{message} after the `else`.
        do_something4

      #{message} before the `ensure`.
      ensure

      #{message} after the `ensure`.
        do_something4

      end
    RUBY

    expect_correction(<<~RUBY)
      def foo

        do_something1
      rescue RuntimeError
        do_something2
      rescue ArgumentError => ex
        do_something3
      rescue
        do_something3
      else
        do_something4
      ensure
        do_something4

      end
    RUBY
  end
end
