# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::IfUnlessModifier do
  include StatementModifierHelper

  subject(:cop) { described_class.new(config) }

  let(:config) do
    RuboCop::Config.new('Metrics/LineLength' => line_length_config)
  end
  let(:line_length_config) do
    {
      'Enabled' => true,
      'Max' => 80,
      'AllowURI' => allow_uri,
      'IgnoreCopDirectives' => ignore_cop_directives,
      'URISchemes' => %w[http https]
    }
  end
  let(:allow_uri) { true }
  let(:ignore_cop_directives) { true }

  context 'modifier if that does not fit on one line' do
    let(:spaces) { ' ' * 59 }
    let(:source) { "puts '#{spaces}' if condition" }
    let(:long_url) do
      'https://some.example.com/with/a/rather?long&and=very&complicated=path'
    end

    context 'when Metrics/LineLength is enabled' do
      it 'corrects it to normal form' do
        expect(source.length).to be(79) # That's 81 including indentation.
        expect_offense(<<~RUBY)
          def f
            # Comment 1
            #{source} # Comment 2
            #{spaces}        ^^ Modifier form of `if` makes the line too long.
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

      describe 'IgnoreCopDirectives' do
        let(:spaces) { ' ' * 57 }
        let(:comment) { '# rubocop:disable Style/For' }
        let(:source) { "puts '#{spaces}' if condition" }

        context 'and the long line is allowed because IgnoreCopDirectives is ' \
                'true' do
          it 'accepts' do
            expect(source.length).to eq(77) # That's 79 including indentation.
            expect_no_offenses(<<~RUBY)
              def f
                #{source} #{comment}
              end
            RUBY
          end
        end

        context 'and the long line is too long because IgnoreCopDirectives ' \
                'is false' do
          let(:ignore_cop_directives) { false }

          it 'registers an offense' do
            expect_offense(<<~RUBY)
              def f
                #{source} #{comment}
                #{spaces}        ^^ Modifier form of `if` makes the line too long.
              end
            RUBY
          end
        end
      end
    end

    context 'when Metrics/LineLength is disabled in configuration' do
      let(:line_length_config) { { 'Enabled' => false, 'Max' => 80 } }

      it 'accepts' do
        expect_no_offenses(<<~RUBY)
          def f
            #{source}
          end
        RUBY
      end
    end

    context 'when Metrics/LineLength is disabled with enable/disable ' \
            'comments' do
      it 'accepts' do
        expect_no_offenses(<<~RUBY)
          def f
            # rubocop:disable Metrics/LineLength
            #{source}
            # rubocop:enable Metrics/LineLength
          end
        RUBY
      end
    end

    context 'when Metrics/LineLength is disabled with an EOL comment' do
      it 'accepts' do
        expect_no_offenses(<<~RUBY)
          def f
            #{source} # rubocop:disable Metrics/LineLength
          end
        RUBY
      end
    end
  end

  context 'multiline if that fits on one line' do
    let(:source) do
      # Empty lines should make no difference.
      <<~RUBY
        if #{condition}
          #{body}

        end
      RUBY
    end

    let(:condition) { 'a' * 38 }
    let(:body) { 'b' * 38 }

    it 'registers an offense' do
      # This if statement fits exactly on one line if written as a
      # modifier.
      expect("#{body} if #{condition}".length).to eq(80)

      inspect_source(source)
      expect(cop.messages).to eq(
        ['Favor modifier `if` usage when having a single-line' \
         ' body. Another good alternative is the usage of control flow' \
         ' `&&`/`||`.']
      )
    end

    it 'does auto-correction' do
      corrected = autocorrect_source(source)
      expect(corrected).to eq "#{body} if #{condition}\n"
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
  end

  context 'multiline if that fits on one line with comment on first line' do
    let(:source) do
      <<~RUBY
        if a # comment
          b
        end
      RUBY
    end

    it 'registers an offense' do
      expect_offense(<<~RUBY)
        if a # comment
        ^^ Favor modifier `if` usage when having a single-line body. Another good alternative is the usage of control flow `&&`/`||`.
          b
        end
      RUBY
    end

    it 'does auto-correction and preserves comment' do
      corrected = autocorrect_source(source)
      expect(corrected).to eq "b if a # comment\n"
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
    let(:source) do
      <<~RUBY
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
          b
        end
      RUBY
    end

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
    end

    it 'does auto-correction' do
      corrected = autocorrect_source(source)
      expect(corrected).to eq(<<~RUBY)
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

  it "accepts multiline if that doesn't fit on one line" do
    check_too_long('if')
  end

  it 'accepts multiline if whose body is more than one line' do
    check_short_multiline('if')
  end

  context 'multiline unless that fits on one line' do
    let(:source) do
      <<~RUBY
        unless a
          b
        end
      RUBY
    end

    it 'registers an offense' do
      expect_offense(<<~RUBY)
        unless a
        ^^^^^^ Favor modifier `unless` usage when having a single-line body. Another good alternative is the usage of control flow `&&`/`||`.
          b
        end
      RUBY
    end

    it 'does auto-correction' do
      corrected = autocorrect_source(source)
      expect(corrected).to eq "b unless a\n"
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

  it 'accepts an empty condition' do
    check_empty('if')
    check_empty('unless')
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

  context 'with implicit match conditional' do
    let(:source) do
      <<-RUBY.strip_margin('|')
        |  if #{conditional}
        |    #{body}
        |  end
      RUBY
    end

    let(:body) { 'b' * 36 }

    context 'when a multiline if fits on one line' do
      let(:conditional) { "/#{'a' * 36}/" }

      it 'registers an offense' do
        expect("  #{body} if #{conditional}".length).to eq(80)

        inspect_source(source)
        expect(cop.offenses.size).to eq(1)
      end

      it 'does auto-correction' do
        corrected = autocorrect_source(source)
        expect(corrected).to eq "  #{body} if #{conditional}\n"
      end
    end

    context "when a multiline if doesn't fit on one line" do
      let(:conditional) { "/#{'a' * 37}/" }

      it 'accepts' do
        expect("  #{body} if #{conditional}".length).to eq(81)

        expect_no_offenses(source)
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

  it "doesn't break if-end when used as RHS of local var assignment" do
    corrected = autocorrect_source(<<~RUBY)
      a = if b
        1
      end
    RUBY
    expect(corrected).to eq "a = (1 if b)\n"
  end

  it "doesn't break if-end when used as RHS of instance var assignment" do
    corrected = autocorrect_source(<<~RUBY)
      @a = if b
        1
      end
    RUBY
    expect(corrected).to eq "@a = (1 if b)\n"
  end

  it "doesn't break if-end when used as RHS of class var assignment" do
    corrected = autocorrect_source(<<~RUBY)
      @@a = if b
        1
      end
    RUBY
    expect(corrected).to eq "@@a = (1 if b)\n"
  end

  it "doesn't break if-end when used as RHS of constant assignment" do
    corrected = autocorrect_source(<<~RUBY)
      A = if b
        1
      end
    RUBY
    expect(corrected).to eq "A = (1 if b)\n"
  end

  it "doesn't break if-end when used as RHS of binary arithmetic" do
    corrected = autocorrect_source(<<~RUBY)
      a + if b
        1
      end
    RUBY
    expect(corrected).to eq "a + (1 if b)\n"
  end

  it 'accepts if-end when used as LHS of binary arithmetic' do
    expect_no_offenses(<<~RUBY)
      if test
        1
      end + 2
    RUBY
  end

  context 'if-end is argument to a parenthesized method call' do
    it "doesn't add redundant parentheses" do
      corrected = autocorrect_source(<<~RUBY)
        puts("string", if a
          1
        end)
      RUBY
      expect(corrected).to eq "puts(\"string\", 1 if a)\n"
    end
  end

  context 'if-end is argument to a non-parenthesized method call' do
    it 'adds parentheses so as not to change meaning' do
      corrected = autocorrect_source(<<~RUBY)
        puts "string", if a
          1
        end
      RUBY
      expect(corrected).to eq "puts \"string\", (1 if a)\n"
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

  context 'with disabled Layout/Tab cop' do
    shared_examples 'with tabs indentation' do
      let(:source) do
        # Empty lines should make no difference.
        <<-RUBY
						if #{condition}
							#{body}
						end
        RUBY
      end

      let(:body) { 'bbb' }

      context 'it fits on one line' do
        let(:condition) { 'aaa' }

        it 'registers an offense' do
          # This if statement fits exactly on one line if written as a
          # modifier.
          expect("#{body} if #{condition}".length).to eq(10)

          inspect_source(source)
          expect(cop.messages).to eq(
            ['Favor modifier `if` usage when having a single-line' \
             ' body. Another good alternative is the usage of control flow' \
             ' `&&`/`||`.']
          )
        end
      end

      context "it doesn't fit on one line" do
        let(:condition) { 'aaaa' }

        it "doesn't register an offense" do
          # This if statement fits exactly on one line if written as a
          # modifier.
          expect("#{body} if #{condition}".length).to eq(11)

          expect_no_offenses(source)
        end
      end
    end

    context 'with Layout/Tab: IndentationWidth config' do
      let(:config) do
        RuboCop::Config.new(
          'Layout/IndentationWidth' => {
            'Width' => 1
          },
          'Layout/Tab' => {
            'Enabled' => false,
            'IndentationWidth' => 2
          },
          'Metrics/LineLength' => { 'Max' => 10 + 12 } # 12 is indentation
        )
      end

      it_behaves_like 'with tabs indentation'
    end

    context 'with Layout/IndentationWidth: Width config' do
      let(:config) do
        RuboCop::Config.new(
          'Layout/IndentationWidth' => {
            'Width' => 1
          },
          'Layout/Tab' => {
            'Enabled' => false
          },
          'Metrics/LineLength' => { 'Max' => 10 + 6 } # 6 is indentation
        )
      end

      it_behaves_like 'with tabs indentation'
    end

    context 'without any IndentationWidth config' do
      let(:config) do
        RuboCop::Config.new(
          'Layout/Tab' => {
            'Enabled' => false
          },
          'Metrics/LineLength' => { 'Max' => 10 + 12 } # 12 is indentation
        )
      end

      it_behaves_like 'with tabs indentation'
    end
  end

  context 'when Metrics/LineLength is disabled' do
    let(:config) do
      RuboCop::Config.new(
        'Metrics/LineLength' => {
          'Enabled' => false,
          'Max' => 80
        }
      )
    end

    it 'registers an offense even for a long modifier statement' do
      expect_offense(<<~RUBY)
        if foo
        ^^ Favor modifier `if` usage when having a single-line body. Another good alternative is the usage of control flow `&&`/`||`.
          "This string would make the line longer than eighty characters if combined with the statement."
        end
      RUBY
    end
  end
end
