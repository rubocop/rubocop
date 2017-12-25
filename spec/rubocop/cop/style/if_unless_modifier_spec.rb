# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::IfUnlessModifier do
  include StatementModifierHelper

  subject(:cop) { described_class.new(config) }

  let(:config) do
    hash = { 'Metrics/LineLength' => { 'Max' => 80 } }
    RuboCop::Config.new(hash)
  end

  context 'multiline if that fits on one line' do
    let(:source) do
      # Empty lines should make no difference.
      <<-RUBY.strip_indent
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
        expect_no_offenses(<<-RUBY.strip_indent)
          if condition
            do_this; do_that
          end
        RUBY
      end
    end
  end

  context 'multiline if that fits on one line with comment on first line' do
    let(:source) do
      <<-RUBY.strip_indent
        if a # comment
          b
        end
      RUBY
    end

    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
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
      expect_no_offenses(<<-RUBY.strip_indent)
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
      <<-RUBY.strip_indent
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
      expect_offense(<<-RUBY.strip_indent)
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
      expect(corrected).to eq(<<-RUBY.strip_indent)
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
    check_too_long(cop, 'if')
  end

  it 'accepts multiline if whose body is more than one line' do
    check_short_multiline(cop, 'if')
  end

  context 'multiline unless that fits on one line' do
    let(:source) do
      <<-RUBY.strip_indent
        unless a
          b
        end
      RUBY
    end

    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
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
    expect_no_offenses(<<-RUBY.strip_indent)
      unless a
        b # A comment
      end
    RUBY
  end

  it 'accepts if-else-end' do
    expect_no_offenses(<<-RUBY.strip_indent)
      if args.last.is_a? Hash then args.pop else Hash.new end
    RUBY
  end

  it 'accepts an empty condition' do
    check_empty(cop, 'if')
    check_empty(cop, 'unless')
  end

  it 'accepts if/elsif' do
    expect_no_offenses(<<-RUBY.strip_indent)
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

        inspect_source(source)
        expect(cop.offenses.empty?).to be(true)
      end
    end
  end

  it 'accepts if-end followed by a chained call' do
    expect_no_offenses(<<-RUBY.strip_indent)
      if test
        something
      end.inspect
    RUBY
  end

  it "doesn't break if-end when used as RHS of local var assignment" do
    corrected = autocorrect_source(<<-RUBY.strip_indent)
      a = if b
        1
      end
    RUBY
    expect(corrected).to eq "a = (1 if b)\n"
  end

  it "doesn't break if-end when used as RHS of instance var assignment" do
    corrected = autocorrect_source(<<-RUBY.strip_indent)
      @a = if b
        1
      end
    RUBY
    expect(corrected).to eq "@a = (1 if b)\n"
  end

  it "doesn't break if-end when used as RHS of class var assignment" do
    corrected = autocorrect_source(<<-RUBY.strip_indent)
      @@a = if b
        1
      end
    RUBY
    expect(corrected).to eq "@@a = (1 if b)\n"
  end

  it "doesn't break if-end when used as RHS of constant assignment" do
    corrected = autocorrect_source(<<-RUBY.strip_indent)
      A = if b
        1
      end
    RUBY
    expect(corrected).to eq "A = (1 if b)\n"
  end

  it "doesn't break if-end when used as RHS of binary arithmetic" do
    corrected = autocorrect_source(<<-RUBY.strip_indent)
      a + if b
        1
      end
    RUBY
    expect(corrected).to eq "a + (1 if b)\n"
  end

  it 'accepts if-end when used as LHS of binary arithmetic' do
    expect_no_offenses(<<-RUBY.strip_indent)
      if test
        1
      end + 2
    RUBY
  end

  context 'if-end is argument to a parenthesized method call' do
    it "doesn't add redundant parentheses" do
      corrected = autocorrect_source(<<-RUBY.strip_indent)
        puts("string", if a
          1
        end)
      RUBY
      expect(corrected).to eq "puts(\"string\", 1 if a)\n"
    end
  end

  context 'if-end is argument to a non-parenthesized method call' do
    it 'adds parentheses so as not to change meaning' do
      corrected = autocorrect_source(<<-RUBY.strip_indent)
        puts "string", if a
          1
        end
      RUBY
      expect(corrected).to eq "puts \"string\", (1 if a)\n"
    end
  end

  context 'if-end with conditional as body' do
    it 'accepts' do
      expect_no_offenses(<<-RUBY.strip_indent)
        if condition
          foo ? "bar" : "baz"
        end
      RUBY
    end
  end

  context 'unless-end with conditional as body' do
    it 'accepts' do
      expect_no_offenses(<<-RUBY.strip_indent)
        unless condition
          foo ? "bar" : "baz"
        end
      RUBY
    end
  end
end
