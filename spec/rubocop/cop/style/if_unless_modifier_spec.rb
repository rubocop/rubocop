# frozen_string_literal: true

######
# Note: most of these tests probably belong in the shared context "condition modifier cop"
######
RSpec.describe RuboCop::Cop::Style::IfUnlessModifier, :config do
  shared_context 'with LineLength settings' do |enabled: true,
                                                allow_uri: true,
                                                ignore_cop_directives: true|
    let(:other_cops) do
      {
        'Layout/LineLength' => {
          'Enabled' => enabled,
          'Max' => 80,
          'AllowURI' => allow_uri,
          'IgnoreCopDirectives' => ignore_cop_directives,
          'URISchemes' => %w[http https]
        }
      }
    end
  end

  include_context 'with LineLength settings' # default ones

  extra = ' Another good alternative is the usage of control flow `&&`/`||`.'
  it_behaves_like 'condition modifier cop', :if, extra
  it_behaves_like 'condition modifier cop', :unless, extra

  context 'modifier `if` that does not fit on one line' do
    let(:body) { "puts '                                                           '" }
    let(:long_url) do
      'https://some.example.com/with/a/rather?long&and=very&complicated=path'
    end

    context 'when Layout/LineLength is enabled' do
      it 'corrects it to normal form' do
        expect("#{body} if condition".length).to be(79) # That's 81 including indentation
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
              #{body}
            end # Comment 2
          end
        RUBY
      end

      context 'when AllowURI is true' do
        it 'ignores the long line with an URL' do
          expect_no_offenses(<<~RUBY)
            puts 1 if url == '#{long_url}'
          RUBY
        end
      end

      context 'when AllowURI is false' do
        include_context 'with LineLength settings', allow_uri: false

        it 'flags the long line with an URL' do
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

      describe 'IgnoreCopDirectives' do
        let(:comment) { '# rubocop:disable Style/For' }

        context 'when IgnoreCopDirectives is true' do
          it 'ignores an overly long line' do
            expect("#{body} if condition".length).to eq(79)
            expect_no_offenses(<<~RUBY)
              #{body} if condition #{comment}
            RUBY
          end
        end

        context 'when IgnoreCopDirectives is false' do
          include_context 'with LineLength settings',
                          ignore_cop_directives: false

          it 'flags an overly long line' do
            expect_offense(<<~RUBY, body: body)
              %{body} if condition #{comment}
              _{body} ^^ Modifier form of `if` makes the line too long.
            RUBY

            expect_correction(<<~RUBY)
              if condition
                #{body}
              end #{comment}
            RUBY
          end
        end
      end
    end

    context 'when Layout/LineLength is disabled in configuration' do
      include_context 'with LineLength settings', enabled: false

      it 'accepts' do
        expect_no_offenses(<<~RUBY)
          def f
            #{source}
          end
        RUBY
      end
    end

    context 'when Layout/LineLength is disabled with enable/disable ' \
            'comments' do
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

  context 'when multiline `if` that fits on one line' do
    it 'flags and inlines' do
      condition = 'a' * 38
      body = 'b' * 38

      # The statement fits exactly on one line if written as a modifier
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

    it 'ignores two statements separated by semicolon' do
      expect_no_offenses(<<~RUBY)
        if condition
          do_this; do_that
        end
      RUBY
    end
  end

  it 'ignores modifier `if` that does not fit on one line, but is not the' \
          ' only statement on the line' do
    # Long lines which have multiple statements on the same line can be flagged
    # by Layout/LineLength, Style/Semicolon, etc. If they are handled by
    # Style/IfUnlessModifier, there is a risk of infinite autocorrect loops.
    expect_no_offenses(<<~RUBY)
      puts '                                                                                ' if condition; some_method_call
    RUBY
  end

  context 'when multiline `if` fits on one line with a comment on first line' do
    it 'flags and inlines preserving the comment' do
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

  it 'ignores multiline `if` that fits on one line with a comment near end' do
    expect_no_offenses(<<~RUBY)
      if a
        b
      end # comment
      if a
        b
        # comment
      end
      unless a
        b # A comment
      end
    RUBY
  end

  it 'inlines a short multiline `if` surrounded by unrelated conditionals' do
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

  it 'ignores if-else-end' do
    expect_no_offenses(<<~RUBY)
      if args.last.is_a? Hash then args.pop else Hash.new end
    RUBY
  end

  it 'ignores if/elsif' do
    expect_no_offenses(<<~RUBY)
      if test
        something
      elsif test2
        something_else
      end
    RUBY
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

  it 'ignores if-end followed by a chained call using `.`' do
    expect_no_offenses(<<~RUBY)
      if test
        something
      end.inspect
    RUBY
  end

  it 'ignores if-end followed by a chained call using `&.`' do
    expect_no_offenses(<<~RUBY)
      if test
        something
      end&.inspect
    RUBY
  end

  it "doesn't break if-end when used as RHS of local var assignment" do
    expect_offense(<<~RUBY)
      a = if b
          ^^ Favor modifier `if` usage when having a single-line body. [...]
        1
      end
    RUBY

    expect_correction(<<~RUBY)
      a = (1 if b)
    RUBY
  end

  it "doesn't break if-end when used as RHS of instance var assignment" do
    expect_offense(<<~RUBY)
      @a = if b
           ^^ Favor modifier `if` usage when having a single-line body. [...]
        1
      end
    RUBY

    expect_correction(<<~RUBY)
      @a = (1 if b)
    RUBY
  end

  it "doesn't break if-end when used as RHS of class var assignment" do
    expect_offense(<<~RUBY)
      @@a = if b
            ^^ Favor modifier `if` usage when having a single-line body. [...]
        1
      end
    RUBY

    expect_correction(<<~RUBY)
      @@a = (1 if b)
    RUBY
  end

  it "doesn't break if-end when used as RHS of constant assignment" do
    expect_offense(<<~RUBY)
      A = if b
          ^^ Favor modifier `if` usage when having a single-line body. [...]
        1
      end
    RUBY

    expect_correction(<<~RUBY)
      A = (1 if b)
    RUBY
  end

  it "doesn't break if-end when used as RHS of binary arithmetic" do
    expect_offense(<<~RUBY)
      a + if b
          ^^ Favor modifier `if` usage when having a single-line body. [...]
        1
      end
    RUBY

    expect_correction(<<~RUBY)
      a + (1 if b)
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

  it 'ignores if-end when used as LHS of binary arithmetic' do
    expect_no_offenses(<<~RUBY)
      if test
        1
      end + 2
    RUBY
  end

  context 'if-end is argument to a parenthesized method call' do
    it "doesn't add redundant parentheses" do
      expect_offense(<<~RUBY)
        puts("string", if a
                       ^^ Favor modifier `if` usage when having a single-line body. [...]
          1
        end)
      RUBY

      expect_correction(<<~RUBY)
        puts("string", 1 if a)
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
    include_context 'with LineLength settings', enabled: false

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
      let(:source) do
        <<~RUBY
          x = if a
            #{'b' * body_length}
          end
        RUBY
      end

      context 'when it is short enough to fit on a single line' do
        let(:body_length) { 69 }

        it 'corrects it to the single-line form' do
          corrected = autocorrect_source(source)
          expect(corrected).to eq "x = (#{'b' * body_length} if a)\n"
        end
      end

      context 'when it is not short enough to fit on a single line' do
        let(:body_length) { 70 }

        it 'accepts it in the multiline form' do
          expect_no_offenses(source)
        end
      end
    end

    context 'with variable being on the previous line' do
      let(:source) do
        <<~RUBY
          x =
            if a
              #{'b' * body_length}
            end
        RUBY
      end

      context 'when it is short enough to fit on a single line' do
        let(:body_length) { 71 }

        it 'corrects it to the single-line form' do
          corrected = autocorrect_source(source)
          expect(corrected).to eq "x =\n  (#{'b' * body_length} if a)\n"
        end
      end

      context 'when it is not short enough to fit on a single line' do
        let(:body_length) { 72 }

        it 'accepts it in the multiline form' do
          expect_no_offenses(source)
        end
      end
    end
  end

  context 'when if-end condition is an element of an array' do
    let(:source) do
      <<~RUBY
        [
          if a
            #{'b' * body_length}
          end
        ]
      RUBY
    end

    context 'when short enough to fit on a single line' do
      let(:body_length) { 71 }

      it 'corrects it to the single-line form' do
        corrected = autocorrect_source(source)
        expect(corrected).to eq "[\n  (#{'b' * body_length} if a)\n]\n"
      end
    end

    context 'when not short enough to fit on a single line' do
      let(:body_length) { 72 }

      it 'accepts it in the multiline form' do
        expect_no_offenses(source)
      end
    end
  end

  context 'when if-end condition is a value in a hash' do
    let(:source) do
      <<~RUBY
        {
          x: if a
               #{'b' * body_length}
             end
        }
      RUBY
    end

    context 'when it is short enough to fit on a single line' do
      let(:body_length) { 68 }

      it 'corrects it to the single-line form' do
        corrected = autocorrect_source(source)
        expect(corrected).to eq "{\n  x: (#{'b' * body_length} if a)\n}\n"
      end
    end

    context 'when it is not short enough to fit on a single line' do
      let(:body_length) { 69 }

      it 'accepts it in the multiline form' do
        expect_no_offenses(source)
      end
    end
  end

  context 'when if-end condition has a first line comment' do
    let(:source) do
      <<~RUBY
        if foo # #{'c' * comment_length}
          bar
        end
      RUBY
    end

    context 'when it is short enough to fit on a single line' do
      let(:comment_length) { 67 }

      it 'corrects it to the single-line form' do
        corrected = autocorrect_source(source)
        expect(corrected).to eq "bar if foo # #{'c' * comment_length}\n"
      end
    end

    context 'when it is not short enough to fit on a single line' do
      let(:comment_length) { 68 }

      it 'accepts it in the multiline form' do
        expect_no_offenses(source)
      end
    end
  end
end
