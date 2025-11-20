# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::TrailingCommaInArguments, :config do
  shared_examples 'single line lists' do |extra_info|
    [%w[( )], %w[[ ]]].each do |start_bracket, end_bracket|
      context "with `#{start_bracket}#{end_bracket}` brackets" do
        it 'registers an offense for trailing comma in a method call' do
          expect_offense(<<~RUBY, start_bracket: start_bracket, end_bracket: end_bracket)
            some_method#{start_bracket}a, b, c, #{end_bracket}
                        _{start_bracket}      ^ Avoid comma after the last parameter of a method call#{extra_info}.
          RUBY

          expect_correction(<<~RUBY)
            some_method#{start_bracket}a, b, c #{end_bracket}
          RUBY
        end

        it 'registers an offense for trailing comma preceded by whitespace in a method call' do
          expect_offense(<<~RUBY, start_bracket: start_bracket, end_bracket: end_bracket)
            some_method#{start_bracket}a, b, c , #{end_bracket}
                      _{start_bracket}         ^ Avoid comma after the last parameter of a method call#{extra_info}.
          RUBY

          expect_correction(<<~RUBY)
            some_method#{start_bracket}a, b, c  #{end_bracket}
          RUBY
        end

        it 'registers an offense for trailing comma in a method call with hash parameters at the end' do
          expect_offense(<<~RUBY, start_bracket: start_bracket, end_bracket: end_bracket)
            some_method#{start_bracket}a, b, c: 0, d: 1, #{end_bracket}
                      _{start_bracket}                 ^ Avoid comma after the last parameter of a method call#{extra_info}.
          RUBY

          expect_correction(<<~RUBY)
            some_method#{start_bracket}a, b, c: 0, d: 1 #{end_bracket}
          RUBY
        end

        it 'accepts method call without trailing comma' do
          expect_no_offenses("some_method#{start_bracket}a, b, c#{end_bracket}")
        end

        it 'accepts method call without trailing comma when a line break before a method call' do
          expect_no_offenses(<<~RUBY)
            obj
              .do_something#{start_bracket}:foo, :bar#{end_bracket}
          RUBY
        end

        it 'accepts method call without trailing comma with single element hash ' \
           'parameters at the end' do
          expect_no_offenses("some_method#{start_bracket}a: 1#{end_bracket}")
        end

        it 'accepts method call without parameters' do
          expect_no_offenses('some_method')
        end

        it 'accepts chained single-line method calls' do
          expect_no_offenses(<<~RUBY)
            target
              .some_method#{start_bracket}a#{end_bracket}
          RUBY
        end

        context 'when using safe navigation operator' do
          it 'registers an offense for trailing comma in a method call' do
            expect_offense(<<~RUBY, start_bracket: start_bracket, end_bracket: end_bracket)
              receiver&.some_method#{start_bracket}a, b, c, #{end_bracket}
                                  _{start_bracket}        ^ Avoid comma after the last parameter of a method call#{extra_info}.
            RUBY

            expect_correction(<<~RUBY)
              receiver&.some_method#{start_bracket}a, b, c #{end_bracket}
            RUBY
          end

          it 'registers an offense for trailing comma in a method call with hash ' \
             'parameters at the end' do
            expect_offense(<<~RUBY, start_bracket: start_bracket, end_bracket: end_bracket)
              receiver&.some_method#{start_bracket}a, b, c: 0, d: 1, #{end_bracket}
                                  _{start_bracket}                 ^ Avoid comma after the last parameter of a method call#{extra_info}.
            RUBY

            expect_correction(<<~RUBY)
              receiver&.some_method#{start_bracket}a, b, c: 0, d: 1 #{end_bracket}
            RUBY
          end
        end
      end
    end

    it 'accepts method call without parameters' do
      expect_no_offenses('some_method')
    end

    it 'accepts heredoc without trailing comma' do
      expect_no_offenses(<<~RUBY)
        route(1, <<-HELP.chomp)
        ...
        HELP
      RUBY
    end
  end

  context 'with single line list of values' do
    context 'when EnforcedStyleForMultiline is no_comma' do
      let(:cop_config) { { 'EnforcedStyleForMultiline' => 'no_comma' } }

      it_behaves_like 'single line lists', ''
    end

    context 'when EnforcedStyleForMultiline is comma' do
      let(:cop_config) { { 'EnforcedStyleForMultiline' => 'comma' } }

      it_behaves_like 'single line lists', ', unless each item is on its own line'
    end

    context 'when EnforcedStyleForMultiline is diff_comma' do
      let(:cop_config) { { 'EnforcedStyleForMultiline' => 'diff_comma' } }

      it_behaves_like 'single line lists', ', unless that item immediately precedes a newline'
    end

    context 'when EnforcedStyleForMultiline is consistent_comma' do
      let(:cop_config) { { 'EnforcedStyleForMultiline' => 'consistent_comma' } }

      it_behaves_like 'single line lists', ', unless items are split onto multiple lines'
    end
  end

  context 'with a single argument spanning multiple lines' do
    context 'when EnforcedStyleForMultiline is consistent_comma' do
      let(:cop_config) { { 'EnforcedStyleForMultiline' => 'consistent_comma' } }

      [%w[( )], %w[[ ]]].each do |start_bracket, end_bracket|
        context "with `#{start_bracket}#{end_bracket}` brackets" do
          it 'accepts a single argument with no trailing comma' do
            expect_no_offenses(<<~RUBY)
              EmailWorker.perform_async#{start_bracket}{
                subject: "hey there",
                email: "foo@bar.com"
              }#{end_bracket}
            RUBY
          end
        end
      end
    end
  end

  context 'with a braced hash argument spanning multiple lines after an argument' do
    context 'when EnforcedStyleForMultiline is consistent_comma' do
      let(:cop_config) { { 'EnforcedStyleForMultiline' => 'consistent_comma' } }

      [%w[( )], %w[[ ]]].each do |start_bracket, end_bracket|
        context "with `#{start_bracket}#{end_bracket}` brackets" do
          it 'accepts multiple arguments with no trailing comma' do
            expect_no_offenses(<<~RUBY)
              EmailWorker.perform_async#{start_bracket}arg, {
                subject: "hey there",
                email: "foo@bar.com"
              }#{end_bracket}
            RUBY
          end
        end
      end
    end
  end

  context 'with a single argument of anonymous function spanning multiple lines' do
    context 'when EnforcedStyleForMultiline is consistent_comma' do
      let(:cop_config) { { 'EnforcedStyleForMultiline' => 'consistent_comma' } }

      it 'accepts a single argument with no trailing comma' do
        expect_no_offenses(<<~RUBY)
          func.(
            'foo',
            'bar',
            'baz',
          )
        RUBY
      end
    end
  end

  context 'with multi-line list of values' do
    context 'when EnforcedStyleForMultiline is no_comma' do
      let(:cop_config) { { 'EnforcedStyleForMultiline' => 'no_comma' } }

      [%w[( )], %w[[ ]]].each do |start_bracket, end_bracket|
        context "with `#{start_bracket}#{end_bracket}` brackets" do
          it 'registers an offense for trailing comma in a method call with ' \
             'hash parameters at the end' do
            expect_offense(<<~RUBY, start_bracket: start_bracket, end_bracket: end_bracket)
              some_method#{start_bracket}
                            a,
                            b,
                            c: 0,
                            d: 1,#{end_bracket}
                                ^ Avoid comma after the last parameter of a method call.
            RUBY

            expect_correction(<<~RUBY)
              some_method#{start_bracket}
                            a,
                            b,
                            c: 0,
                            d: 1#{end_bracket}
            RUBY
          end

          it 'accepts a method call with hash parameters at the end and no trailing comma' do
            expect_no_offenses(<<~RUBY)
              some_method#{start_bracket}a,
                          b,
                          c: 0,
                          d: 1
                        #{end_bracket}
            RUBY
          end

          it 'accepts comma inside a heredoc parameter at the end' do
            expect_no_offenses(<<~RUBY)
              route#{start_bracket}help: {
                'auth' => <<-HELP.chomp
              ,
              HELP
              }#{end_bracket}
            RUBY
          end

          it 'accepts comma inside a heredoc with comments inside' do
            expect_no_offenses(<<~RUBY)
              route#{start_bracket}
                <<-HELP
                ,
                # some comment
                HELP
              #{end_bracket}
            RUBY
          end

          it 'accepts comma inside a heredoc with method and comments inside' do
            expect_no_offenses(<<~RUBY)
              route#{start_bracket}
                <<-HELP.chomp
                ,
                # some comment
                HELP
              #{end_bracket}
            RUBY
          end

          it 'accepts comma inside a heredoc in brackets' do
            expect_no_offenses(<<~RUBY)
              expect_no_offenses(
                expect_no_offenses(<<~SOURCE)
                  run#{start_bracket}
                        :foo, defaults.merge(
                                              bar: 3)#{end_bracket}
                SOURCE
              )
            RUBY
          end

          it 'accepts comma inside a modified heredoc parameter' do
            expect_no_offenses(<<~RUBY)
              some_method#{start_bracket}
                <<-LOREM.delete("\\n")
                  Something with a , in it
                LOREM
              #{end_bracket}
            RUBY
          end

          it 'autocorrects unwanted comma after modified heredoc parameter' do
            expect_offense(<<~'RUBY', start_bracket: start_bracket, end_bracket: end_bracket)
              some_method%{start_bracket}
                <<-LOREM.delete("\n"),
                                     ^ Avoid comma after the last parameter of a method call.
                  Something with a , in it
                LOREM
              %{end_bracket}
            RUBY

            expect_correction(<<~RUBY)
              some_method#{start_bracket}
                <<-LOREM.delete("\\n")
                  Something with a , in it
                LOREM
              #{end_bracket}
            RUBY
          end

          context 'when there is string interpolation inside heredoc parameter' do
            it 'accepts comma inside a heredoc parameter' do
              expect_no_offenses(<<~RUBY)
                some_method#{start_bracket}
                  <<-SQL
                    \#{variable}.a ASC,
                    \#{variable}.b ASC
                  SQL
                #{end_bracket}
              RUBY
            end

            it 'accepts comma inside a heredoc parameter when on a single line' do
              expect_no_offenses(<<~RUBY)
                some_method#{start_bracket}
                  bar: <<-BAR
                    \#{variable} foo, bar
                  BAR
                #{end_bracket}
              RUBY
            end

            it 'autocorrects unwanted comma inside string interpolation' do
              expect_offense(<<~'RUBY')
                some_method(
                  bar: <<-BAR,
                    #{other_method(a, b,)} foo, bar
                                       ^ Avoid comma after the last parameter of a method call.
                  BAR
                  baz: <<-BAZ
                    #{third_method(c, d,)} foo, bar
                                       ^ Avoid comma after the last parameter of a method call.
                  BAZ
                )
              RUBY

              expect_correction(<<~RUBY)
                some_method(
                  bar: <<-BAR,
                    \#{other_method(a, b)} foo, bar
                  BAR
                  baz: <<-BAZ
                    \#{third_method(c, d)} foo, bar
                  BAZ
                )
              RUBY
            end
          end
        end
      end
    end

    context 'when EnforcedStyleForMultiline is comma' do
      let(:cop_config) { { 'EnforcedStyleForMultiline' => 'comma' } }

      [%w[( )], %w[[ ]]].each do |start_bracket, end_bracket|
        context "with `#{start_bracket}#{end_bracket}` brackets" do
          context 'when closing bracket is on same line as last value' do
            it 'accepts a method call with Hash as last parameter split on multiple lines' do
              expect_no_offenses(<<~RUBY)
                some_method#{start_bracket}a: "b",
                            c: "d"#{end_bracket}
              RUBY
            end
          end

          it 'registers an offense for no trailing comma in a method call with ' \
             'hash parameters at the end' do
            expect_offense(<<~RUBY, start_bracket: start_bracket, end_bracket: end_bracket)
              some_method#{start_bracket}
                            a,
                            b,
                            c: 0,
                            d: 1
                            ^^^^ Put a comma after the last parameter of a multiline method call.
                        #{end_bracket}
            RUBY

            expect_correction(<<~RUBY)
              some_method#{start_bracket}
                            a,
                            b,
                            c: 0,
                            d: 1,
                        #{end_bracket}
            RUBY
          end

          it 'accepts a method call with two parameters on the same line' do
            expect_no_offenses(<<~RUBY)
              some_method#{start_bracket}a, b
                        #{end_bracket}
            RUBY
          end

          it 'accepts trailing comma in a method call with hash parameters at the end' do
            expect_no_offenses(<<~RUBY)
              some_method#{start_bracket}
                            a,
                            b,
                            c: 0,
                            d: 1,
                        #{end_bracket}
            RUBY
          end

          it 'accepts missing comma after heredoc with comments' do
            expect_no_offenses(<<~RUBY)
              route#{start_bracket}
                a, <<-HELP.chomp
                ,
                # some comment
                HELP
              #{end_bracket}
            RUBY
          end

          it 'accepts no trailing comma in a method call with a multiline ' \
             'braceless hash at the end with more than one parameter on a line' do
            expect_no_offenses(<<~RUBY)
              some_method#{start_bracket}
                            a,
                            b: 0,
                            c: 0, d: 1
                        #{end_bracket}
            RUBY
          end

          it 'accepts a trailing comma in a method call with single line hashes' do
            expect_no_offenses(<<~RUBY)
              some_method#{start_bracket}
              { a: 0, b: 1 },
              { a: 1, b: 0 },
              #{end_bracket}
            RUBY
          end

          it 'accepts an empty hash being passed as a method argument' do
            expect_no_offenses(<<~RUBY)
              Foo.new#{start_bracket}{
                      }#{end_bracket}
            RUBY
          end

          it 'accepts a multiline call with a single argument and trailing comma' do
            expect_no_offenses(<<~RUBY)
              method#{start_bracket}
                1,
              #{end_bracket}
            RUBY
          end

          it 'does not break when a method call is chained on the offending one' do
            expect_no_offenses(<<~RUBY)
              foo.bar#{start_bracket}
                baz: 1,
              #{end_bracket}.fetch(:qux)
            RUBY
          end

          it 'does not break when a safe method call is chained on the offending simple one' do
            expect_no_offenses(<<~RUBY)
              foo
                &.do_something#{start_bracket}:bar, :baz#{end_bracket}
            RUBY
          end

          it 'does not break when a safe method call is chained on the offending more complex one' do
            expect_no_offenses(<<~RUBY)
              foo.bar#{start_bracket}
                baz: 1,
              #{end_bracket}&.fetch(:qux)
            RUBY
          end
        end
      end
    end

    context 'when EnforcedStyleForMultiline is diff_comma' do
      let(:cop_config) { { 'EnforcedStyleForMultiline' => 'diff_comma' } }

      [%w[( )], %w[[ ]]].each do |start_bracket, end_bracket|
        context "with `#{start_bracket}#{end_bracket}` brackets" do
          it 'registers an offense for no trailing comma when last argument precedes newline' do
            expect_offense(<<~RUBY, start_bracket: start_bracket, end_bracket: end_bracket)
              some_method#{start_bracket}
                           a,
                           b,
                           c: 0,
                           d: 1
                           ^^^^ Put a comma after the last parameter of a multiline method call.
                         #{end_bracket}
            RUBY

            expect_correction(<<~RUBY)
              some_method#{start_bracket}
                           a,
                           b,
                           c: 0,
                           d: 1,
                         #{end_bracket}
            RUBY
          end

          it 'registers an offense for trailing comma when last argument is on same line as closing bracket' do
            expect_offense(<<~RUBY, start_bracket: start_bracket, end_bracket: end_bracket)
              some_method#{start_bracket}a: "b",
                          c: "d",#{end_bracket}
                                ^ Avoid comma after the last parameter of a method call, unless that item immediately precedes a newline.
            RUBY

            expect_correction(<<~RUBY)
              some_method#{start_bracket}a: "b",
                          c: "d"#{end_bracket}
            RUBY
          end

          it 'registers an offense for trailing comma when last argument is array literal on same line as closing bracket' do
            expect_offense(<<~RUBY, start_bracket: start_bracket, end_bracket: end_bracket)
              method#{start_bracket}1, [
                2,
              ],#{end_bracket}
               ^ Avoid comma after the last parameter of a method call, unless that item immediately precedes a newline.
            RUBY

            expect_correction(<<~RUBY)
              method#{start_bracket}1, [
                2,
              ]#{end_bracket}
            RUBY
          end

          it 'accepts trailing comma when last argument precedes newline' do
            expect_no_offenses(<<~RUBY)
              some_method#{start_bracket}
                           a,
                           b,
                           c: 0,
                           d: 1,
                         #{end_bracket}
            RUBY
          end

          it 'accepts no trailing comma when last argument is on same line as closing bracket' do
            expect_no_offenses(<<~RUBY)
              some_method#{start_bracket}a: "b",
                          c: "d"#{end_bracket}
            RUBY
          end

          it 'accepts no trailing comma when last argument is array literal on same line as closing bracket' do
            expect_no_offenses(<<~RUBY)
              method#{start_bracket}1, [
                2,
              ]#{end_bracket}
            RUBY
          end

          it 'accepts trailing comma when last argument has inline comment and precedes newline' do
            expect_no_offenses(<<~RUBY)
              some_method#{start_bracket}
                           a,
                           b,
                           c: 0,
                           d: 1, # comment
                         #{end_bracket}
            RUBY
          end
        end
      end
    end

    context 'when EnforcedStyleForMultiline is consistent_comma' do
      let(:cop_config) { { 'EnforcedStyleForMultiline' => 'consistent_comma' } }

      [%w[( )], %w[[ ]]].each do |start_bracket, end_bracket|
        context "with `#{start_bracket}#{end_bracket}` brackets" do
          context 'when closing bracket is on same line as last value' do
            it 'registers an offense for a method call, with a Hash as the ' \
               'last parameter, split on multiple lines' do
              expect_offense(<<~RUBY, start_bracket: start_bracket, end_bracket: end_bracket)
                some_method#{start_bracket}a: "b",
                            c: "d"#{end_bracket}
                            ^^^^^^ Put a comma after the last parameter of a multiline method call.
              RUBY

              expect_correction(<<~RUBY)
                some_method#{start_bracket}a: "b",
                            c: "d",#{end_bracket}
              RUBY
            end
          end

          it 'registers an offense for no trailing comma in a method call with ' \
             'hash parameters at the end' do
            expect_offense(<<~RUBY, start_bracket: start_bracket, end_bracket: end_bracket)
              some_method#{start_bracket}
                            a,
                            b,
                            c: 0,
                            d: 1
                            ^^^^ Put a comma after the last parameter of a multiline method call.
                        #{end_bracket}
            RUBY

            expect_correction(<<~RUBY)
              some_method#{start_bracket}
                            a,
                            b,
                            c: 0,
                            d: 1,
                        #{end_bracket}
            RUBY
          end

          it 'registers an offense for no trailing comma in a method call with' \
             'two parameters on the same line' do
            expect_offense(<<~RUBY, start_bracket: start_bracket, end_bracket: end_bracket)
              some_method#{start_bracket}a, b
                             ^ Put a comma after the last parameter of a multiline method call.
                        #{end_bracket}
            RUBY

            expect_correction(<<~RUBY)
              some_method#{start_bracket}a, b,
                        #{end_bracket}
            RUBY
          end

          it 'accepts trailing comma in a method call with hash parameters at the end' do
            expect_no_offenses(<<~RUBY)
              some_method#{start_bracket}
                            a,
                            b,
                            c: 0,
                            d: 1,
                        #{end_bracket}
            RUBY
          end

          it 'accepts a trailing comma in a method call with a single hash parameter' do
            expect_no_offenses(<<~RUBY)
              some_method#{start_bracket}
                            a: 0,
                            b: 1,
                        #{end_bracket}
            RUBY
          end

          it 'accepts a trailing comma in a method call with ' \
             'a single hash parameter to a receiver object' do
            expect_no_offenses(<<~RUBY)
              obj.some_method#{start_bracket}
                                a: 0,
                                b: 1,
                            #{end_bracket}
            RUBY
          end

          it 'accepts a trailing comma in a method call with single line hashes' do
            expect_no_offenses(<<~RUBY)
              some_method#{start_bracket}
              { a: 0, b: 1 },
              { a: 1, b: 0 },
              #{end_bracket}
            RUBY
          end

          # this is a sad parse error
          it 'accepts no trailing comma in a method call with a block parameter at the end' do
            expect_no_offenses(<<~RUBY)
              some_method#{start_bracket}
                            a,
                            b,
                            c: 0,
                            d: 1,
                            &block
                        #{end_bracket}
            RUBY
          end

          it 'autocorrects missing comma after a heredoc' do
            expect_offense(<<~RUBY, start_bracket: start_bracket, end_bracket: end_bracket)
              route#{start_bracket}1, <<-HELP.chomp
                       ^^^^^^^^^^^^^ Put a comma after the last parameter of a multiline method call.
              ...
              HELP
              #{end_bracket}
            RUBY

            expect_correction(<<~RUBY)
              route#{start_bracket}1, <<-HELP.chomp,
              ...
              HELP
              #{end_bracket}
            RUBY
          end

          it 'accepts a multiline call with a single argument and trailing comma' do
            expect_no_offenses(<<~RUBY)
              method#{start_bracket}
                1,
              #{end_bracket}
            RUBY
          end

          it 'accepts a multiline call with arguments on a single line and trailing comma' do
            expect_no_offenses(<<~RUBY)
              method#{start_bracket}
                1, 2,
              #{end_bracket}
            RUBY
          end

          it 'accepts a multiline call with single argument on multiple lines' do
            expect_no_offenses(<<~RUBY)
              method#{start_bracket}a:
                        "foo"#{end_bracket}
            RUBY
          end
        end
      end
    end
  end
end
