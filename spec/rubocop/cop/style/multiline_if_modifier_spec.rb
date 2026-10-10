# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::MultilineIfModifier, :config do
  context 'if guard clause' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        {
        ^ Favor a normal if-statement over a modifier clause in a multiline statement.
          result: run
        } if cond
      RUBY

      expect_correction(<<~RUBY)
        if cond
          {
            result: run
          }
        end
      RUBY
    end

    it 'allows a one liner' do
      expect_no_offenses(<<~RUBY)
        run if cond
      RUBY
    end

    it 'allows a multiline condition' do
      expect_no_offenses(<<~RUBY)
        run if cond &&
               cond2
      RUBY
    end

    it 'registers an offense when indented' do
      expect_offense(<<-RUBY.strip_margin('|'))
        |  {
        |  ^ Favor a normal if-statement over a modifier clause in a multiline statement.
        |    result: run
        |  } if cond
      RUBY

      expect_correction(<<-RUBY.strip_margin('|'))
        |  if cond
        |    {
        |      result: run
        |    }
        |  end
      RUBY
    end

    it 'registers an offense when nested modifier' do
      expect_offense(<<~RUBY)
        [
        ^ Favor a normal if-statement over a modifier clause in a multiline statement.
        ] if inner if outer
      RUBY

      expect_correction(<<~RUBY)
        if outer
          if inner
            [
            ]
          end
        end
      RUBY
    end

    it 'registers an offense when a heredoc is opened on the modifier line' do
      expect_offense(<<~RUBY)
        items.each { |item|
        ^^^^^^^^^^^^^^^^^^^ Favor a normal if-statement over a modifier clause in a multiline statement.
          foo(item, <<~EOS) } if cond
          text
        EOS
      RUBY

      expect_correction(<<~RUBY)
        if cond
          items.each { |item|
            foo(item, <<~EOS) }
          text
        EOS
        end
      RUBY
    end

    it 'registers an offense when a heredoc in the condition is opened on the modifier line' do
      expect_offense(<<~RUBY)
        foo(bar,
        ^^^^^^^^ Favor a normal if-statement over a modifier clause in a multiline statement.
            baz) if cond?(<<~EOS)
          text
        EOS
      RUBY

      expect_correction(<<~RUBY)
        if cond?(<<~EOS)
          text
        EOS
          foo(bar,
              baz)
        end
      RUBY
    end

    it 'registers an offense when several heredocs are opened on the modifier line' do
      expect_offense(<<~'RUBY')
        foo(bar,
        ^^^^^^^^ Favor a normal if-statement over a modifier clause in a multiline statement.
            <<~A, <<~B) if cond
          #{baz(<<~C)}
            c
          C
        A
          b
        B
        qux
      RUBY

      expect_correction(<<~'RUBY')
        if cond
          foo(bar,
              <<~A, <<~B)
          #{baz(<<~C)}
            c
          C
        A
          b
        B
        end
        qux
      RUBY
    end

    it 'registers an offense when the body contains a `<<-` heredoc' do
      expect_offense(<<~RUBY)
        items.each do |item|
        ^^^^^^^^^^^^^^^^^^^^ Favor a normal if-statement over a modifier clause in a multiline statement.
          foo(item, <<-EOS)
          text
          EOS
        end if cond
      RUBY

      expect_correction(<<~RUBY)
        if cond
          items.each do |item|
            foo(item, <<-EOS)
          text
          EOS
          end
        end
      RUBY
    end

    it 'registers an offense when the body contains a `<<` heredoc' do
      expect_offense(<<~RUBY)
        items.each do |item|
        ^^^^^^^^^^^^^^^^^^^^ Favor a normal if-statement over a modifier clause in a multiline statement.
          foo(item, <<EOS)
          text
        EOS
        end if cond
      RUBY

      expect_correction(<<~RUBY)
        if cond
          items.each do |item|
            foo(item, <<EOS)
          text
        EOS
          end
        end
      RUBY
    end

    it 'registers an offense when the body contains a squiggly heredoc' do
      expect_offense(<<~RUBY)
        items.each do |item|
        ^^^^^^^^^^^^^^^^^^^^ Favor a normal if-statement over a modifier clause in a multiline statement.
          foo(item, <<~EOS)
            text
          EOS
        end if cond
      RUBY

      expect_correction(<<~RUBY)
        if cond
          items.each do |item|
            foo(item, <<~EOS)
              text
            EOS
          end
        end
      RUBY
    end
  end

  context 'unless guard clause' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        {
        ^ Favor a normal unless-statement over a modifier clause in a multiline statement.
          result: run
        } unless cond
      RUBY

      expect_correction(<<~RUBY)
        unless cond
          {
            result: run
          }
        end
      RUBY
    end

    it 'allows a one liner' do
      expect_no_offenses(<<~RUBY)
        run unless cond
      RUBY
    end

    it 'allows a multiline condition' do
      expect_no_offenses(<<~RUBY)
        run unless cond &&
                   cond2
      RUBY
    end

    it 'registers an offense when indented' do
      expect_offense(<<-RUBY.strip_margin('|'))
        |  {
        |  ^ Favor a normal unless-statement over a modifier clause in a multiline statement.
        |    result: run
        |  } unless cond
      RUBY

      expect_correction(<<-RUBY.strip_margin('|'))
        |  unless cond
        |    {
        |      result: run
        |    }
        |  end
      RUBY
    end

    it 'registers an offense when nested modifier' do
      expect_offense(<<~RUBY)
        [
        ^ Favor a normal unless-statement over a modifier clause in a multiline statement.
        ] unless inner unless outer
      RUBY

      expect_correction(<<~RUBY)
        unless outer
          unless inner
            [
            ]
          end
        end
      RUBY
    end
  end
end
