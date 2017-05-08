# frozen_string_literal: true

describe RuboCop::Cop::Layout::MultilineMethodCallIndentation do
  subject(:cop) { described_class.new(config) }
  let(:config) do
    merged = RuboCop::ConfigLoader
             .default_configuration['Layout/MultilineMethodCallIndentation']
             .merge(cop_config)
             .merge('IndentationWidth' => cop_indent)
    RuboCop::Config
      .new('Layout/MultilineMethodCallIndentation' => merged,
           'Layout/IndentationWidth' => { 'Width' => indentation_width })
  end
  let(:indentation_width) { 2 }
  let(:cop_indent) { nil } # use indentation width from Layout/IndentationWidth

  shared_examples 'common' do
    it 'accepts indented methods in LHS of []= assignment' do
      expect_no_offenses(<<-END.strip_indent)
        a
          .b[c] = 0
      END
    end

    it 'accepts indented methods inside and outside a block' do
      inspect_source(cop, <<-END.strip_indent)
        a = b.map do |c|
          c
            .b
            .d do
              x
                .y
            end
        end
      END
      expect(cop.messages).to be_empty
    end

    it 'accepts indentation relative to first receiver' do
      expect_no_offenses(<<-END.strip_indent)
        node
          .children.map { |n| string_source(n) }.compact
          .any? { |s| preferred.any? { |d| s.include?(d) } }
      END
    end

    it 'accepts indented methods in ordinary statement' do
      inspect_source(cop, <<-END.strip_indent)
        a.
          b
      END
      expect(cop.messages).to be_empty
    end

    it 'accepts no extra indentation of third line' do
      inspect_source(cop, <<-END.strip_margin('|'))
        |   a.
        |     b.
        |     c
      END
      expect(cop.offenses).to be_empty
    end

    it 'accepts indented methods in for body' do
      inspect_source(cop, <<-END.strip_indent)
        for x in a
          something.
            something_else
        end
      END
      expect(cop.highlights).to be_empty
    end

    it 'accepts alignment inside a grouped expression' do
      inspect_source(cop, <<-END.strip_indent)
        (a.
         b)
      END
      expect(cop.messages).to be_empty
    end

    it 'accepts an expression where the first method spans multiple lines' do
      inspect_source(cop, <<-END.strip_indent)
        subject.each do |item|
          result = resolve(locale) and return result
        end.a
      END
      expect(cop.messages).to be_empty
    end

    it 'accepts any indentation of parameters to #[]' do
      inspect_source(cop, <<-END.strip_indent)
        payment = Models::IncomingPayments[
                id:      input['incoming-payment-id'],
                   user_id: @user[:id]]
      END
      expect(cop.messages).to be_empty
    end

    it "doesn't fail on unary operators" do
      inspect_source(cop, <<-END.strip_indent)
        def foo
          !0
          .nil?
        end
      END
      expect(cop.offenses.size).to eq(1)
    end
  end

  shared_examples 'common for aligned and indented' do
    it 'accepts even indentation of consecutive lines in typical RSpec code' do
      inspect_source(cop, <<-END.strip_indent)
        expect { Foo.new }.
          to change { Bar.count }.
          from(1).to(2)
      END
      expect(cop.messages).to be_empty
    end

    it 'registers an offense for no indentation of second line' do
      inspect_source(cop, <<-END.strip_indent)
        a.
        b
      END
      expect(cop.messages)
        .to eq(['Use 2 (not 0) spaces for indenting an expression spanning ' \
                'multiple lines.'])
      expect(cop.highlights).to eq(['b'])
    end

    it 'registers an offense for 3 spaces indentation of second line' do
      inspect_source(cop, <<-END.strip_indent)
        a.
           b
        c.
           d
      END
      expect(cop.messages)
        .to eq(['Use 2 (not 3) spaces for indenting an expression spanning ' \
                'multiple lines.'] * 2)
      expect(cop.highlights).to eq(%w[b d])
    end

    it 'registers an offense for extra indentation of third line' do
      inspect_source(cop, <<-END.strip_margin('|'))
        |   a.
        |     b.
        |       c
      END
      expect(cop.messages)
        .to eq(['Use 2 (not 4) spaces for indenting an expression spanning ' \
                'multiple lines.'])
      expect(cop.highlights).to eq(['c'])
    end

    it 'registers an offense for the emacs ruby-mode 1.1 indentation of an ' \
       'expression in an array' do
      inspect_source(cop, <<-END.strip_margin('|'))
        |  [
        |   a.
        |   b
        |  ]
      END
      expect(cop.messages)
        .to eq(['Use 2 (not 0) spaces for indenting an expression spanning ' \
                'multiple lines.'])
      expect(cop.highlights).to eq(['b'])
    end

    it 'registers an offense for extra indentation of 3rd line in typical ' \
       'RSpec code' do
      inspect_source(cop, <<-END.strip_indent)
        expect { Foo.new }.
          to change { Bar.count }.
              from(1).to(2)
      END
      expect(cop.messages).to eq(['Use 2 (not 6) spaces for indenting an ' \
                                  'expression spanning multiple lines.'])
      expect(cop.highlights).to eq(['from'])
    end

    it 'registers an offense for proc call without a selector' do
      inspect_source(cop, <<-END.strip_indent)
        a
         .(args)
      END
      expect(cop.messages).to eq(['Use 2 (not 1) spaces for indenting an ' \
                                  'expression spanning multiple lines.'])
      expect(cop.highlights).to eq(['.('])
    end

    it 'registers an offense for one space indentation of second line' do
      inspect_source(cop, <<-END.strip_indent)
        a
         .b
      END
      expect(cop.messages).to eq(['Use 2 (not 1) spaces for indenting an ' \
                                  'expression spanning multiple lines.'])
      expect(cop.highlights).to eq(['.b'])
    end
  end

  context 'when EnforcedStyle is aligned' do
    let(:cop_config) { { 'EnforcedStyle' => 'aligned' } }

    include_examples 'common'
    include_examples 'common for aligned and indented'

    # We call it semantic alignment when a dot is aligned with the first dot in
    # a chain of calls, and that first dot does not begin its line.
    context 'for semantic alignment' do
      it 'accepts method being aligned with method' do
        expect_no_offenses(<<-END.strip_indent)
          User.all.first
              .age.to_s
        END
      end

      it 'accepts method being aligned with method that is an argument' do
        inspect_source(cop,
                       ['authorize scope.includes(:user)',
                        '               .order(:name)'])
        expect(cop.offenses).to be_empty
      end

      it 'accepts method being aligned with method that is an argument in ' \
         'assignment' do
        inspect_source(cop,
                       ['user = authorize scope.includes(:user)',
                        '                      .order(:name)'])
        expect(cop.offenses).to be_empty
      end

      it 'accepts method being aligned with method in assignment' do
        expect_no_offenses(<<-END.strip_indent)
          age = User.all.first
                    .age.to_s
        END
      end

      it 'accepts aligned method even when an aref is in the chain' do
        expect_no_offenses(<<-END.strip_indent)
          foo = '123'.a
                     .b[1]
                     .c
        END
      end

      it 'accepts aligned method even when an aref is first in the chain' do
        expect_no_offenses(<<-END.strip_indent)
          foo = '123'[1].a
                        .b
                        .c
        END
      end

      it "doesn't fail on a chain of aref calls" do
        expect_no_offenses('a[1][2][3]')
      end

      it 'accepts aligned method with blocks in operation assignment' do
        expect_no_offenses(<<-END.strip_indent)
          @comment_lines ||=
            src.comments
               .select { |c| begins_its_line?(c) }
               .map { |c| c.loc.line }
        END
      end

      it 'accepts 3 aligned methods' do
        expect_no_offenses(<<-END.strip_indent)
          a_class.new(severity, location, 'message', 'CopName')
                 .severity
                 .level
        END
      end

      it 'registers an offense for unaligned methods' do
        expect_offense(<<-RUBY.strip_indent)
          User.a
            .b
            ^^ Align `.b` with `.a` on line 1.
           .c
           ^^ Align `.c` with `.a` on line 1.
        RUBY
      end

      it 'registers an offense for unaligned method in block body' do
        expect_offense(<<-RUBY.strip_indent)
          a do
            b.c
              .d
              ^^ Align `.d` with `.c` on line 2.
          end
        RUBY
      end

      it 'auto-corrects' do
        new_source = autocorrect_source(cop, <<-END.strip_indent)
          User.all.first
            .age.to_s
        END
        expect(new_source).to eq(<<-END.strip_indent)
          User.all.first
              .age.to_s
        END
      end
    end

    it 'accepts correctly aligned methods in operands' do
      expect_no_offenses(<<-END.strip_indent)
        1 + a
            .b
            .c + d.
                 e
      END
    end

    it 'accepts correctly aligned methods in assignment' do
      expect_no_offenses(<<-END.strip_indent)
        def investigate(processed_source)
          @modifier = processed_source
                      .tokens
                      .select { |t| t.type == :k }
                      .map(&:pos)
        end
      END
    end

    it 'accepts aligned methods in if + assignment' do
      expect_no_offenses(<<-END.strip_indent)
        KeyMap = Hash.new do |map, key|
          value = if key.respond_to?(:to_str)
            key
          else
            key.to_s.split('_').
              each { |w| w.capitalize! }.
              join('-')
          end
          keymap_mutex.synchronize { map[key] = value }
        end
      END
    end

    it 'accepts indented method when there is nothing to align with' do
      expect_no_offenses(<<-END.strip_indent)
        expect { custom_formatter_class('NonExistentClass') }
          .to raise_error(NameError)
      END
    end

    it 'registers an offense for one space indentation of third line' do
      expect_offense(<<-RUBY.strip_indent)
        a
          .b
         .c
         ^^ Use 2 (not 1) spaces for indenting an expression spanning multiple lines.
      RUBY
    end

    it 'accepts indented and aligned methods in binary operation' do
      # b is indented relative to a
      # .d is aligned with c
      expect_no_offenses(<<-END.strip_indent)
        a.
          b + c
              .d
      END
    end

    it 'accepts aligned methods in if condition' do
      inspect_source(cop, <<-END.strip_indent)
        if a.
           b
          something
        end
      END
      expect(cop.messages).to be_empty
    end

    it 'accepts aligned methods in a begin..end block' do
      inspect_source(cop, <<-END.strip_indent)
        @dependencies ||= begin
          DEFAULT_DEPENDENCIES
            .reject { |e| e }
            .map { |e| e }
        end
      END
      expect(cop.messages).to be_empty
    end

    it 'registers an offense for misaligned methods in if condition' do
      inspect_source(cop, <<-END.strip_indent)
        if a.
            b
          something
        end
      END
      expect(cop.messages).to eq(['Align `b` with `a.` on line 1.'])
      expect(cop.highlights).to eq(['b'])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'does not check binary operations when string wrapped with backslash' do
      inspect_source(cop,
                     ["flash[:error] = 'Here is a string ' \\",
                      "                'That spans' <<",
                      "  'multiple lines'"])
      expect(cop.offenses).to be_empty
    end

    it 'does not check binary operations when string wrapped with +' do
      expect_no_offenses(<<-END.strip_indent)
        flash[:error] = 'Here is a string ' +
                        'That spans' <<
          'multiple lines'
      END
    end

    it 'registers an offense for misaligned method in []= call' do
      expect_offense(<<-RUBY.strip_indent)
        flash[:error] = here_is_a_string.
                        that_spans.
           multiple_lines
           ^^^^^^^^^^^^^^ Align `multiple_lines` with `here_is_a_string.` on line 1.
      RUBY
    end

    it 'registers an offense for misaligned methods in unless condition' do
      inspect_source(cop, <<-END.strip_indent)
        unless a
        .b
          something
        end
      END
      expect(cop.messages).to eq(['Align `.b` with `a` on line 1.'])
      expect(cop.highlights).to eq(['.b'])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'registers an offense for misaligned methods in while condition' do
      expect_offense(<<-RUBY.strip_indent)
        while a.
            b
            ^ Align `b` with `a.` on line 1.
          something
        end
      RUBY
    end

    it 'registers an offense for misaligned methods in until condition' do
      expect_offense(<<-RUBY.strip_indent)
        until a.
            b
            ^ Align `b` with `a.` on line 1.
          something
        end
      RUBY
    end

    it 'accepts aligned method in return' do
      expect_no_offenses(<<-END.strip_indent)
        def a
          return b.
                 c
        end
      END
    end

    it 'accepts aligned method in assignment + block + assignment' do
      expect_no_offenses(<<-END.strip_indent)
        a = b do
          c.d = e.
                f
        end
      END
    end

    it 'accepts aligned methods in assignment' do
      inspect_source(cop, <<-END.strip_indent)
        formatted_int = int_part
                        .to_s
                        .reverse
                        .gsub(/...(?=.)/, '\&_')
      END
      expect(cop.messages).to be_empty
    end

    it 'registers an offense for misaligned methods in local variable ' \
       'assignment' do
      inspect_source(cop, <<-END.strip_indent)
        a = b.c.
         d
      END
      expect(cop.messages).to eq(['Align `d` with `b.c.` on line 1.'])
      expect(cop.highlights).to eq(['d'])
    end

    it 'accepts aligned methods in constant assignment' do
      expect_no_offenses(<<-END.strip_indent)
        A = b
            .c
      END
    end

    it 'accepts aligned methods in operator assignment' do
      expect_no_offenses(<<-END.strip_indent)
        a +=
          b
          .c
      END
    end

    it 'registers an offense for unaligned methods in assignment' do
      expect_offense(<<-RUBY.strip_indent)
        bar = Foo
          .a
          ^^ Align `.a` with `Foo` on line 1.
              .b(c)
      RUBY
    end

    it 'auto-corrects' do
      new_source = autocorrect_source(cop, <<-END.strip_indent)
        until a.
            b
          something
        end
      END
      expect(new_source).to eq(<<-END.strip_indent)
        until a.
              b
          something
        end
      END
    end
  end

  shared_examples 'both indented* styles' do
    # We call it semantic alignment when a dot is aligned with the first dot in
    # a chain of calls, and that first dot does not begin its line. But for the
    # indented style, it doesn't come into play.
    context 'for possible semantic alignment' do
      it 'accepts indented methods' do
        inspect_source(cop, <<-END.strip_indent)
          User.a
            .c
            .b
        END
        expect(cop.messages).to be_empty
        expect(cop.highlights).to be_empty
        expect(cop.offenses).to be_empty
      end
    end
  end

  context 'when EnforcedStyle is indented_relative_to_receiver' do
    let(:cop_config) { { 'EnforcedStyle' => 'indented_relative_to_receiver' } }

    include_examples 'common'
    include_examples 'both indented* styles'

    it 'accepts correctly indented methods in operation' do
      inspect_source(cop, <<-END.strip_margin('|'))
        |        1 + a
        |              .b
        |              .c
      END
      expect(cop.highlights).to be_empty
      expect(cop.offenses).to be_empty
    end

    it 'accepts indentation of consecutive lines in typical RSpec code' do
      inspect_source(cop, <<-END.strip_indent)
        expect { Foo.new }.
          to change { Bar.count }.
               from(1).to(2)
      END
      expect(cop.messages).to be_empty

      inspect_source(cop, <<-END.strip_indent)
        expect { Foo.new }.to change { Bar.count }
                                .from(1).to(2)
      END
      expect(cop.messages).to be_empty
    end

    it 'registers an offense for no indentation of second line' do
      expect_offense(<<-RUBY.strip_indent)
        a.
        b
        ^ Indent `b` 2 spaces more than `a` on line 1.
      RUBY
    end

    it 'registers an offense for extra indentation of 3rd line in typical ' \
       'RSpec code' do
      inspect_source(cop, <<-END.strip_indent)
        expect { Foo.new }.
          to change { Bar.count }.
              from(1).to(2)
      END
      expect(cop.messages).to eq(['Indent `from` 2 spaces more than `change ' \
                                  '{ Bar.count }` on line 2.'])
      expect(cop.highlights).to eq(['from'])
    end

    it 'registers an offense for proc call without a selector' do
      expect_offense(<<-RUBY.strip_indent)
        a
         .(args)
         ^^ Indent `.(` 2 spaces more than `a` on line 1.
      RUBY
    end

    it 'registers an offense for one space indentation of second line' do
      expect_offense(<<-RUBY.strip_indent)
        a
         .b
         ^^ Indent `.b` 2 spaces more than `a` on line 1.
      RUBY
    end

    it 'registers an offense for 3 spaces indentation of second line' do
      expect_offense(<<-RUBY.strip_indent)
        a.
           b
           ^ Indent `b` 2 spaces more than `a` on line 1.
        c.
           d
           ^ Indent `d` 2 spaces more than `c` on line 3.
      RUBY
    end

    it 'registers an offense for extra indentation of third line' do
      expect_offense(<<-RUBY.strip_indent)
           a.
             b.
               c
               ^ Indent `c` 2 spaces more than `a` on line 1.
      RUBY
    end

    it 'registers an offense for the emacs ruby-mode 1.1 indentation of an ' \
       'expression in an array' do
      inspect_source(cop, <<-END.strip_margin('|'))
        |  [
        |   a.
        |   b
        |  ]
      END
      expect(cop.messages)
        .to eq(['Indent `b` 2 spaces more than `a` on line 2.'])
      expect(cop.highlights).to eq(['b'])
    end

    it 'auto-corrects' do
      new_source = autocorrect_source(cop, <<-END.strip_indent)
        until a.
              b
          something
        end
      END
      expect(new_source).to eq(<<-END.strip_indent)
        until a.
                b
          something
        end
      END
    end
  end

  context 'when EnforcedStyle is indented' do
    let(:cop_config) { { 'EnforcedStyle' => 'indented' } }

    include_examples 'common'
    include_examples 'common for aligned and indented'
    include_examples 'both indented* styles'

    it 'accepts correctly indented methods in operation' do
      inspect_source(cop, <<-END.strip_margin('|'))
        |        1 + a
        |          .b
        |          .c
      END
      expect(cop.offenses).to be_empty
      expect(cop.highlights).to be_empty
    end

    it 'registers an offense for one space indentation of third line' do
      expect_offense(<<-RUBY.strip_indent)
        a
          .b
         .c
         ^^ Use 2 (not 1) spaces for indenting an expression spanning multiple lines.
      RUBY
    end

    it 'accepts indented methods in if condition' do
      inspect_source(cop, <<-END.strip_indent)
        if a.
            b
          something
        end
      END
      expect(cop.messages).to be_empty
    end

    it 'registers an offense for aligned methods in if condition' do
      inspect_source(cop, <<-END.strip_indent)
        if a.
           b
          something
        end
      END
      expect(cop.messages).to eq(['Use 4 (not 3) spaces for indenting a ' \
                                  'condition in an `if` statement spanning ' \
                                  'multiple lines.'])
      expect(cop.highlights).to eq(['b'])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'accepts normal indentation of method parameters' do
      inspect_source(cop, <<-END.strip_indent)
        Parser::Source::Range.new(expr.source_buffer,
                                  begin_pos,
                                  begin_pos + line.length)
      END
      expect(cop.messages).to be_empty
    end

    it 'accepts any indentation of method parameters' do
      inspect_source(cop, <<-END.strip_indent)
        a(b.
            c
        .d)
      END
      expect(cop.messages).to be_empty
    end

    it 'accepts normal indentation inside grouped expression' do
      inspect_source(cop, <<-END.strip_indent)
        arg_array.size == a.size && (
          arg_array == a ||
          arg_array.map(&:children) == a.map(&:children)
        )
      END
      expect(cop.messages).to be_empty
    end

    [
      %w[an if],
      %w[an unless],
      %w[a while],
      %w[an until]
    ].each do |article, keyword|
      it "accepts double indentation of #{keyword} condition" do
        inspect_source(cop, <<-END.strip_indent)
          #{keyword} receiver.
              nil? &&
              !args.empty?
          end
        END
        expect(cop.messages).to be_empty
      end

      it "registers an offense for a 2 space indentation of #{keyword} " \
         'condition' do
        inspect_source(cop, <<-END.strip_indent)
          #{keyword} receiver
            .nil? &&
            !args.empty?
          end
        END
        expect(cop.highlights).to eq(['.nil?'])
        expect(cop.messages).to eq(['Use 4 (not 2) spaces for indenting a ' \
                                    "condition in #{article} `#{keyword}` " \
                                    'statement spanning multiple lines.'])
      end

      it "accepts indented methods in #{keyword} body" do
        inspect_source(cop, <<-END.strip_indent)
          #{keyword} a
            something.
              something_else
          end
        END
        expect(cop.highlights).to be_empty
      end
    end

    %w[unless if].each do |keyword|
      it "accepts special indentation of return #{keyword} condition" do
        inspect_source(cop, <<-END.strip_indent)
          return #{keyword} receiver.nil? &&
              !args.empty? &&
              BLACKLIST.include?(method_name)
        END
        expect(cop.messages).to be_empty
      end
    end

    it 'registers an offense for wrong indentation of for expression' do
      expect_offense(<<-RUBY.strip_indent)
        for n in a.
          b
          ^ Use 4 (not 2) spaces for indenting a collection in a `for` statement spanning multiple lines.
        end
      RUBY
    end

    it 'accepts special indentation of for expression' do
      inspect_source(cop, <<-END.strip_indent)
        for n in a.
            b
        end
      END
      expect(cop.messages).to be_empty
    end

    it 'accepts indentation of assignment' do
      inspect_source(cop, <<-END.strip_indent)
        formatted_int = int_part
          .abs
          .to_s
          .reverse
          .gsub(/...(?=.)/, '\&_')
          .reverse
      END
      expect(cop.messages).to be_empty
    end

    it 'registers an offense for correct + unrecognized style' do
      inspect_source(cop, <<-END.strip_indent)
        a.
          b
        c.
            d
      END
      expect(cop.messages).to eq(['Use 2 (not 4) spaces for indenting an ' \
                                  'expression spanning multiple lines.'])
      expect(cop.highlights).to eq(%w[d])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'registers an offense for aligned operators in assignment' do
      msg = 'Use %d (not %d) spaces for indenting an expression ' \
              'in an assignment spanning multiple lines.'

      expect_offense(<<-END.strip_indent)
        formatted_int = int_part
                        .abs
                        ^^^^ #{format(msg, 2, 16)}
                        .reverse
                        ^^^^^^^^ #{format(msg, 2, 16)}
      END
    end

    it 'auto-corrects' do
      new_source = autocorrect_source(cop, <<-END.strip_indent)
        until a.
              b
          something
        end
      END
      expect(new_source).to eq(<<-END.strip_indent)
        until a.
            b
          something
        end
      END
    end

    context 'when indentation width is overridden for this cop' do
      let(:cop_indent) { 7 }

      it 'accepts indented methods' do
        expect_no_offenses(<<-END.strip_indent)
          User.a
                 .c
                 .b
        END
      end

      it 'accepts correctly indented methods in operation' do
        inspect_source(cop, <<-END.strip_margin('|'))
          |        1 + a
          |               .b
          |               .c
        END
        expect(cop.offenses).to be_empty
        expect(cop.highlights).to be_empty
      end

      it 'accepts indented methods in if condition' do
        inspect_source(cop, <<-END.strip_indent)
          if a.
                   b
            something
          end
        END
        expect(cop.messages).to be_empty
      end

      it 'accepts indentation of assignment' do
        inspect_source(cop, <<-END.strip_indent)
          formatted_int = int_part
                 .abs
                 .to_s
                 .reverse
        END
        expect(cop.messages).to be_empty
      end

      [
        %w[an if],
        %w[an unless],
        %w[a while],
        %w[an until]
      ].each do |article, keyword|
        it "accepts indentation of #{keyword} condition which is offset " \
           'by a single normal indentation step' do
          # normal code indentation is 2 spaces, and we have configured
          # multiline method indentation to 7 spaces
          # so in this case, 9 spaces are required
          inspect_source(cop, <<-END.strip_indent)
            #{keyword} receiver.
                     nil? &&
                     !args.empty?
            end
          END
          expect(cop.messages).to be_empty
        end

        it "registers an offense for a 4 space indentation of #{keyword} " \
           'condition' do
          inspect_source(cop, <<-END.strip_indent)
            #{keyword} receiver
                .nil? &&
                !args.empty?
            end
          END
          expect(cop.highlights).to eq(['.nil?'])
          expect(cop.messages).to eq(['Use 9 (not 4) spaces for indenting a ' \
                                      "condition in #{article} `#{keyword}` " \
                                      'statement spanning multiple lines.'])
        end

        it "accepts indented methods in #{keyword} body" do
          inspect_source(cop, <<-END.strip_indent)
            #{keyword} a
              something.
                     something_else
            end
          END
          expect(cop.highlights).to be_empty
        end
      end
    end
  end
end
