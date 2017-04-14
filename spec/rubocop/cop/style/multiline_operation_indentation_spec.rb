# frozen_string_literal: true

describe RuboCop::Cop::Layout::MultilineOperationIndentation do
  subject(:cop) { described_class.new(config) }
  let(:config) do
    merged = RuboCop::ConfigLoader
             .default_configuration['Layout/MultilineOperationIndentation']
             .merge(cop_config)
             .merge('IndentationWidth' => cop_indent)
    RuboCop::Config
      .new('Layout/MultilineOperationIndentation' => merged,
           'Layout/IndentationWidth' => { 'Width' => indentation_width })
  end
  let(:indentation_width) { 2 }
  let(:cop_indent) { nil } # use indentation width from Layout/IndentationWidth

  shared_examples 'common' do
    it 'accepts indented operands in ordinary statement' do
      inspect_source(cop, <<-END.strip_indent)
        a +
          b
      END
      expect(cop.messages).to be_empty
    end

    it 'accepts indented operands inside and outside a block' do
      inspect_source(cop, <<-END.strip_indent)
        a = b.map do |c|
          c +
            b +
            d do
              x +
                y
            end
        end
      END
      expect(cop.messages).to be_empty
    end

    it 'registers an offense for no indentation of second line' do
      inspect_source(cop, <<-END.strip_indent)
        a +
        b
      END
      expect(cop.messages).to eq(['Use 2 (not 0) spaces for indenting an ' \
                                  'expression spanning multiple lines.'])
      expect(cop.highlights).to eq(['b'])
    end

    it 'registers an offense for one space indentation of second line' do
      inspect_source(cop, <<-END.strip_indent)
        a +
         b
      END
      expect(cop.messages).to eq(['Use 2 (not 1) spaces for indenting an ' \
                                  'expression spanning multiple lines.'])
      expect(cop.highlights).to eq(['b'])
    end

    it 'does not check method calls' do
      inspect_source(cop, <<-END.strip_indent)
        a
         .(args)

        Foo
        .a
          .b

        Foo
        .a
          .b(c)

        expect { Foo.new }.
          to change { Bar.count }.
              from(1).to(2)
      END
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for three spaces indentation of second line' do
      inspect_source(cop, <<-END.strip_indent)
        a ||
           b
        c and
           d
      END
      expect(cop.messages).to eq(['Use 2 (not 3) spaces for indenting an ' \
                                  'expression spanning multiple lines.'] * 2)
      expect(cop.highlights).to eq(%w[b d])
    end

    it 'registers an offense for extra indentation of third line' do
      inspect_source(cop, <<-END.strip_margin('|'))
        |   a ||
        |     b ||
        |       c
      END
      expect(cop.messages).to eq(['Use 2 (not 4) spaces for indenting an ' \
                                  'expression spanning multiple lines.'])
      expect(cop.highlights).to eq(['c'])
    end

    it 'registers an offense for the emacs ruby-mode 1.1 indentation of an ' \
       'expression in an array' do
      inspect_source(cop, <<-END.strip_margin('|'))
        |  [
        |   a +
        |   b
        |  ]
      END
      expect(cop.messages).to eq(['Use 2 (not 0) spaces for indenting an ' \
                                  'expression spanning multiple lines.'])
      expect(cop.highlights).to eq(['b'])
    end

    it 'accepts indented operands in an array' do
      inspect_source(cop, <<-END.strip_margin('|'))
        |    dm[i][j] = [
        |      dm[i-1][j-1] +
        |        (this[j-1] == that[i-1] ? 0 : sub),
        |      dm[i][j-1] + ins,
        |      dm[i-1][j] + del
        |    ].min
      END
      expect(cop.offenses).to be_empty
    end

    it 'accepts two spaces indentation in assignment of local variable' do
      inspect_source(cop, <<-END.strip_indent)
        a =
          'foo' +
          'bar'
      END
      expect(cop.messages).to be_empty
    end

    it 'accepts two spaces indentation in assignment of array element' do
      inspect_source(cop, <<-END.strip_indent)
        a['test'] =
          'foo' +
          'bar'
      END
      expect(cop.messages).to be_empty
    end

    it 'accepts two spaces indentation of second line' do
      inspect_source(cop, <<-END.strip_margin('|'))
        |   a ||
        |     b
      END
      expect(cop.messages).to be_empty
    end

    it 'accepts no extra indentation of third line' do
      inspect_source(cop, <<-END.strip_margin('|'))
        |   a &&
        |     b &&
        |     c
      END
      expect(cop.messages).to be_empty
    end

    it 'accepts indented operands in for body' do
      inspect_source(cop, <<-END.strip_indent)
        for x in a
          something &&
            something_else
        end
      END
      expect(cop.highlights).to be_empty
    end

    it 'accepts alignment inside a grouped expression' do
      inspect_source(cop, <<-END.strip_indent)
        (a +
         b)
      END
      expect(cop.messages).to be_empty
    end

    it 'accepts an expression where the first operand spans multiple lines' do
      inspect_source(cop, <<-END.strip_indent)
        subject.each do |item|
          result = resolve(locale) and return result
        end and nil
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

    it 'registers an offense for an unindented multiline operation that is ' \
       'the left operand in another operation' do
      inspect_source(cop, <<-END.strip_indent)
        a +
        b < 3
      END
      expect(cop.messages).to eq(['Use 2 (not 0) spaces for indenting an ' \
                                  'expression spanning multiple lines.'])
      expect(cop.highlights).to eq(['b'])
    end
  end

  context 'when EnforcedStyle is aligned' do
    let(:cop_config) { { 'EnforcedStyle' => 'aligned' } }

    include_examples 'common'

    it 'accepts aligned operands in if condition' do
      inspect_source(cop, <<-END.strip_indent)
        if a +
           b
          something
        end
      END
      expect(cop.messages).to be_empty
    end

    it 'registers an offense for indented operands in if condition' do
      inspect_source(cop, <<-END.strip_indent)
        if a +
            b
          something
        end
      END
      expect(cop.messages).to eq(['Align the operands of a condition in an ' \
                                  '`if` statement spanning multiple lines.'])
      expect(cop.highlights).to eq(['b'])
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'indented')
    end

    it 'accepts indented code on LHS of equality operator' do
      inspect_source(cop, ['def config_to_allow_offenses',
                           '  a +',
                           '    b == c ',
                           'end'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts indented operands inside block + assignment' do
      inspect_source(cop, <<-END.strip_indent)
        a = b.map do |c|
          c +
            d
        end

        requires_interpolation = node.children.any? do |s|
          s.type == :dstr ||
            s.loc.expression.source =~ REGEXP
        end
      END
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for indented second part of string' do
      inspect_source(cop, <<-END.strip_indent)
        it "should convert " +
          "a to " +
          "b" do
        end
      END
      expect(cop.messages).to eq(['Align the operands of an expression ' \
                                  'spanning multiple lines.'] * 2)
      expect(cop.highlights).to eq(['"a to "', '"b"'])
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'indented')
    end

    it 'registers an offense for indented operand in second argument' do
      inspect_source(cop, <<-END.strip_indent)
        puts a, 1 +
          2
      END
      expect(cop.messages)
        .to eq(['Align the operands of an expression spanning multiple lines.'])
      expect(cop.highlights).to eq(['2'])
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'indented')
    end

    it 'registers an offense for misaligned string operand when the first ' \
       'operand has backslash continuation' do
      inspect_source(cop,
                     ['def f',
                      "  flash[:error] = 'Here is a string ' \\",
                      "                  'That spans' <<",
                      "    'multiple lines'",
                      'end'])
      expect(cop.messages).to eq(['Align the operands of an expression in an ' \
                                  'assignment spanning multiple lines.'])
      expect(cop.highlights).to eq(["'multiple lines'"])
    end

    it 'registers an offense for misaligned string operand when plus is used' do
      inspect_source(cop, <<-END.strip_indent)
        Error = 'Here is a string ' +
                'That spans' <<
          'multiple lines'
      END
      expect(cop.messages).to eq(['Align the operands of an expression in an ' \
                                  'assignment spanning multiple lines.'])
      expect(cop.highlights).to eq(["'multiple lines'"])
    end

    it 'registers an offense for misaligned operands in unless condition' do
      inspect_source(cop, <<-END.strip_indent)
        unless a +
          b
          something
        end
      END
      expect(cop.messages).to eq(['Align the operands of a condition in an ' \
                                  '`unless` statement spanning multiple ' \
                                  'lines.'])
      expect(cop.highlights).to eq(['b'])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    [
      %w[an if],
      %w[an unless],
      %w[a while],
      %w[an until]
    ].each do |article, keyword|
      it "registers an offense for misaligned operands in #{keyword} " \
         'condition' do
        inspect_source(cop, <<-END.strip_indent)
          #{keyword} a or
              b
            something
          end
        END
        expect(cop.messages).to eq(['Align the operands of a condition in ' \
                                    "#{article} `#{keyword}` statement " \
                                    'spanning multiple lines.'])
        expect(cop.highlights).to eq(['b'])
        expect(cop.config_to_allow_offenses)
          .to eq('EnforcedStyle' => 'indented')
      end
    end

    it 'accepts aligned operands in assignment' do
      inspect_source(cop, <<-END.strip_indent)
        a = b +
            c +
            d
      END
      expect(cop.offenses).to be_empty
    end

    it 'accepts aligned or:ed operands in assignment' do
      inspect_source(cop, <<-END.strip_indent)
        tmp_dir = ENV['TMPDIR'] || ENV['TMP'] || ENV['TEMP'] ||
                  Etc.systmpdir || '/tmp'
      END
      expect(cop.messages).to be_empty
    end

    it 'registers an offense for unaligned operands in op-assignment' do
      inspect_source(cop, <<-END.strip_indent)
        bar *= Foo +
          a +
               b(c)
      END
      expect(cop.messages).to eq(['Align the operands of an expression in an ' \
                                  'assignment spanning multiple lines.'])
      expect(cop.highlights).to eq(['a'])
    end

    it 'auto-corrects' do
      new_source = autocorrect_source(cop, <<-END.strip_indent)
        until a +
            b
          something
        end
      END
      expect(new_source).to eq(<<-END.strip_indent)
        until a +
              b
          something
        end
      END
    end
  end

  context 'when EnforcedStyle is indented' do
    let(:cop_config) { { 'EnforcedStyle' => 'indented' } }

    include_examples 'common'

    it 'accepts indented operands in if condition' do
      inspect_source(cop, <<-END.strip_indent)
        if a +
            b
          something
        end
      END
      expect(cop.messages).to be_empty
    end

    it 'registers an offense for aligned operands in if condition' do
      inspect_source(cop, <<-END.strip_indent)
        if a +
           b
          something
        end
      END
      expect(cop.messages).to eq(['Use 4 (not 3) spaces for indenting a ' \
                                  'condition in an `if` statement spanning ' \
                                  'multiple lines.'])
      expect(cop.highlights).to eq(['b'])
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'aligned')
    end

    it 'accepts the indentation of a broken string' do
      inspect_source(cop,
                     ["MSG = 'Use 2 (not %d) spaces for indenting a ' \\",
                      "      'broken line.'"])
      expect(cop.messages).to be_empty
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
        a(b +
            c +
        d)
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
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for aligned code on LHS of equality operator' do
      inspect_source(cop, ['def config_to_allow_offenses',
                           '  a +',
                           '  b == c ',
                           'end'])
      expect(cop.messages).to eq(['Use 2 (not 0) spaces for indenting an ' \
                                  'expression spanning multiple lines.'])
    end

    [
      %w[an if],
      %w[an unless],
      %w[a while],
      %w[an until]
    ].each do |article, keyword|
      it "accepts double indentation of #{keyword} condition" do
        inspect_source(cop, <<-END.strip_indent)
          #{keyword} receiver.nil? &&
              !args.empty? &&
              BLACKLIST.include?(method_name)
          end
          #{keyword} receiver.
              nil?
          end
        END
        expect(cop.messages).to be_empty
      end

      it "registers an offense for a 2 space indentation of #{keyword} " \
         'condition' do
        inspect_source(cop, <<-END.strip_indent)
          #{keyword} receiver.nil? &&
            !args.empty? &&
            BLACKLIST.include?(method_name)
          end
        END
        expect(cop.highlights).to eq(['!args.empty?',
                                      'BLACKLIST.include?(method_name)'])
        expect(cop.messages).to eq(['Use 4 (not 2) spaces for indenting a ' \
                                    "condition in #{article} `#{keyword}` " \
                                    'statement spanning multiple lines.'] * 2)
      end

      it "accepts indented operands in #{keyword} body" do
        inspect_source(cop, <<-END.strip_indent)
          #{keyword} a
            something &&
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
      inspect_source(cop, <<-END.strip_indent)
        for n in a +
          b
        end
      END
      expect(cop.messages).to eq(['Use 4 (not 2) spaces for indenting a ' \
                                  'collection in a `for` statement spanning ' \
                                  'multiple lines.'])
      expect(cop.highlights).to eq(['b'])
    end

    it 'accepts special indentation of for expression' do
      inspect_source(cop, <<-END.strip_indent)
        for n in a +
            b
        end
      END
      expect(cop.messages).to be_empty
    end

    it 'accepts indentation of assignment' do
      inspect_source(cop, <<-END.strip_indent)
        a = b +
          c +
          d
      END
      expect(cop.messages).to be_empty
    end

    it 'registers an offense for correct + unrecognized style' do
      inspect_source(cop, <<-END.strip_indent)
        a ||
          b
        c and
            d
      END
      expect(cop.messages).to eq(['Use 2 (not 4) spaces for indenting an ' \
                                  'expression spanning multiple lines.'])
      expect(cop.highlights).to eq(%w[d])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'registers an offense for aligned operators in assignment' do
      inspect_source(cop, <<-END.strip_indent)
        a = b +
            c +
            d
      END
      expect(cop.messages).to eq(['Use 2 (not 4) spaces for indenting an ' \
                                  'expression in an assignment spanning ' \
                                  'multiple lines.'] * 2)
    end

    it 'auto-corrects' do
      new_source = autocorrect_source(cop, <<-END.strip_indent)
        until a +
              b
          something
        end
      END
      expect(new_source).to eq(<<-END.strip_indent)
        until a +
            b
          something
        end
      END
    end

    context 'when indentation width is overridden for this cop' do
      let(:cop_indent) { 6 }

      it 'accepts indented operands in if condition' do
        inspect_source(cop, <<-END.strip_indent)
          if a +
                  b
            something
          end
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
          # multiline method indentation to 6 spaces
          # so in this case, 8 spaces are required
          inspect_source(cop, <<-END.strip_indent)
            #{keyword} receiver.nil? &&
                    !args.empty? &&
                    BLACKLIST.include?(method_name)
            end
            #{keyword} receiver.
                    nil?
            end
          END
          expect(cop.messages).to be_empty
        end

        it "registers an offense for a 4 space indentation of #{keyword} " \
           'condition' do
          inspect_source(cop, <<-END.strip_indent)
            #{keyword} receiver.nil? &&
                !args.empty? &&
                BLACKLIST.include?(method_name)
            end
          END
          expect(cop.highlights).to eq(['!args.empty?',
                                        'BLACKLIST.include?(method_name)'])
          expect(cop.messages).to eq(['Use 8 (not 4) spaces for indenting a ' \
                                      "condition in #{article} `#{keyword}` " \
                                      'statement spanning multiple lines.'] * 2)
        end

        it "accepts indented operands in #{keyword} body" do
          inspect_source(cop, <<-END.strip_indent)
            #{keyword} a
              something &&
                    something_else
            end
          END
          expect(cop.highlights).to be_empty
        end
      end

      it 'auto-corrects' do
        new_source = autocorrect_source(cop, <<-END.strip_indent)
          until a +
                b
            something
          end
        END
        expect(new_source).to eq(<<-END.strip_indent)
          until a +
                  b
            something
          end
        END
      end
    end
  end
end
