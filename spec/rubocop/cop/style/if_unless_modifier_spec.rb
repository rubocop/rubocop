# frozen_string_literal: true

######
# Note: most of these tests probably belong in the shared context "condition modifier cop"
######
RSpec.describe RuboCop::Cop::Style::IfUnlessModifier, :config do
  let(:ignore_cop_directives) { true }
  let(:allow_uri) { true }
  let(:line_length_config) do
    {
      'Enabled' => true,
      'Max' => 80,
      'AllowURI' => allow_uri,
      'IgnoreCopDirectives' => ignore_cop_directives,
      'URISchemes' => %w[http https]
    }
  end
  let(:other_cops) { { 'Layout/LineLength' => line_length_config } }

  extra = ' Another good alternative is the usage of control flow `&&`/`||`.'
  it_behaves_like 'condition modifier cop', :if, extra
  it_behaves_like 'condition modifier cop', :unless, extra

  context 'modifier if that does not fit on one line' do
    let(:spaces) { ' ' * 59 }
    let(:body) { "puts '#{spaces}'" }
    let(:source) { "#{body} if condition" }
    let(:long_url) { 'https://some.example.com/with/a/rather?long&and=very&complicated=path' }

    context 'when Layout/LineLength is enabled' do
      it 'corrects it to normal form' do
        expect(source.length).to be(79) # That's 81 including indentation.
        expect_offense(<<~RUBY, body: body)
          def f
            # Comment 1
            %{body} if condition # Comment 2
            _{body} ^^ Modifier form of `if` makes the line too long.
          end
        RUBY

        expect_correction(<<~RUBY)
          def f
            # Comment 1
            if condition
              puts '#{spaces}'
            end # Comment 2
          end
        RUBY
      end

      context 'and the long line is allowed because AllowURI is true' do
        it 'accepts' do
          expect_no_offenses(<<~RUBY)
            puts 1 if url == '#{long_url}'
          RUBY
        end
      end

      context 'and the long line is too long because AllowURI is false' do
        let(:allow_uri) { false }

        it 'registers an offense' do
          expect_offense(<<~RUBY)
            puts 1 if url == '#{long_url}'
                   ^^ Modifier form of `if` makes the line too long.
          RUBY

          expect_correction(<<~RUBY)
            if url == '#{long_url}'
              puts 1
            end
          RUBY
        end
      end

      context 'when using multiple `if` modifier in the long one line' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            def f
              return value if items.filter_map { |item| item.do_something if item.something? }
                                                                          ^^ Modifier form of `if` makes the line too long.
                           ^^ Modifier form of `if` makes the line too long.
            end
          RUBY

          expect_correction(<<~RUBY)
            def f
              if items.filter_map { |item| item.do_something if item.something? }
                return value
              end
            end
          RUBY
        end
      end

      context 'when using a method with heredoc argument' do
        it 'accepts' do
          expect_offense(<<~RUBY)
            fooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo(<<~EOS) if condition
                                                                                 ^^ Modifier form of `if` makes the line too long.
              string
            EOS
          RUBY

          expect_correction(<<~RUBY)
            if condition
              fooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo(<<~EOS)
                string
              EOS
            end
          RUBY
        end
      end

      context 'when variable assignment is used in the branch body of if modifier' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            variable = foooooooooooooooooooooooooooooooooooooooooooooooooooooooo if condition
                                                                                 ^^ Modifier form of `if` makes the line too long.
          RUBY

          expect_correction(<<~RUBY)
            if condition
              variable = foooooooooooooooooooooooooooooooooooooooooooooooooooooooo
            end
          RUBY
        end
      end

      context 'when the line is too long due to long comment with modifier' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            some_statement if some_quite_long_condition # The condition might have been long, but this comment is longer. In fact, it is too long for RuboCop
                           ^^ Modifier form of `if` makes the line too long.
          RUBY

          expect_correction(<<~RUBY)
            # The condition might have been long, but this comment is longer. In fact, it is too long for RuboCop
            some_statement if some_quite_long_condition
          RUBY
        end
      end

      describe 'IgnoreCopDirectives' do
        let(:spaces) { ' ' * 57 }
        let(:comment) { '# rubocop:disable Style/For' }
        let(:body) { "puts '#{spaces}'" }

        context 'and the long line is allowed because IgnoreCopDirectives is true' do
          it 'accepts' do
            expect("#{body} if condition".length).to eq(77) # That's 79 including indentation.
            expect_no_offenses(<<~RUBY)
              def f
                #{body} if condition #{comment}
              end
            RUBY
          end
        end

        context 'and the long line is too long because IgnoreCopDirectives is false' do
          let(:ignore_cop_directives) { false }

          it 'registers an offense' do
            expect_offense(<<~RUBY, body: body)
              def f
                %{body} if condition #{comment}
                _{body} ^^ Modifier form of `if` makes the line too long.
              end
            RUBY

            expect_correction(<<~RUBY)
              def f
                #{comment}
                #{body} if condition
              end
            RUBY
          end
        end
      end
    end

    context 'when Layout/LineLength is disabled in configuration' do
      let(:line_length_config) { { 'Enabled' => false, 'Max' => 80 } }

      it 'accepts' do
        expect_no_offenses(<<~RUBY)
          def f
            #{source}
          end
        RUBY
      end
    end

    context 'when Layout/LineLength is disabled with enable/disable comments' do
      it 'accepts' do
        expect_no_offenses(<<~RUBY)
          def f
            # rubocop:disable Layout/LineLength
            #{source}
            # rubocop:enable Layout/LineLength
          end
        RUBY
      end
    end

    context 'when Layout/LineLength is disabled with an EOL comment' do
      it 'accepts' do
        expect_no_offenses(<<~RUBY)
          def f
            #{source} # rubocop:disable Layout/LineLength
          end
        RUBY
      end
    end
  end

  context 'multiline if that fits on one line' do
    let(:condition) { 'a' * 38 }
    let(:body) { 'b' * 38 }

    it 'registers an offense' do
      # This if statement fits exactly on one line if written as a
      # modifier.
      expect("#{body} if #{condition}".length).to eq(80)

      # Empty lines should make no difference.
      expect_offense(<<~RUBY)
        if #{condition}
        ^^ Favor modifier `if` usage when having a single-line body. Another good alternative is the usage of control flow `&&`/`||`.
          #{body}

        end
      RUBY

      expect_correction(<<~RUBY)
        #{body} if #{condition}
      RUBY
    end

    context 'and has two statements separated by semicolon' do
      it 'accepts' do
        expect_no_offenses(<<~RUBY)
          if condition
            do_this; do_that
          end
        RUBY
      end
    end

    context 'and has a method call with kwargs splat' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          if condition
          ^^ Favor modifier `if` usage when having a single-line body. Another good alternative is the usage of control flow `&&`/`||`.
            do_this(**options)
          end
        RUBY

        expect_correction(<<~RUBY)
          do_this(**options) if condition
        RUBY
      end
    end
  end

  context 'modifier if that does not fit on one line, but is not the only statement on the line' do
    let(:spaces) { ' ' * 59 }

    # long lines which have multiple statements on the same line can be flagged
    #   by Layout/LineLength, Style/Semicolon, etc.
    # if they are handled by Style/IfUnlessModifier, there is a danger of
    #   creating infinite autocorrect loops when autocorrecting
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        def f
          puts '#{spaces}' if condition; some_method_call
        end
      RUBY
    end
  end

  context 'multiline if that fits on one line with comment on first line' do
    it 'registers an offense and preserves comment' do
      expect_offense(<<~RUBY)
        if a # comment
        ^^ Favor modifier `if` usage when having a single-line body. Another good alternative is the usage of control flow `&&`/`||`.
          b
        end
      RUBY

      expect_correction(<<~RUBY)
        b if a # comment
      RUBY
    end
  end

  context 'multiline if that fits on one line with comment near end' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        if a
          b
        end # comment
        if a
          b
          # comment
        end
      RUBY
    end
  end

  context 'short multiline if near an else etc' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        if x
          y
        elsif x1
          y1
        else
          z
        end
        n = a ? 0 : 1
        m = 3 if m0

        if a
        ^^ Favor modifier `if` usage when having a single-line body. Another good alternative is the usage of control flow `&&`/`||`.
          b
        end
      RUBY

      expect_correction(<<~RUBY)
        if x
          y
        elsif x1
          y1
        else
          z
        end
        n = a ? 0 : 1
        m = 3 if m0

        b if a
      RUBY
    end
  end

  context 'multiline unless that fits on one line' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        unless a
        ^^^^^^ Favor modifier `unless` usage when having a single-line body. Another good alternative is the usage of control flow `&&`/`||`.
          b
        end
      RUBY

      expect_correction(<<~RUBY)
        b unless a
      RUBY
    end
  end

  it 'accepts code with EOL comment since user might want to keep it' do
    expect_no_offenses(<<~RUBY)
      unless a
        b # A comment
      end
    RUBY
  end

  it 'accepts if-else-end' do
    expect_no_offenses(<<~RUBY)
      if args.last.is_a? Hash then args.pop else Hash.new end
    RUBY
  end

  it 'accepts if/elsif' do
    expect_no_offenses(<<~RUBY)
      if test
        something
      elsif test2
        something_else
      end
    RUBY
  end

  shared_examples 'one-line pattern matching' do
    it 'does not register an offense when using match var in body' do
      expect_no_offenses(<<~RUBY)
        if [42] in [x]
          x
        end
      RUBY
    end

    it 'does not register an offense when using some match var in body' do
      expect_no_offenses(<<~RUBY)
        if { x: 1, y: 2 } in { x:, y: }
          a && y
        end
      RUBY
    end

    it 'does not register an offense when not using match var in body' do
      expect_no_offenses(<<~RUBY)
        if [42] in [x]
          y
        end
      RUBY
    end

    it 'does not register an offense when not using any match var in body' do
      expect_no_offenses(<<~RUBY)
        if { x: 1, y: 2 } in { x:, y: }
          a && b
        end
      RUBY
    end
  end

  # The node type for one-line `in` pattern matching in Ruby 2.7 is `match_pattern`.
  context 'using `match_pattern` as a one-line pattern matching', :ruby27 do
    include_examples 'one-line pattern matching'
  end

  # The node type for one-line `in` pattern matching in Ruby 3.0 is `match_pattern_p`.
  context 'using `match_pattern_p` as a one-line pattern matching', :ruby30 do
    include_examples 'one-line pattern matching'
  end

  context 'multiline `if` that fits on one line and using hash value omission syntax', :ruby31 do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        if condition
        ^^ Favor modifier `if` usage when having a single-line body. Another good alternative is the usage of control flow `&&`/`||`.
          obj.do_something foo:
        end

        if condition
        ^^ Favor modifier `if` usage when having a single-line body. Another good alternative is the usage of control flow `&&`/`||`.
          obj&.do_something foo:
        end
      RUBY

      expect_correction(<<~RUBY)
        obj.do_something(foo:) if condition

        obj&.do_something(foo:) if condition
      RUBY
    end
  end

  context 'using `defined?` in the condition' do
    it 'registers for argument value is defined' do
      expect_offense(<<~RUBY)
        value = :custom

        unless defined?(value)
        ^^^^^^ Favor modifier `unless` usage when having a single-line body. Another good alternative is the usage of control flow `&&`/`||`.
          value = :default
        end
      RUBY

      expect_correction(<<~RUBY)
        value = :custom

        value = :default unless defined?(value)
      RUBY
    end

    it 'registers for argument value is `yield`' do
      expect_offense(<<~RUBY)
        unless defined?(yield)
        ^^^^^^ Favor modifier `unless` usage when having a single-line body. Another good alternative is the usage of control flow `&&`/`||`.
          value = :default
        end
      RUBY

      expect_correction(<<~RUBY)
        value = :default unless defined?(yield)
      RUBY
    end

    it 'registers for argument value is `super`' do
      expect_offense(<<~RUBY)
        unless defined?(super)
        ^^^^^^ Favor modifier `unless` usage when having a single-line body. Another good alternative is the usage of control flow `&&`/`||`.
          value = :default
        end
      RUBY

      expect_correction(<<~RUBY)
        value = :default unless defined?(super)
      RUBY
    end

    it 'accepts `defined?` when argument value is undefined' do
      expect_no_offenses(<<~RUBY)
        other_value = do_something

        unless defined?(value)
          value = :default
        end
      RUBY
    end

    it 'accepts `defined?` when argument value is undefined and the first condition' do
      expect_no_offenses(<<~RUBY)
        other_value = do_something

        unless defined?(value) && condition
          value = :default
        end
      RUBY
    end

    it 'accepts `defined?` when argument value is undefined and the last condition' do
      expect_no_offenses(<<~RUBY)
        other_value = do_something

        unless condition && defined?(value)
          value = :default
        end
      RUBY
    end
  end

  context 'with implicit match conditional' do
    let(:body) { 'b' * 36 }

    context 'when a multiline if fits on one line' do
      let(:conditional) { "/#{'a' * 36}/" }

      it 'registers an offense' do
        expect("  #{body} if #{conditional}".length).to eq(80)

        expect_offense(<<-RUBY.strip_margin('|'))
          |  if #{conditional}
          |  ^^ Favor modifier `if` usage when having a single-line body. [...]
          |    #{body}
          |  end
        RUBY

        expect_correction("  #{body} if #{conditional}\n")
      end
    end

    context "when a multiline if doesn't fit on one line" do
      let(:conditional) { "/#{'a' * 37}/" }

      it 'accepts' do
        expect("  #{body} if #{conditional}".length).to eq(81)

        expect_no_offenses(<<-RUBY.strip_margin('|'))
          |  if #{conditional}
          |    #{body}
          |  end
        RUBY
      end
    end
  end

  it 'accepts if-end followed by a chained call using `.`' do
    expect_no_offenses(<<~RUBY)
      if test
        something
      end.inspect
    RUBY
  end

  it 'accepts if-end followed by a chained call using `&.`' do
    expect_no_offenses(<<~RUBY)
      if test
        something
      end&.inspect
    RUBY
  end

  it 'adds parens in autocorrect when if-end used with `||` operator' do
    expect_offense(<<~RUBY)
      a || if b
           ^^ Favor modifier `if` usage when having a single-line body. Another good alternative is the usage of control flow `&&`/`||`.
        1
      end
    RUBY

    expect_correction(<<~RUBY)
      a || (1 if b)
    RUBY
  end

  it 'adds parens in autocorrect when if-end used with `&&` operator' do
    expect_offense(<<~RUBY)
      a && if b
           ^^ Favor modifier `if` usage when having a single-line body. Another good alternative is the usage of control flow `&&`/`||`.
        1
      end
    RUBY

    expect_correction(<<~RUBY)
      a && (1 if b)
    RUBY
  end

  it 'accepts if-end when used as LHS of binary arithmetic' do
    expect_no_offenses(<<~RUBY)
      if test
        1
      end + 2
    RUBY
  end

  context 'if-end is argument to a parenthesized method call' do
    it 'adds parentheses because otherwise it would cause SyntaxError' do
      expect_offense(<<~RUBY)
        puts("string", if a
                       ^^ Favor modifier `if` usage when having a single-line body. [...]
          1
        end)
      RUBY

      expect_correction(<<~RUBY)
        puts("string", (1 if a))
      RUBY
    end
  end

  context 'if-end is argument to a non-parenthesized method call' do
    it 'adds parentheses so as not to change meaning' do
      expect_offense(<<~RUBY)
        puts "string", if a
                       ^^ Favor modifier `if` usage when having a single-line body. [...]
          1
        end
      RUBY

      expect_correction(<<~RUBY)
        puts "string", (1 if a)
      RUBY
    end
  end

  context 'if-end with conditional as body' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        if condition
          foo ? "bar" : "baz"
        end
      RUBY
    end
  end

  context 'unless-end with conditional as body' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        unless condition
          foo ? "bar" : "baz"
        end
      RUBY
    end
  end

  context 'with a named regexp capture on the LHS' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        if /(?<foo>\d)/ =~ "bar"
          foo
        end
      RUBY
    end
  end

  context 'with tabs used for indentation' do
    shared_examples 'with tabs indentation' do
      let(:indent) { "\t" * 6 }
      let(:body) { 'bbb' }

      context 'it fits on one line' do
        let(:condition) { 'aaa' }

        it 'registers an offense' do
          # This if statement fits exactly on one line if written as a
          # modifier.
          expect("#{body} if #{condition}".length).to eq(10)

          expect_offense(<<~RUBY, indent: indent)
            %{indent}if #{condition}
            _{indent}^^ Favor modifier `if` usage when having a single-line body. [...]
            %{indent}\t#{body}
            %{indent}end
          RUBY

          expect_correction(<<~RUBY)
            #{indent}#{body} if #{condition}
          RUBY
        end
      end

      context "it doesn't fit on one line" do
        let(:condition) { 'aaaa' }

        it "doesn't register an offense" do
          # This if statement fits exactly on one line if written as a
          # modifier.
          expect("#{body} if #{condition}".length).to eq(11)

          expect_no_offenses(<<~RUBY)
            #{indent}if #{condition}
            #{indent}\t#{body}
            #{indent}end
          RUBY
        end
      end
    end

    context 'with Layout/IndentationStyle: IndentationWidth config' do
      let(:other_cops) do
        {
          'Layout/IndentationStyle' => { 'IndentationWidth' => 2 },
          'Layout/LineLength' => { 'Max' => 10 + 12 } # 12 is indentation
        }
      end

      it_behaves_like 'with tabs indentation'
    end

    context 'with Layout/IndentationWidth: Width config' do
      let(:other_cops) do
        {
          'Layout/IndentationWidth' => { 'Width' => 3 },
          'Layout/LineLength' => { 'Max' => 10 + 18 } # 18 is indentation
        }
      end

      it_behaves_like 'with tabs indentation'
    end
  end

  context 'when Layout/LineLength is disabled' do
    let(:line_length_config) { { 'Enabled' => false } }

    it 'registers an offense even for a long modifier statement' do
      expect_offense(<<~RUBY)
        if foo
        ^^ Favor modifier `if` usage when having a single-line body. Another good alternative is the usage of control flow `&&`/`||`.
          "This string would make the line longer than eighty characters if combined with the statement."
        end
      RUBY

      expect_correction(<<~RUBY)
        "This string would make the line longer than eighty characters if combined with the statement." if foo
      RUBY
    end
  end

  context 'when if-end condition is assigned to a variable' do
    context 'with variable being on the same line' do
      let(:body) { 'b' * body_length }

      context 'when it is short enough to fit on a single line' do
        let(:body_length) { 69 }

        it 'corrects it to the single-line form' do
          expect_offense(<<~RUBY, body: body)
            x = if a
                ^^ Favor modifier `if` usage [...]
              %{body}
            end
          RUBY

          expect_correction(<<~RUBY)
            x = (#{body} if a)
          RUBY
        end
      end

      context 'when it is not short enough to fit on a single line' do
        let(:body_length) { 70 }

        it 'accepts it in the multiline form' do
          expect_no_offenses(<<~RUBY)
            x = if a
              #{body}
            end
          RUBY
        end
      end
    end

    context 'with variable being on the previous line' do
      let(:body) { 'b' * body_length }

      context 'when it is short enough to fit on a single line' do
        let(:body_length) { 71 }

        it 'corrects it to the single-line form' do
          expect_offense(<<~RUBY, body: body)
            x =
              if a
              ^^ Favor modifier `if` usage [...]
                %{body}
              end
          RUBY

          expect_correction(<<~RUBY)
            x =
              (#{body} if a)
          RUBY
        end
      end

      context 'when it is not short enough to fit on a single line' do
        let(:body_length) { 72 }

        it 'accepts it in the multiline form' do
          expect_no_offenses(<<~RUBY)
            x =
              if a
                #{body}
              end
          RUBY
        end
      end
    end
  end

  context 'when if-end condition is an element of an array' do
    let(:body) { 'b' * body_length }

    context 'when short enough to fit on a single line' do
      let(:body_length) { 71 }

      it 'corrects it to the single-line form' do
        expect_offense(<<~RUBY, body: body)
          [
            if a
            ^^ Favor modifier `if` usage [...]
              %{body}
            end
          ]
        RUBY

        expect_correction(<<~RUBY)
          [
            (#{body} if a)
          ]
        RUBY
      end
    end

    context 'when not short enough to fit on a single line' do
      let(:body_length) { 72 }

      it 'accepts it in the multiline form' do
        expect_no_offenses(<<~RUBY)
          [
            if a
              #{body}
            end
          ]
        RUBY
      end
    end
  end

  context 'when if-end condition is a value in a hash' do
    let(:body) { 'b' * body_length }

    context 'when it is short enough to fit on a single line' do
      let(:body_length) { 68 }

      it 'corrects it to the single-line form' do
        expect_offense(<<~RUBY, body: body)
          {
            x: if a
               ^^ Favor modifier `if` usage [...]
                 %{body}
               end
          }
        RUBY

        expect_correction(<<~RUBY)
          {
            x: (#{body} if a)
          }
        RUBY
      end
    end

    context 'when it is not short enough to fit on a single line' do
      let(:body_length) { 69 }

      it 'accepts it in the multiline form' do
        expect_no_offenses(<<~RUBY)
          {
            x: if a
                 #{body}
               end
          }
        RUBY
      end
    end
  end

  context 'when if-end condition has a first line comment' do
    let(:comment) { 'c' * comment_length }

    context 'when it is short enough to fit on a single line' do
      let(:comment_length) { 67 }

      it 'corrects it to the single-line form' do
        expect_offense(<<~RUBY, comment: comment)
          if foo # %{comment}
          ^^ Favor modifier `if` usage [...]
            bar
          end
        RUBY

        expect_correction(<<~RUBY)
          bar if foo # #{comment}
        RUBY
      end
    end

    context 'when it is not short enough to fit on a single line' do
      let(:comment_length) { 68 }

      it 'accepts it in the multiline form' do
        expect_no_offenses(<<~RUBY)
          if foo # #{comment}
            bar
          end
        RUBY
      end
    end
  end

  context 'when if-end condition has some code after the end keyword' do
    let(:body) { 'b' * body_length }

    context 'when it is short enough to fit on a single line' do
      let(:body_length) { 53 }

      it 'corrects it to the single-line form' do
        expect_offense(<<~RUBY, body: body)
          [
            1, if foo
               ^^ Favor modifier `if` usage [...]
                 %{body}
               end, 300_000_000
          ]
        RUBY

        expect_correction(<<~RUBY)
          [
            1, (#{body} if foo), 300_000_000
          ]
        RUBY
      end
    end

    context 'when it is not short enough to fit on a single line' do
      let(:body_length) { 54 }

      it 'accepts it in the multiline form' do
        expect_no_offenses(<<~RUBY)
          [
            1, if foo
                 #{body}
               end, 300_000_000
          ]
        RUBY
      end
    end
  end
end
