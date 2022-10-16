# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantBegin, :config do
  it 'reports an offense for single line def with redundant begin block' do
    expect_offense(<<~RUBY)
      def func; begin; x; y; rescue; z end; end
                ^^^^^ Redundant `begin` block detected.
    RUBY

    expect_correction(<<~RUBY)
      def func; ; x; y; rescue; z ; end
    RUBY
  end

  it 'reports an offense for def with redundant begin block' do
    expect_offense(<<~RUBY)
      def func
        begin
        ^^^^^ Redundant `begin` block detected.
          ala
        rescue => e
          bala
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      def func
       #{trailing_whitespace}
          ala
        rescue => e
          bala
       #{trailing_whitespace}
      end
    RUBY
  end

  it 'reports an offense for defs with redundant begin block' do
    expect_offense(<<~RUBY)
      def Test.func
        begin
        ^^^^^ Redundant `begin` block detected.
          ala
        rescue => e
          bala
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      def Test.func
       #{trailing_whitespace}
          ala
        rescue => e
          bala
       #{trailing_whitespace}
      end
    RUBY
  end

  it 'accepts a def with required begin block' do
    expect_no_offenses(<<~RUBY)
      def func
        begin
          ala
        rescue => e
          bala
        end
        something
      end
    RUBY
  end

  it 'accepts a defs with required begin block' do
    expect_no_offenses(<<~RUBY)
      def Test.func
        begin
          ala
        rescue => e
          bala
        end
        something
      end
    RUBY
  end

  it 'accepts a def with a begin block after a statement' do
    expect_no_offenses(<<~RUBY)
      def Test.func
        something
        begin
          ala
        rescue => e
          bala
        end
      end
    RUBY
  end

  it "doesn't modify spacing when autocorrecting" do
    expect_offense(<<~RUBY)
      def method
        begin
        ^^^^^ Redundant `begin` block detected.
          BlockA do |strategy|
            foo
          end

          BlockB do |portfolio|
            foo
          end

        rescue => e # some problem
          bar
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      def method
       #{trailing_whitespace}
          BlockA do |strategy|
            foo
          end

          BlockB do |portfolio|
            foo
          end

        rescue => e # some problem
          bar
       #{trailing_whitespace}
      end
    RUBY
  end

  it 'autocorrects when there are trailing comments' do
    expect_offense(<<~RUBY)
      def method
        begin # comment 1
        ^^^^^ Redundant `begin` block detected.
          do_some_stuff
        rescue # comment 2
        end # comment 3
      end
    RUBY

    expect_correction(<<~RUBY)
      def method
         # comment 1
          do_some_stuff
        rescue # comment 2
         # comment 3
      end
    RUBY
  end

  it 'registers an offense and corrects when using `begin` without `rescue` or `ensure`' do
    expect_offense(<<~RUBY)
      begin
      ^^^^^ Redundant `begin` block detected.
        do_something
      end
    RUBY

    expect_correction("\n  do_something\n\n")
  end

  it 'does not register an offense when using `begin` with `rescue`' do
    expect_no_offenses(<<~RUBY)
      begin
        do_something
      rescue
        handle_exception
      end
    RUBY
  end

  it 'does not register an offense when using `begin` with `ensure`' do
    expect_no_offenses(<<~RUBY)
      begin
        do_something
      ensure
        finalize
      end
    RUBY
  end

  it 'does not register an offense when using `begin` for assignment' do
    expect_no_offenses(<<~RUBY)
      var = begin
        foo
        bar
      end
    RUBY
  end

  it 'registers and corrects an offense when using `begin` with single statement for or assignment' do
    expect_offense(<<~RUBY)
      # outer comment
      var ||= begin # inner comment 1
              ^^^^^ Redundant `begin` block detected.
        # inner comment 2
        foo
        # inner comment 3
      end
    RUBY

    expect_correction(<<~RUBY)
      # outer comment
       # inner comment 1
        # inner comment 2
        var ||= foo
        # inner comment 3

    RUBY
  end

  it 'registers and corrects an offense when using `begin` with single statement that called a block for or assignment' do
    expect_offense(<<~RUBY)
      var ||= begin
              ^^^^^ Redundant `begin` block detected.
        foo do |arg|
          bar
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      var ||= foo do |arg|
          bar
        end

    RUBY
  end

  it 'registers and corrects an offense when using modifier `if` single statement in `begin` block' do
    expect_offense(<<~RUBY)
      var ||= begin
              ^^^^^ Redundant `begin` block detected.
        foo if condition
      end
    RUBY

    expect_correction(<<~RUBY)
      var ||= (foo if condition)

    RUBY
  end

  it 'registers and corrects an offense when using multi-line `if` in `begin` block' do
    expect_offense(<<~RUBY)
      var ||= begin
              ^^^^^ Redundant `begin` block detected.
        if condition
          foo
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      var ||= if condition
          foo
        end\n
    RUBY
  end

  it 'does not register an offense when using `begin` with multiple statement for or assignment' do
    expect_no_offenses(<<~RUBY)
      var ||= begin
        foo
        bar
      end
    RUBY
  end

  it 'does not register an offense when using `begin` with no statements for or assignment' do
    expect_no_offenses(<<~RUBY)
      var ||= begin
      end
    RUBY
  end

  it 'does not register an offense when using `begin` with `while`' do
    expect_no_offenses(<<~RUBY)
      begin
        do_first_thing
        some_value = do_second_thing
      end while some_value
    RUBY
  end

  it 'does not register an offense when using `begin` with `until`' do
    expect_no_offenses(<<~RUBY)
      begin
        do_first_thing
        some_value = do_second_thing
      end until some_value
    RUBY
  end

  it 'does not register an offense when using body of `begin` is empty' do
    expect_no_offenses(<<~RUBY)
      begin
      end
    RUBY
  end

  it 'does not register an offense when using `begin` for or assignment and method call' do
    expect_no_offenses(<<~RUBY)
      var ||= begin
        foo
        bar
      end.baz do
        qux
      end
    RUBY
  end

  it 'does not register an offense when using `begin` for method argument' do
    expect_no_offenses(<<~RUBY)
      do_something begin
        foo
        bar
      end
    RUBY
  end

  it 'does not register an offense when using `begin` for logical operator conditions' do
    expect_no_offenses(<<~RUBY)
      condition && begin
        foo
        bar
      end
    RUBY
  end

  it 'does not register an offense when using `begin` for semantic operator conditions' do
    expect_no_offenses(<<~RUBY)
      condition and begin
        foo
        bar
      end
    RUBY
  end

  context '< Ruby 2.5', :ruby24 do
    it 'accepts a do-end block with a begin-end' do
      expect_no_offenses(<<~RUBY)
        do_something do
          begin
            foo
          rescue => e
            bar
          end
        end
      RUBY
    end
  end

  context '>= ruby 2.5', :ruby25 do
    it 'registers an offense for a do-end block with redundant begin-end' do
      expect_offense(<<~RUBY)
        do_something do
          begin
          ^^^^^ Redundant `begin` block detected.
            foo
          rescue => e
            bar
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        do_something do
         #{trailing_whitespace}
            foo
          rescue => e
            bar
         #{trailing_whitespace}
        end
      RUBY
    end

    it 'accepts a {} block with a begin-end' do
      expect_no_offenses(<<~RUBY)
        do_something {
          begin
            foo
          rescue => e
            bar
          end
        }
      RUBY
    end

    it 'accepts a block with a begin block after a statement' do
      expect_no_offenses(<<~RUBY)
        do_something do
          something
          begin
            ala
          rescue => e
            bala
          end
        end
      RUBY
    end

    it 'accepts a stabby lambda with a begin-end' do
      expect_no_offenses(<<~RUBY)
        -> do
          begin
            foo
          rescue => e
            bar
          end
        end
      RUBY
    end

    it 'accepts super with block' do
      expect_no_offenses(<<~RUBY)
        def a_method
          super do |arg|
            foo
          rescue => e
            bar
          end
        end
      RUBY
    end
  end

  it 'accepts when one-liner `begin` block has multiple statements with modifier condition' do
    expect_no_offenses(<<~RUBY)
      begin foo; bar; end unless condition
    RUBY
  end

  it 'accepts when multi-line `begin` block has multiple statements with modifier condition' do
    expect_no_offenses(<<~RUBY)
      begin
        foo; bar
      end unless condition
    RUBY
  end

  it 'reports an offense when one-liner `begin` block has single statement with modifier condition' do
    expect_offense(<<~RUBY)
      begin foo end unless condition
      ^^^^^ Redundant `begin` block detected.
    RUBY

    expect_correction(" foo  unless condition\n")
  end

  it 'reports an offense when multi-line `begin` block has single statement with modifier condition' do
    expect_offense(<<~RUBY)
      begin
      ^^^^^ Redundant `begin` block detected.
        foo
      end unless condition
    RUBY

    expect_correction("\n  foo unless condition\n")
  end

  it 'reports an offense when multi-line `begin` block has single statement and it is inside condition' do
    expect_offense(<<~RUBY)
      unless condition
        begin
        ^^^^^ Redundant `begin` block detected.
          foo
        end
      end
    RUBY

    expect_correction("unless condition\n  \n    foo\n  \nend\n")
  end

  it 'reports an offense when assigning nested `begin` blocks' do
    expect_offense(<<~RUBY)
      @foo ||= begin
        @bar ||= begin
                 ^^^^^ Redundant `begin` block detected.
          baz
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      @foo ||= @bar ||= baz
      #{trailing_whitespace * 2}

    RUBY
  end

  it 'reports an offense when assigning nested blocks which contain `begin` blocks' do
    expect_offense(<<~RUBY)
      var = do_something do
        begin
        ^^^^^ Redundant `begin` block detected.
          do_something do
            begin
            ^^^^^ Redundant `begin` block detected.
              foo
            ensure
              bar
            end
          end
        ensure
          baz
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      var = do_something do
       #{trailing_whitespace}
          do_something do
           #{trailing_whitespace}
              foo
            ensure
              bar
           #{trailing_whitespace}
          end
        ensure
          baz
       #{trailing_whitespace}
      end
    RUBY
  end

  context 'Ruby 2.7', :ruby27 do
    it 'reports an offense when assigning nested blocks which contain `begin` blocks' do
      expect_offense(<<~RUBY)
        var = do_something do
          begin
          ^^^^^ Redundant `begin` block detected.
            do_something do
              begin
              ^^^^^ Redundant `begin` block detected.
                _1
              ensure
                bar
              end
            end
          ensure
            baz
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        var = do_something do
         #{trailing_whitespace}
            do_something do
             #{trailing_whitespace}
                _1
              ensure
                bar
             #{trailing_whitespace}
            end
          ensure
            baz
         #{trailing_whitespace}
        end
      RUBY
    end
  end

  context 'when using endless method definition', :ruby30 do
    it 'registers when `begin` block has a single statement' do
      expect_offense(<<~RUBY)
        def foo = begin
                  ^^^^^ Redundant `begin` block detected.
          bar
        end
      RUBY

      expect_correction("def foo = \n  bar\n\n")
    end

    it 'accepts when `begin` block has multiple statements' do
      expect_no_offenses(<<~RUBY)
        def foo = begin
          bar
          baz
        end
      RUBY
    end

    it 'accepts when `begin` block has no statements' do
      expect_no_offenses(<<~RUBY)
        def foo = begin
        end
      RUBY
    end
  end
end
