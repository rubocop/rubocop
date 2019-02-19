# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::TrailingCommaInArguments, :config do
  subject(:cop) { described_class.new(config) }

  shared_examples 'single line lists' do |extra_info|
    it 'registers an offense for trailing comma in a method call' do
      expect_offense(<<-RUBY.strip_indent)
        some_method(a, b, c, )
                           ^ Avoid comma after the last parameter of a method call#{extra_info}.
      RUBY
    end

    it 'registers an offense for trailing comma preceded by whitespace' \
       ' in a method call' do
      expect_offense(<<-RUBY.strip_indent)
        some_method(a, b, c , )
                            ^ Avoid comma after the last parameter of a method call#{extra_info}.
      RUBY
    end

    it 'registers an offense for trailing comma in a method call with hash' \
       ' parameters at the end' do
      expect_offense(<<-RUBY.strip_indent)
        some_method(a, b, c: 0, d: 1, )
                                    ^ Avoid comma after the last parameter of a method call#{extra_info}.
      RUBY
    end

    it 'accepts method call without trailing comma' do
      expect_no_offenses('some_method(a, b, c)')
    end

    it 'accepts method call without trailing comma ' \
       'when a line break before a method call' do
      expect_no_offenses(<<-RUBY.strip_indent)
        obj
          .do_something(:foo, :bar)
      RUBY
    end

    it 'accepts method call without trailing comma with single element hash' \
        ' parameters at the end' do
      expect_no_offenses('some_method(a: 1)')
    end

    it 'accepts method call without parameters' do
      expect_no_offenses('some_method')
    end

    it 'accepts chained single-line method calls' do
      expect_no_offenses(<<-RUBY.strip_indent)
        target
          .some_method(a)
      RUBY
    end

    it 'auto-corrects unwanted comma in a method call' do
      new_source = autocorrect_source('some_method(a, b, c, )')
      expect(new_source).to eq('some_method(a, b, c )')
    end

    it 'auto-corrects unwanted comma in a method call with hash parameters at' \
       ' the end' do
      new_source = autocorrect_source('some_method(a, b, c: 0, d: 1, )')
      expect(new_source).to eq('some_method(a, b, c: 0, d: 1 )')
    end

    it 'accepts heredoc without trailing comma' do
      expect_no_offenses(<<-RUBY.strip_indent)
        route(1, <<-HELP.chomp)
        ...
        HELP
      RUBY
    end

    context 'when using safe navigation operator', :ruby23 do
      it 'registers an offense for trailing comma in a method call' do
        expect_offense(<<-RUBY.strip_indent)
        receiver&.some_method(a, b, c, )
                                     ^ Avoid comma after the last parameter of a method call#{extra_info}.
        RUBY
      end

      it 'registers an offense for trailing comma in a method call with hash' \
        ' parameters at the end' do
        expect_offense(<<-RUBY.strip_indent)
        receiver&.some_method(a, b, c: 0, d: 1, )
                                              ^ Avoid comma after the last parameter of a method call#{extra_info}.
        RUBY
      end

      it 'auto-corrects unwanted comma in a method call' do
        new_source = autocorrect_source('receiver&.some_method(a, b, c, )')
        expect(new_source).to eq('receiver&.some_method(a, b, c )')
      end

      it 'auto-corrects unwanted comma in a method call with hash parameters' \
        ' at the end' do
        new_source = autocorrect_source(
          'receiver&.some_method(a, b, c: 0, d: 1, )'
        )
        expect(new_source).to eq('receiver&.some_method(a, b, c: 0, d: 1 )')
      end
    end
  end

  context 'with single line list of values' do
    context 'when EnforcedStyleForMultiline is no_comma' do
      let(:cop_config) { { 'EnforcedStyleForMultiline' => 'no_comma' } }

      include_examples 'single line lists', ''
    end

    context 'when EnforcedStyleForMultiline is comma' do
      let(:cop_config) { { 'EnforcedStyleForMultiline' => 'comma' } }

      include_examples 'single line lists',
                       ', unless each item is on its own line'
    end

    context 'when EnforcedStyleForMultiline is consistent_comma' do
      let(:cop_config) { { 'EnforcedStyleForMultiline' => 'consistent_comma' } }

      include_examples 'single line lists',
                       ', unless items are split onto multiple lines'
    end
  end

  context 'with a single argument spanning multiple lines' do
    context 'when EnforcedStyleForMultiline is consistent_comma' do
      let(:cop_config) { { 'EnforcedStyleForMultiline' => 'consistent_comma' } }

      it 'accepts a single argument with no trailing comma' do
        expect_no_offenses(<<-RUBY.strip_indent)
          EmailWorker.perform_async({
            subject: "hey there",
            email: "foo@bar.com"
          })
        RUBY
      end
    end
  end

  context 'with multi-line list of values' do
    context 'when EnforcedStyleForMultiline is no_comma' do
      let(:cop_config) { { 'EnforcedStyleForMultiline' => 'no_comma' } }

      it 'registers an offense for trailing comma in a method call with ' \
         'hash parameters at the end' do
        expect_offense(<<-RUBY.strip_indent)
          some_method(
                        a,
                        b,
                        c: 0,
                        d: 1,)
                            ^ Avoid comma after the last parameter of a method call.
        RUBY
      end

      it 'accepts a method call with ' \
         'hash parameters at the end and no trailing comma' do
        expect_no_offenses(<<-RUBY.strip_indent)
          some_method(a,
                      b,
                      c: 0,
                      d: 1
                     )
        RUBY
      end

      it 'accepts comma inside a heredoc parameter at the end' do
        expect_no_offenses(<<-RUBY.strip_indent)
          route(help: {
            'auth' => <<-HELP.chomp
          ,
          HELP
          })
        RUBY
      end

      it 'accepts comma inside a heredoc with comments inside' do
        expect_no_offenses(<<-RUBY.strip_indent)
          route(
            <<-HELP
            ,
            # some comment
            HELP
          )
        RUBY
      end

      it 'accepts comma inside a heredoc with method and comments inside' do
        expect_no_offenses(<<-RUBY.strip_indent)
          route(
            <<-HELP.chomp
            ,
            # some comment
            HELP
          )
        RUBY
      end

      it 'accepts comma inside a heredoc in brackets' do
        expect_no_offenses(<<-RUBY.strip_indent)
          new_source = autocorrect_source(
            autocorrect_source(<<-SOURCE.strip_indent)
              run(
                    :foo, defaults.merge(
                                          bar: 3))
            SOURCE
          )
        RUBY
      end

      it 'accepts comma inside a modified heredoc parameter' do
        expect_no_offenses(<<-RUBY.strip_indent)
          some_method(
            <<-LOREM.delete("\\n")
              Something with a , in it
            LOREM
          )
        RUBY
      end

      it 'auto-corrects unwanted comma after modified heredoc parameter' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          some_method(
            <<-LOREM.delete("\\n"),
              Something with a , in it
            LOREM
          )
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          some_method(
            <<-LOREM.delete("\\n")
              Something with a , in it
            LOREM
          )
        RUBY
      end

      context 'when there is string interpolation inside heredoc parameter' do
        it 'accepts comma inside a heredoc parameter' do
          expect_no_offenses(<<-RUBY.strip_indent)
            some_method(
              <<-SQL
                \#{variable}.a ASC,
                \#{variable}.b ASC
              SQL
            )
          RUBY
        end

        it 'accepts comma inside a heredoc parameter when on a single line' do
          expect_no_offenses(<<-RUBY.strip_indent)
            some_method(
              bar: <<-BAR
                \#{variable} foo, bar
              BAR
            )
          RUBY
        end

        it 'auto-corrects unwanted comma inside string interpolation' do
          new_source = autocorrect_source(<<-RUBY.strip_indent)
            some_method(
              bar: <<-BAR,
                \#{other_method(a, b,)} foo, bar
              BAR
              baz: <<-BAZ
                \#{third_method(c, d,)} foo, bar
              BAZ
            )
          RUBY
          expect(new_source).to eq(<<-RUBY.strip_indent)
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

      it 'auto-corrects unwanted comma in a method call with hash parameters' \
         ' at the end' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          some_method(
                        a,
                        b,
                        c: 0,
                        d: 1,)
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          some_method(
                        a,
                        b,
                        c: 0,
                        d: 1)
        RUBY
      end
    end

    context 'when EnforcedStyleForMultiline is comma' do
      let(:cop_config) { { 'EnforcedStyleForMultiline' => 'comma' } }

      context 'when closing bracket is on same line as last value' do
        it 'accepts a method call with Hash as last parameter split on ' \
           'multiple lines' do
          expect_no_offenses(<<-RUBY.strip_indent)
            some_method(a: "b",
                        c: "d")
          RUBY
        end
      end

      it 'registers an offense for no trailing comma in a method call with' \
         ' hash parameters at the end' do
        expect_offense(<<-RUBY.strip_indent)
          some_method(
                        a,
                        b,
                        c: 0,
                        d: 1
                        ^^^^ Put a comma after the last parameter of a multiline method call.
                     )
        RUBY
      end

      it 'accepts a method call with two parameters on the same line' do
        expect_no_offenses(<<-RUBY.strip_indent)
          some_method(a, b
                     )
        RUBY
      end

      it 'accepts trailing comma in a method call with hash' \
         ' parameters at the end' do
        expect_no_offenses(<<-RUBY.strip_indent)
          some_method(
                        a,
                        b,
                        c: 0,
                        d: 1,
                     )
        RUBY
      end

      it 'accepts missing comma after heredoc with comments' do
        expect_no_offenses(<<-RUBY.strip_indent)
          route(
            a, <<-HELP.chomp
            ,
            # some comment
            HELP
          )
        RUBY
      end

      it 'accepts no trailing comma in a method call with a multiline' \
         ' braceless hash at the end with more than one parameter on a line' do
        expect_no_offenses(<<-RUBY.strip_indent)
          some_method(
                        a,
                        b: 0,
                        c: 0, d: 1
                     )
        RUBY
      end

      it 'accepts a trailing comma in a method call with single ' \
         'line hashes' do
        expect_no_offenses(<<-RUBY.strip_indent)
          some_method(
           { a: 0, b: 1 },
           { a: 1, b: 0 },
          )
        RUBY
      end

      it 'accepts an empty hash being passed as a method argument' do
        expect_no_offenses(<<-RUBY.strip_indent)
          Foo.new({
                   })
        RUBY
      end

      it 'auto-corrects missing comma in a method call with hash parameters' \
         ' at the end' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          some_method(
                        a,
                        b,
                        c: 0,
                        d: 1
                     )
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          some_method(
                        a,
                        b,
                        c: 0,
                        d: 1,
                     )
        RUBY
      end

      it 'accepts a multiline call with a single argument and trailing comma' do
        expect_no_offenses(<<-RUBY.strip_indent)
          method(
            1,
          )
        RUBY
      end

      it 'does not break when a method call is chaned on the offending one' do
        expect_no_offenses(<<-RUBY.strip_indent)
          foo.bar(
            baz: 1,
          ).fetch(:qux)
        RUBY
      end

      it 'does not break when a safe method call is chained on the ' \
         'offending one', :ruby23 do
        expect_no_offenses(<<-RUBY.strip_indent)
          foo
            &.do_something(:bar, :baz)
        RUBY
      end

      it 'does not break when a safe method call is chained on the ' \
         'offending one', :ruby23 do
        expect_no_offenses(<<-RUBY.strip_indent)
          foo.bar(
            baz: 1,
          )&.fetch(:qux)
        RUBY
      end
    end

    context 'when EnforcedStyleForMultiline is consistent_comma' do
      let(:cop_config) { { 'EnforcedStyleForMultiline' => 'consistent_comma' } }

      context 'when closing bracket is on same line as last value' do
        it 'registers an offense for a method call, with a Hash as the ' \
           'last parameter, split on multiple lines' do
          expect_offense(<<-RUBY.strip_indent)
            some_method(a: "b",
                        c: "d")
                        ^^^^^^ Put a comma after the last parameter of a multiline method call.
          RUBY
        end
      end

      it 'registers an offense for no trailing comma in a method call with' \
         ' hash parameters at the end' do
        expect_offense(<<-RUBY.strip_indent)
          some_method(
                        a,
                        b,
                        c: 0,
                        d: 1
                        ^^^^ Put a comma after the last parameter of a multiline method call.
                     )
        RUBY
      end

      it 'registers an offense for no trailing comma in a method call with' \
          'two parameters on the same line' do
        expect_offense(<<-RUBY.strip_indent)
          some_method(a, b
                         ^ Put a comma after the last parameter of a multiline method call.
                     )
        RUBY
      end

      it 'accepts trailing comma in a method call with hash' \
         ' parameters at the end' do
        expect_no_offenses(<<-RUBY.strip_indent)
          some_method(
                        a,
                        b,
                        c: 0,
                        d: 1,
                     )
        RUBY
      end

      it 'accepts a trailing comma in a method call with ' \
         'a single hash parameter' do
        expect_no_offenses(<<-RUBY.strip_indent)
          some_method(
                        a: 0,
                        b: 1,
                     )
        RUBY
      end

      it 'accepts a trailing comma in a method call with ' \
         'a single hash parameter to a receiver object' do
        expect_no_offenses(<<-RUBY.strip_indent)
          obj.some_method(
                            a: 0,
                            b: 1,
                         )
        RUBY
      end

      it 'accepts a trailing comma in a method call with single ' \
         'line hashes' do
        expect_no_offenses(<<-RUBY.strip_indent)
          some_method(
           { a: 0, b: 1 },
           { a: 1, b: 0 },
          )
        RUBY
      end

      # this is a sad parse error
      it 'accepts no trailing comma in a method call with a block' \
         ' parameter at the end' do
        expect_no_offenses(<<-RUBY.strip_indent)
          some_method(
                        a,
                        b,
                        c: 0,
                        d: 1,
                        &block
                     )
        RUBY
      end

      it 'auto-corrects missing comma after a heredoc' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          route(1, <<-HELP.chomp
          ...
          HELP
          )
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          route(1, <<-HELP.chomp,
          ...
          HELP
          )
        RUBY
      end

      it 'auto-corrects missing comma in a method call with hash parameters' \
         ' at the end' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          some_method(
                        a,
                        b,
                        c: 0,
                        d: 1
                     )
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          some_method(
                        a,
                        b,
                        c: 0,
                        d: 1,
                     )
        RUBY
      end

      it 'accepts a multiline call with a single argument and trailing comma' do
        expect_no_offenses(<<-RUBY.strip_indent)
          method(
            1,
          )
        RUBY
      end

      it 'accepts a multiline call with arguments on a single line and' \
         ' trailing comma' do
        expect_no_offenses(<<-RUBY.strip_indent)
          method(
            1, 2,
          )
        RUBY
      end

      it 'accepts a multiline call with single argument on multiple lines' do
        expect_no_offenses(<<-RUBY.strip_indent)
          method(a:
                    "foo")
        RUBY
      end
    end
  end
end
