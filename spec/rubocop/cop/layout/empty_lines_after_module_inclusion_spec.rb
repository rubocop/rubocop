# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::EmptyLinesAfterModuleInclusion, :config do
  described_class::MODULE_INCLUSION_METHODS.each do |method|
    it "registers an offense and corrects for code that immediately follows #{method}" do
      expect_offense(<<~RUBY, method: method)
        #{method} Foo
        ^{method}^^^^ Add an empty line after module inclusion.
        def do_something
        end
      RUBY

      expect_correction(<<~RUBY)
        #{method} Foo

        def do_something
        end
      RUBY
    end

    it "registers an offense and corrects for code that immediately follows #{method} with comment" do
      expect_offense(<<~RUBY, method: method)
        #{method} Foo # my comment
        ^{method}^^^^ Add an empty line after module inclusion.
        def do_something
        end
      RUBY

      expect_correction(<<~RUBY)
        #{method} Foo # my comment

        def do_something
        end
      RUBY
    end

    it "registers an offense and corrects for code that immediately follows #{method} and comment line" do
      expect_offense(<<~RUBY, method: method)
        #{method} Foo
        ^{method}^^^^ Add an empty line after module inclusion.
        # my comment
        def do_something
        end
      RUBY

      expect_correction(<<~RUBY)
        #{method} Foo

        # my comment
        def do_something
        end
      RUBY
    end

    it "registers an offense and corrects for #{method} and `rubocop:enable` comment line" do
      expect_offense(<<~RUBY, method: method)
        # rubocop:disable Department/Cop
        #{method} Foo
        ^{method}^^^^ Add an empty line after module inclusion.
        # rubocop:enable Department/Cop
        def do_something
        end
      RUBY

      expect_correction(<<~RUBY)
        # rubocop:disable Department/Cop
        #{method} Foo
        # rubocop:enable Department/Cop

        def do_something
        end
      RUBY
    end

    it "registers an offense and corrects for #{method} and `rubocop:enable` comment line and other comment" do
      expect_offense(<<~RUBY, method: method)
        # rubocop:disable Department/Cop
        #{method} Foo
        ^{method}^^^^ Add an empty line after module inclusion.
        # rubocop:enable Department/Cop
        # comment
        def do_something
        end
      RUBY

      expect_correction(<<~RUBY)
        # rubocop:disable Department/Cop
        #{method} Foo
        # rubocop:enable Department/Cop

        # comment
        def do_something
        end
      RUBY
    end

    it "registers an offense and corrects when #{method} has multiple arguments" do
      expect_offense(<<~RUBY, method: method)
        class Foo
          #{method} Bar, Baz
          ^{method}^^^^^^^^^ Add an empty line after module inclusion.
          def do_something
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo
          #{method} Bar, Baz

          def do_something
          end
        end
      RUBY
    end

    it "registers an offense and corrects for code that immediately follows #{method} inside a class" do
      expect_offense(<<~RUBY, method: method)
        class Bar
          #{method} Foo
          ^{method}^^^^ Add an empty line after module inclusion.
          def do_something
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class Bar
          #{method} Foo

          def do_something
          end
        end
      RUBY
    end

    it "registers an offense and corrects for code that immediately follows #{method} inside Class.new" do
      expect_offense(<<~RUBY, method: method)
        Class.new do
          #{method} Foo
          ^{method}^^^^ Add an empty line after module inclusion.
          def do_something
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        Class.new do
          #{method} Foo

          def do_something
          end
        end
      RUBY
    end

    it 'does not register an offense for #{method} separated from the code and `rubocop:enable` ' \
       'comment line with a newline' do
      expect_no_offenses(<<~RUBY)
        # rubocop:disable Department/Cop
        #{method} Foo
        # rubocop:enable Department/Cop

        def do_something
        end
      RUBY
    end

    it "does not register an offense for #{method} separated from the code with a newline" do
      expect_no_offenses(<<~RUBY)
        #{method} Foo

        def do_something
        end
      RUBY
    end

    it "does not register an offense for multiple #{method} methods separated from the code with a newline" do
      expect_no_offenses(<<~RUBY)
        #{method} Foo
        #{method} Foo

        def do_something
        end
      RUBY
    end

    it "does not register an offense when #{method} is used in class definition" do
      expect_no_offenses(<<~RUBY)
        module Baz
          class Bar
            #{method} Foo
          end
        end
      RUBY
    end

    it "does not register an offense when #{method} is used in Class.new" do
      expect_no_offenses(<<~RUBY)
        Class.new do
          #{method} Foo
        end
      RUBY
    end

    it "does not register an offense when #{method} is used with block method" do
      expect_no_offenses(<<~RUBY)
        #{method} Module.new do |arg|
          do_something(arg)
        end
      RUBY
    end

    it "does not register an offense when #{method} is used with numbered block method", :ruby27 do
      expect_no_offenses(<<~RUBY)
        #{method} Module.new do
          do_something(_1)
        end
      RUBY
    end

    it "does not register an offense when #{method} is used with `it` block method", :ruby34 do
      expect_no_offenses(<<~RUBY)
        #{method} Module.new do
          do_something(it)
        end
      RUBY
    end

    it "does not register an offense when using #{method} in `if` ... `else` branches" do
      expect_no_offenses(<<~RUBY)
        if condition
          #{method} Foo
        else
          do_something
        end
      RUBY
    end

    it "does not register an offense where #{method} is the last line" do
      expect_no_offenses("#{method} Foo")
    end
  end

  it 'does not register an offense when there are multiple grouped module inclusion methods' do
    expect_no_offenses(<<~RUBY)
      module Foo
        module Bar
          extend Baz
          prepend Baz
          include Baz
        end
      end
    RUBY
  end

  it 'does not register an offense for RSpec matcher `include`' do
    expect_no_offenses(<<~RUBY)
      it 'something' do
        expect(foo).to include(bar), "baz"
      end
    RUBY
  end

  it 'does not register an offense for `include` inside an array' do
    expect_no_offenses(<<~RUBY)
      it 'something' do
        match([include(foo), anything])
      end
    RUBY
  end

  it 'does not register an offense when `include` has zero arguments' do
    expect_no_offenses(<<~RUBY)
      class Foo
        includes = [include, sdk_include].compact.map do |inc|
          inc + "blah"
        end.join(' ')
      end
    RUBY
  end

  it 'does not register an offense when module inclusion is called with modifier' do
    expect_no_offenses(<<~RUBY)
      class Foo
        include Bar
        include Baz if condition
        include Qux
      end
    RUBY
  end
end
