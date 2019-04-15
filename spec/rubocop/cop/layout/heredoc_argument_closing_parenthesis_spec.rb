# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::HeredocArgumentClosingParenthesis do
  subject(:cop) { described_class.new }

  context 'correct cases' do
    it 'accepts simple correct case' do
      expect_no_offenses(<<-RUBY.strip_indent)
        foo(<<-SQL)
          foo
        SQL
      RUBY
    end

    it 'accepts double correct case' do
      expect_no_offenses(<<-RUBY.strip_indent)
        foo(<<-SQL, <<-NOSQL)
          foo
        SQL
          bar
        NOSQL
      RUBY
    end

    it 'accepts double correct case nested' do
      expect_no_offenses(<<-RUBY.strip_indent)
        baz(bar(foo(<<-SQL, <<-NOSQL)))
          foo
        SQL
          bar
        NOSQL
      RUBY
    end

    it 'accepts double correct case new line' do
      expect_no_offenses(<<-RUBY.strip_indent)
        foo(
          <<-SQL, <<-NOSQL)
          foo
        SQL
          bar
        NOSQL
      RUBY
    end

    it 'accepts correct case with other param after' do
      expect_no_offenses(<<-RUBY.strip_indent)
        foo(<<-SQL, 123)
          foo
        SQL
      RUBY
    end

    it 'accepts correct case with other param before' do
      expect_no_offenses(<<-RUBY.strip_indent)
        foo(123, <<-SQL)
          foo
        SQL
      RUBY
    end

    it 'accepts hash correct case' do
      expect_no_offenses(<<-RUBY.strip_indent)
        foo(foo: <<-SQL)
          foo
        SQL
      RUBY
    end

    context 'double case new line' do
      it 'ignores' do
        expect_no_offenses(<<-RUBY.strip_indent)
          foo(
            <<-SQL, <<-NOSQL
            foo
          SQL
            bar
          NOSQL
          )
        RUBY
      end
    end
  end

  context 'incorrect cases' do
    context 'simple incorrect case' do
      it 'detects' do
        expect_offense(<<-RUBY.strip_indent)
          foo(<<-SQL
            foo
          SQL
          )
          ^ Put the closing parenthesis for a method call with a HEREDOC paramater on the same line as the HEREDOC opening.
        RUBY
      end

      it 'autocorrects' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          foo(<<-SQL
            foo
          SQL
          )
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          foo(<<-SQL)
            foo
          SQL
        RUBY
      end
    end

    context 'simple incorrect case with call after' do
      it 'detects' do
        expect_offense(<<-RUBY.strip_indent)
          foo(<<-SQL.strip_indent
            foo
          SQL
          )
          ^ Put the closing parenthesis for a method call with a HEREDOC paramater on the same line as the HEREDOC opening.
        RUBY
      end

      it 'autocorrects' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          foo(<<-SQL.strip_indent
            foo
          SQL
          )
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          foo(<<-SQL.strip_indent)
            foo
          SQL
        RUBY
      end
    end

    context 'simple incorrect case with call after trailing comma' do
      it 'detects' do
        expect_offense(<<-RUBY.strip_indent)
          foo(<<-SQL.strip_indent,
            foo
          SQL
          )
          ^ Put the closing parenthesis for a method call with a HEREDOC paramater on the same line as the HEREDOC opening.
        RUBY
      end

      it 'autocorrects' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          foo(<<-SQL.strip_indent,
            foo
          SQL
          )
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          foo(<<-SQL.strip_indent)
            foo
          SQL
        RUBY
      end
    end

    context 'simple incorrect case hash' do
      it 'detects' do
        expect_offense(<<-RUBY.strip_indent)
          foo(foo: <<-SQL
            foo
          SQL
          )
          ^ Put the closing parenthesis for a method call with a HEREDOC paramater on the same line as the HEREDOC opening.
        RUBY
      end

      it 'autocorrects' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          foo(foo: <<-SQL
            foo
          SQL
          )
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          foo(foo: <<-SQL)
            foo
          SQL
        RUBY
      end
    end

    context 'nested incorrect case' do
      it 'detects' do
        expect_offense(<<-RUBY.strip_indent)
          foo(foo(<<-SQL)
            foo
          SQL
          )
          ^ Put the closing parenthesis for a method call with a HEREDOC paramater on the same line as the HEREDOC opening.
        RUBY
      end

      it 'autocorrects' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          foo(foo(<<-SQL)
            foo
          SQL
          )
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          foo(foo(<<-SQL))
            foo
          SQL
        RUBY
      end
    end

    context 'simple incorrect case squiggles', :ruby23 do
      it 'detects' do
        expect_offense(<<-RUBY.strip_indent)
          foo(<<~SQL
            foo
          SQL
          )
          ^ Put the closing parenthesis for a method call with a HEREDOC paramater on the same line as the HEREDOC opening.
        RUBY
      end

      it 'autocorrects' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          foo(<<~SQL
            foo
          SQL
          )
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          foo(<<~SQL)
            foo
          SQL
        RUBY
      end
    end

    context 'simple incorrect case comma' do
      it 'detects' do
        expect_offense(<<-RUBY.strip_indent)
          foo(<<-SQL,
            foo
          SQL
          )
          ^ Put the closing parenthesis for a method call with a HEREDOC paramater on the same line as the HEREDOC opening.
        RUBY
      end

      it 'autocorrects' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          foo(<<-SQL,
            foo
          SQL
          )
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          foo(<<-SQL)
            foo
          SQL
        RUBY
      end
    end

    context 'simple incorrect case comma with spaces' do
      it 'detects' do
        expect_offense(<<-RUBY.strip_indent)
          foo(<<-SQL    ,
            foo
          SQL
          )
          ^ Put the closing parenthesis for a method call with a HEREDOC paramater on the same line as the HEREDOC opening.
        RUBY
      end

      it 'autocorrects' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          foo(<<-SQL    ,
            foo
          SQL
          )
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          foo(<<-SQL)
            foo
          SQL
        RUBY
      end
    end

    context 'simple incorrect case comma with spaces and comma in heredoc' do
      it 'detects' do
        expect_offense(<<-RUBY.strip_indent)
          foo(<<-SQL    ,
            foo
          SQL
          )
          ^ Put the closing parenthesis for a method call with a HEREDOC paramater on the same line as the HEREDOC opening.
        RUBY
      end

      it 'autocorrects' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          foo(<<-SQL    ,
               ,
            foo
          SQL
          )
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          foo(<<-SQL)
               ,
            foo
          SQL
        RUBY
      end
    end

    context 'double incorrect case' do
      it 'detects ' do
        expect_offense(<<-RUBY.strip_indent)
          foo(<<-SQL, <<-NOSQL
            foo
          SQL
            bar
          NOSQL
          )
          ^ Put the closing parenthesis for a method call with a HEREDOC paramater on the same line as the HEREDOC opening.
        RUBY
      end

      it 'autocorrects' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          foo(<<-SQL, <<-NOSQL
            foo
          SQL
            bar
          NOSQL
          )
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
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
        expect_offense(<<-RUBY.strip_indent)
          foo(<<-SQL, <<-NOSQL
            foo
          SQL
            bar
          NOSQL
          ).bar(123).baz(456)
          ^ Put the closing parenthesis for a method call with a HEREDOC paramater on the same line as the HEREDOC opening.
        RUBY
      end

      it 'autocorrects' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          foo(<<-SQL, <<-NOSQL
            foo
          SQL
            bar
          NOSQL
          ).bar(123).baz(456)
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
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
        expect_offense(<<-RUBY.strip_indent)
          foo(<<-SQL, 123
            foo
          SQL
          )
          ^ Put the closing parenthesis for a method call with a HEREDOC paramater on the same line as the HEREDOC opening.
        RUBY
      end

      it 'autocorrects' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          foo(<<-SQL, 123
            foo
          SQL
          )
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          foo(<<-SQL, 123)
            foo
          SQL
        RUBY
      end
    end

    context 'incorrect case with other param before' do
      it 'detects' do
        expect_offense(<<-RUBY.strip_indent)
          foo(123, <<-SQL
            foo
          SQL
          )
          ^ Put the closing parenthesis for a method call with a HEREDOC paramater on the same line as the HEREDOC opening.
        RUBY
      end

      it 'autocorrects' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          foo(123, <<-SQL
            foo
          SQL
          )
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          foo(123, <<-SQL)
            foo
          SQL
        RUBY
      end
    end

    context 'incorrect case with other param before constructor' do
      it 'detects' do
        expect_offense(<<-RUBY.strip_indent)
          Foo.new(123, <<-SQL
            foo
          SQL
          )
          ^ Put the closing parenthesis for a method call with a HEREDOC paramater on the same line as the HEREDOC opening.
        RUBY
      end

      it 'autocorrects' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          Foo.new(123, <<-SQL
            foo
          SQL
          )
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          Foo.new(123, <<-SQL)
            foo
          SQL
        RUBY
      end
    end

    context 'incorrect case with other param before constructor' do
      it 'detects' do
        expect_offense(<<-RUBY.strip_indent)
          raise Foo.new(123, <<-SQL
            foo
          SQL
          )
          ^ Put the closing parenthesis for a method call with a HEREDOC paramater on the same line as the HEREDOC opening.
        RUBY
      end

      it 'autocorrects' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          raise Foo.new(123, <<-SQL
            foo
          SQL
          )
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          raise Foo.new(123, <<-SQL)
            foo
          SQL
        RUBY
      end
    end

    context 'incorrect case nested method call with comma' do
      it 'detects' do
        expect_offense(<<-RUBY.strip_indent)
          bar(
            foo(123, <<-SQL
              foo
            SQL
            ),
            ^ Put the closing parenthesis for a method call with a HEREDOC paramater on the same line as the HEREDOC opening.
            456,
            789,
          )
        RUBY
      end

      it 'autocorrects' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          bar(
            foo(123, <<-SQL
              foo
            SQL
            ),
            456,
            789,
          )
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
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
        expect_offense(<<-RUBY.strip_indent)
          [
            foo(123, <<-SQL
              foo
            SQL
            )      ,
            ^ Put the closing parenthesis for a method call with a HEREDOC paramater on the same line as the HEREDOC opening.
            456,
            789,
          ]
        RUBY
      end

      it 'autocorrects' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          [
            foo(123, <<-SQL
              foo
            SQL
            )      ,
            456,
            789,
          ]
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
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

    context 'incorrect case in array with spaced out comma' do
      it 'detects' do
        expect_offense(<<-RUBY.strip_indent)
          [
            foo(123, <<-SQL, 456, 789, <<-NOSQL,
              foo
            SQL
              bar
            NOSQL
            )      ,
            ^ Put the closing parenthesis for a method call with a HEREDOC paramater on the same line as the HEREDOC opening.
            456,
            789,
          ]
        RUBY
      end

      it 'autocorrects' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          [
            foo(123, <<-SQL, 456, 789, <<-NOSQL,
              foo
            SQL
              bar
            NOSQL
            )      ,
            456,
            789,
          ]
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
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

    context 'incorrect case in array with spaced out comma' do
      it 'detects' do
        expect_offense(<<-RUBY.strip_indent)
          [
            foo(foo(foo(123, <<-SQL, 456, 789, <<-NOSQL), 456), 400,
              foo
            SQL
              bar
            NOSQL
            )      ,
            ^ Put the closing parenthesis for a method call with a HEREDOC paramater on the same line as the HEREDOC opening.
            456,
            789,
          ]
        RUBY
      end

      it 'autocorrects' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          [
            foo(foo(foo(123, <<-SQL, 456, 789, <<-NOSQL), 456), 400,
              foo
            SQL
              bar
            NOSQL
            )      ,
            456,
            789,
          ]
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
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
  end
end
