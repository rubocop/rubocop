# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::HeredocArgumentClosingParenthesis, :config do
  context 'correct cases' do
    it 'accepts simple correct case' do
      expect_no_offenses(<<~RUBY)
        foo(<<-SQL)
          foo
        SQL
      RUBY
    end

    it 'accepts double correct case' do
      expect_no_offenses(<<~RUBY)
        foo(<<-SQL, <<-NOSQL)
          foo
        SQL
          bar
        NOSQL
      RUBY
    end

    it 'accepts method chain with heredoc argument correct case' do
      expect_no_offenses(<<~RUBY)
        do_something(
          Model
            .foo(<<~CODE)
              code
            CODE
            .bar(<<~CODE))
              code
            CODE
      RUBY
    end

    it 'accepts method with heredoc argument of proc correct case' do
      expect_no_offenses(<<~RUBY)
        outer_method(-> {
          inner_method(<<~CODE)
            code
          CODE
        })
      RUBY
    end

    it 'accepts double correct case nested' do
      expect_no_offenses(<<~RUBY)
        baz(bar(foo(<<-SQL, <<-NOSQL)))
          foo
        SQL
          bar
        NOSQL
      RUBY
    end

    it 'accepts double correct case new line' do
      expect_no_offenses(<<~RUBY)
        foo(
          <<-SQL, <<-NOSQL)
          foo
        SQL
          bar
        NOSQL
      RUBY
    end

    it 'accepts when there is an argument between a heredoc argument and the closing parentheses' do
      expect_no_offenses(<<~RUBY)
        foo(<<~TEXT,
            Lots of
            Lovely
            Text
          TEXT
          some_arg: { foo: "bar" }
        )
      RUBY
    end

    it 'accepts when heredoc is a method argument in a parenthesized block argument' do
      expect_no_offenses(<<~RUBY)
        foo(bar do
          baz <<~EOS
          EOS
        end)
      RUBY
    end

    it 'accepts when heredoc is a branch body in a method argument of a parenthesized argument' do
      expect_no_offenses(<<~RUBY)
        foo(unless condition
          bar(<<~EOS)
            text
          EOS
        end)
      RUBY
    end

    it 'accepts when heredoc is a branch body in a nested method argument of a parenthesized argument' do
      expect_no_offenses(<<~RUBY)
        foo(unless condition
          bar(baz(<<~EOS))
            text
          EOS
        end)
      RUBY
    end

    it 'accepts correct case with other param after' do
      expect_no_offenses(<<~RUBY)
        foo(<<-SQL, 123)
          foo
        SQL
      RUBY
    end

    it 'accepts correct case with other param before' do
      expect_no_offenses(<<~RUBY)
        foo(123, <<-SQL)
          foo
        SQL
      RUBY
    end

    it 'accepts hash correct case' do
      expect_no_offenses(<<~RUBY)
        foo(foo: <<-SQL)
          foo
        SQL
      RUBY
    end

    context 'invocation after the HEREDOC' do
      it 'ignores tr' do
        expect_no_offenses(<<~RUBY)
          foo(
            <<-SQL.tr("z", "t"))
            baz
          SQL
        RUBY
      end

      it 'ignores random call' do
        expect_no_offenses(<<~RUBY)
          description(
            <<-TEXT.foo)
            foobarbaz
          TEXT
        RUBY
      end

      it 'ignores random call after' do
        expect_no_offenses(<<~RUBY)
          description(
            <<-TEXT
            foobarbaz
          TEXT
          .foo
          )
        RUBY
      end
    end
  end

  context 'incorrect cases' do
    context 'simple incorrect case' do
      it 'detects' do
        expect_offense(<<~RUBY)
          foo(<<-SQL
            foo
          SQL
          )
          ^ Put the closing parenthesis for a method call with a HEREDOC parameter on the same line as the HEREDOC opening.
        RUBY

        expect_correction(<<~RUBY)
          foo(<<-SQL)
            foo
          SQL
        RUBY
      end
    end

    context 'simple incorrect case with call after' do
      it 'detects' do
        expect_offense(<<~RUBY)
          foo(<<~SQL
            foo
          SQL
          ).bar
          ^ Put the closing parenthesis for a method call with a HEREDOC parameter on the same line as the HEREDOC opening.
        RUBY

        expect_correction(<<~RUBY)
          foo(<<~SQL)
            foo
          SQL
          .bar
        RUBY
      end
    end

    context 'simple incorrect case with call after trailing comma' do
      it 'detects' do
        expect_offense(<<~RUBY)
          foo(<<~SQL,
            foo
          SQL
          ).bar
          ^ Put the closing parenthesis for a method call with a HEREDOC parameter on the same line as the HEREDOC opening.
        RUBY

        expect_correction(<<~RUBY)
          foo(<<~SQL)
            foo
          SQL
          .bar
        RUBY
      end
    end

    context 'simple incorrect case hash' do
      it 'detects' do
        expect_offense(<<~RUBY)
          foo(foo: <<-SQL
            foo
          SQL
          )
          ^ Put the closing parenthesis for a method call with a HEREDOC parameter on the same line as the HEREDOC opening.
        RUBY

        expect_correction(<<~RUBY)
          foo(foo: <<-SQL)
            foo
          SQL
        RUBY
      end
    end

    context 'nested incorrect case' do
      it 'detects' do
        expect_offense(<<~RUBY)
          foo(foo(<<-SQL)
            foo
          SQL
          )
          ^ Put the closing parenthesis for a method call with a HEREDOC parameter on the same line as the HEREDOC opening.
        RUBY

        expect_correction(<<~RUBY)
          foo(foo(<<-SQL))
            foo
          SQL
        RUBY
      end
    end

    context 'simple incorrect case squiggles' do
      it 'detects' do
        expect_offense(<<~RUBY)
          foo(<<~SQL
            foo
          SQL
          )
          ^ Put the closing parenthesis for a method call with a HEREDOC parameter on the same line as the HEREDOC opening.
        RUBY

        expect_correction(<<~RUBY)
          foo(<<~SQL)
            foo
          SQL
        RUBY
      end
    end

    context 'simple incorrect case comma' do
      it 'detects' do
        expect_offense(<<~RUBY)
          foo(<<-SQL,
            foo
          SQL
          )
          ^ Put the closing parenthesis for a method call with a HEREDOC parameter on the same line as the HEREDOC opening.
        RUBY

        expect_correction(<<~RUBY)
          foo(<<-SQL)
            foo
          SQL
        RUBY
      end
    end

    context 'simple incorrect case comma with spaces' do
      it 'detects' do
        expect_offense(<<~RUBY)
          foo(<<-SQL    ,
            foo
          SQL
          )
          ^ Put the closing parenthesis for a method call with a HEREDOC parameter on the same line as the HEREDOC opening.
        RUBY

        expect_correction(<<~RUBY)
          foo(<<-SQL)
            foo
          SQL
        RUBY
      end
    end

    context 'simple incorrect case comma with spaces and comma in heredoc' do
      it 'detects' do
        expect_offense(<<~RUBY)
          foo(<<-SQL    ,
            foo,
          SQL
          )
          ^ Put the closing parenthesis for a method call with a HEREDOC parameter on the same line as the HEREDOC opening.
        RUBY

        expect_correction(<<~RUBY)
          foo(<<-SQL)
            foo,
          SQL
        RUBY
      end
    end

    context 'double incorrect case' do
      it 'detects' do
        expect_offense(<<~RUBY)
          foo(<<-SQL, <<-NOSQL
            foo
          SQL
            bar
          NOSQL
          )
          ^ Put the closing parenthesis for a method call with a HEREDOC parameter on the same line as the HEREDOC opening.
        RUBY

        expect_correction(<<~RUBY)
          foo(<<-SQL, <<-NOSQL)
            foo
          SQL
            bar
          NOSQL
        RUBY
      end
    end

    context 'double incorrect case new line chained calls' do
      it 'detects' do
        expect_offense(<<~RUBY)
          foo(<<-SQL, <<-NOSQL
            foo
          SQL
            bar
          NOSQL
          ).bar(123).baz(456)
          ^ Put the closing parenthesis for a method call with a HEREDOC parameter on the same line as the HEREDOC opening.
        RUBY

        expect_correction(<<~RUBY)
          foo(<<-SQL, <<-NOSQL)
            foo
          SQL
            bar
          NOSQL
          .bar(123).baz(456)
        RUBY
      end
    end

    context 'incorrect case with other param after' do
      it 'detects' do
        expect_offense(<<~RUBY)
          foo(<<-SQL, 123
            foo
          SQL
          )
          ^ Put the closing parenthesis for a method call with a HEREDOC parameter on the same line as the HEREDOC opening.
        RUBY

        expect_correction(<<~RUBY)
          foo(<<-SQL, 123)
            foo
          SQL
        RUBY
      end
    end

    context 'incorrect case with other param before' do
      it 'detects' do
        expect_offense(<<~RUBY)
          foo(123, <<-SQL
            foo
          SQL
          )
          ^ Put the closing parenthesis for a method call with a HEREDOC parameter on the same line as the HEREDOC opening.
        RUBY

        expect_correction(<<~RUBY)
          foo(123, <<-SQL)
            foo
          SQL
        RUBY
      end
    end

    context 'incorrect case with other param before constructor' do
      it 'detects' do
        expect_offense(<<~RUBY)
          Foo.new(123, <<-SQL
            foo
          SQL
          )
          ^ Put the closing parenthesis for a method call with a HEREDOC parameter on the same line as the HEREDOC opening.
        RUBY

        expect_correction(<<~RUBY)
          Foo.new(123, <<-SQL)
            foo
          SQL
        RUBY
      end
    end

    context 'incorrect case with other param before constructor and raise call' do
      it 'detects' do
        expect_offense(<<~RUBY)
          raise Foo.new(123, <<-SQL
            foo
          SQL
          )
          ^ Put the closing parenthesis for a method call with a HEREDOC parameter on the same line as the HEREDOC opening.
        RUBY

        expect_correction(<<~RUBY)
          raise Foo.new(123, <<-SQL)
            foo
          SQL
        RUBY
      end
    end

    context 'incorrect case nested method call with comma' do
      it 'detects' do
        expect_offense(<<~RUBY)
          bar(
            foo(123, <<-SQL
              foo
            SQL
            ),
            ^ Put the closing parenthesis for a method call with a HEREDOC parameter on the same line as the HEREDOC opening.
            456,
            789,
          )
        RUBY

        expect_correction(<<~RUBY, loop: false)
          bar(
            foo(123, <<-SQL),
              foo
            SQL
            456,
            789,
          )
        RUBY
      end
    end

    context 'incorrect case in array with spaced out comma' do
      it 'detects' do
        expect_offense(<<~RUBY)
          [
            foo(123, <<-SQL
              foo
            SQL
            )      ,
            ^ Put the closing parenthesis for a method call with a HEREDOC parameter on the same line as the HEREDOC opening.
            456,
            789,
          ]
        RUBY

        expect_correction(<<~RUBY)
          [
            foo(123, <<-SQL),
              foo
            SQL
            456,
            789,
          ]
        RUBY
      end
    end

    context 'incorrect case in array with double heredoc and spaced out comma' do
      it 'detects' do
        expect_offense(<<~RUBY)
          [
            foo(123, <<-SQL, 456, 789, <<-NOSQL,
              foo
            SQL
              bar
            NOSQL
            )      ,
            ^ Put the closing parenthesis for a method call with a HEREDOC parameter on the same line as the HEREDOC opening.
            456,
            789,
          ]
        RUBY

        expect_correction(<<~RUBY)
          [
            foo(123, <<-SQL, 456, 789, <<-NOSQL),
              foo
            SQL
              bar
            NOSQL
            456,
            789,
          ]
        RUBY
      end
    end

    context 'incorrect case in array with nested calls and double heredoc and spaced out comma' do
      it 'detects' do
        expect_offense(<<~RUBY)
          [
            foo(foo(foo(123, <<-SQL, 456, 789, <<-NOSQL), 456), 400,
              foo
            SQL
              bar
            NOSQL
            )      ,
            ^ Put the closing parenthesis for a method call with a HEREDOC parameter on the same line as the HEREDOC opening.
            456,
            789,
          ]
        RUBY

        expect_correction(<<~RUBY)
          [
            foo(foo(foo(123, <<-SQL, 456, 789, <<-NOSQL), 456), 400),
              foo
            SQL
              bar
            NOSQL
            456,
            789,
          ]
        RUBY
      end
    end

    context 'complex incorrect case with multiple calls' do
      it 'detects and fixes the first' do
        expect_offense(<<~RUBY)
          query.order(Arel.sql(<<-SQL,
            foo
          SQL
                              ))
                              ^ Put the closing parenthesis for a method call with a HEREDOC parameter on the same line as the HEREDOC opening.
        RUBY

        expect_correction(<<~RUBY, loop: false)
          query.order(Arel.sql(<<-SQL)
            foo
          SQL
                              )
        RUBY
      end

      it 'detects and fixes the second' do
        expect_offense(<<~RUBY)
          query.order(Arel.sql(<<-SQL)
            foo
          SQL
                              )
                              ^ Put the closing parenthesis for a method call with a HEREDOC parameter on the same line as the HEREDOC opening.
        RUBY

        expect_correction(<<~RUBY)
          query.order(Arel.sql(<<-SQL))
            foo
          SQL
        RUBY
      end
    end

    context 'complex chained incorrect case with multiple calls' do
      it 'detects and fixes the first' do
        expect_offense(<<~RUBY)
          query.joins({
            foo: []
          }).order(Arel.sql(<<-SQL),
            bar
          SQL
                  )
                  ^ Put the closing parenthesis for a method call with a HEREDOC parameter on the same line as the HEREDOC opening.
        RUBY

        expect_correction(<<~RUBY)
          query.joins({
            foo: []
          }).order(Arel.sql(<<-SQL))
            bar
          SQL
        RUBY
      end
    end

    context 'double case new line' do
      it 'detects and fixes' do
        expect_offense(<<~RUBY)
          foo(
            <<-SQL, <<-NOSQL
            foo
          SQL
            bar
          NOSQL
          )
          ^ Put the closing parenthesis for a method call with a HEREDOC parameter on the same line as the HEREDOC opening.
        RUBY

        expect_correction(<<~RUBY)
          foo(
            <<-SQL, <<-NOSQL)
            foo
          SQL
            bar
          NOSQL
        RUBY
      end
    end
  end
end
