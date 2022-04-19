# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::MultilineMethodCallIndentation, :config do
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
      expect_no_offenses(<<~RUBY)
        a
          .b[c] = 0
      RUBY
    end

    it 'accepts indented methods inside and outside a block' do
      expect_no_offenses(<<~RUBY)
        a = b.map do |c|
          c
            .b
            .d do
              x
                .y
            end
        end
      RUBY
    end

    it 'accepts indentation relative to first receiver' do
      expect_no_offenses(<<~RUBY)
        node
          .children.map { |n| string_source(n) }.compact
          .any? { |s| preferred.any? { |d| s.include?(d) } }
      RUBY
    end

    it 'accepts indented methods in ordinary statement' do
      expect_no_offenses(<<~RUBY)
        a.
          b
      RUBY
    end

    it 'accepts no extra indentation of third line' do
      expect_no_offenses(<<~RUBY)
        a.
          b.
          c
      RUBY
    end

    it 'accepts indented methods in for body' do
      expect_no_offenses(<<~RUBY)
        for x in a
          something.
            something_else
        end
      RUBY
    end

    it 'accepts alignment inside a grouped expression' do
      expect_no_offenses(<<~RUBY)
        (a.
         b)
      RUBY
    end

    it 'accepts an expression where the first method spans multiple lines' do
      expect_no_offenses(<<~RUBY)
        subject.each do |item|
          result = resolve(locale) and return result
        end.a
      RUBY
    end

    it 'accepts any indentation of parameters to #[]' do
      expect_no_offenses(<<~RUBY)
        payment = Models::IncomingPayments[
                id:      input['incoming-payment-id'],
                   user_id: @user[:id]]
      RUBY
    end

    it "doesn't crash on unaligned multiline lambdas" do
      expect_no_offenses(<<~RUBY)
        MyClass.(my_args)
          .my_method
      RUBY
    end

    it 'accepts alignment of method with assignment and operator-like method' do
      expect_no_offenses(<<~RUBY)
        query = x.|(
          foo,
          bar
        )
      RUBY
    end
  end

  shared_examples 'common for aligned and indented' do
    it 'accepts even indentation of consecutive lines in typical RSpec code' do
      expect_no_offenses(<<~RUBY)
        expect { Foo.new }.
          to change { Bar.count }.
          from(1).to(2)
      RUBY
    end

    it 'registers an offense and corrects no indentation of second line' do
      expect_offense(<<~RUBY)
        a.
        b
        ^ Use 2 (not 0) spaces for indenting an expression spanning multiple lines.
      RUBY

      expect_correction(<<~RUBY)
        a.
          b
      RUBY
    end

    it 'registers an offense and corrects 3 spaces indentation of 2nd line' do
      expect_offense(<<~RUBY)
        a.
           b
           ^ Use 2 (not 3) spaces for indenting an expression spanning multiple lines.
        c.
           d
           ^ Use 2 (not 3) spaces for indenting an expression spanning multiple lines.
      RUBY

      expect_correction(<<~RUBY)
        a.
          b
        c.
          d
      RUBY
    end

    it 'registers an offense and corrects extra indentation of third line' do
      expect_offense(<<~RUBY)
        a.
          b.
            c
            ^ Use 2 (not 4) spaces for indenting an expression spanning multiple lines.
      RUBY

      expect_correction(<<~RUBY)
        a.
          b.
          c
      RUBY
    end

    it 'registers an offense and corrects the emacs ruby-mode 1.1 ' \
       'indentation of an expression in an array' do
      expect_offense(<<~RUBY)
        [
         a.
         b
         ^ Use 2 (not 0) spaces for indenting an expression spanning multiple lines.
        ]
      RUBY

      expect_correction(<<~RUBY)
        [
         a.
           b
        ]
      RUBY
    end

    it 'registers an offense and corrects extra indentation of 3rd line in typical RSpec code' do
      expect_offense(<<~RUBY)
        expect { Foo.new }.
          to change { Bar.count }.
              from(1).to(2)
              ^^^^ Use 2 (not 6) spaces for indenting an expression spanning multiple lines.
      RUBY

      expect_correction(<<~RUBY)
        expect { Foo.new }.
          to change { Bar.count }.
          from(1).to(2)
      RUBY
    end

    it 'registers an offense and corrects proc call without a selector' do
      expect_offense(<<~RUBY)
        a
         .(args)
         ^^ Use 2 (not 1) spaces for indenting an expression spanning multiple lines.
      RUBY

      expect_correction(<<~RUBY)
        a
          .(args)
      RUBY
    end

    it 'registers an offense and corrects one space indentation of 2nd line' do
      expect_offense(<<~RUBY)
        a
         .b
         ^^ Use 2 (not 1) spaces for indenting an expression spanning multiple lines.
      RUBY

      expect_correction(<<~RUBY)
        a
          .b
      RUBY
    end
  end

  context 'when EnforcedStyle is aligned' do
    let(:cop_config) { { 'EnforcedStyle' => 'aligned' } }

    include_examples 'common'
    include_examples 'common for aligned and indented'

    it "doesn't fail on unary operators" do
      expect_offense(<<~RUBY)
        def foo
          !0
          .nil?
          ^^^^^ Use 2 (not 0) spaces for indenting an expression spanning multiple lines.
        end
      RUBY
    end

    # We call it semantic alignment when a dot is aligned with the first dot in
    # a chain of calls, and that first dot does not begin its line.
    context 'for semantic alignment' do
      it 'accepts method being aligned with method' do
        expect_no_offenses(<<~RUBY)
          User.all.first
              .age.to_s
        RUBY
      end

      it 'accepts methods being aligned with method that is an argument' do
        expect_no_offenses(<<~RUBY)
          authorize scope.includes(:user)
                         .where(name: 'Bob')
                         .order(:name)
        RUBY
      end

      context '>= Ruby 2.7', :ruby27 do
        it 'accepts methods being aligned with method that is an argument' \
           'when using numbered parameter' do
          expect_no_offenses(<<~RUBY)
            File.read('data.yml')
                .then { YAML.safe_load _1 }
                .transform_values(&:downcase)
          RUBY
        end
      end

      it 'accepts methods being aligned with method that is an argument in assignment' do
        expect_no_offenses(<<~RUBY)
          user = authorize scope.includes(:user)
                                .where(name: 'Bob')
                                .order(:name)
        RUBY
      end

      it 'accepts method being aligned with method in assignment' do
        expect_no_offenses(<<~RUBY)
          age = User.all.first
                    .age.to_s
        RUBY
      end

      it 'accepts aligned method even when an aref is in the chain' do
        expect_no_offenses(<<~RUBY)
          foo = '123'.a
                     .b[1]
                     .c
        RUBY
      end

      it 'accepts aligned method even when an aref is first in the chain' do
        expect_no_offenses(<<~RUBY)
          foo = '123'[1].a
                        .b
                        .c
        RUBY
      end

      it "doesn't fail on a chain of aref calls" do
        expect_no_offenses('a[1][2][3]')
      end

      it 'accepts aligned method with blocks in operation assignment' do
        expect_no_offenses(<<~RUBY)
          @comment_lines ||=
            src.comments
               .select { |c| begins_its_line?(c) }
               .map { |c| c.loc.line }
        RUBY
      end

      it 'accepts key access to hash' do
        expect_no_offenses(<<~RUBY)
          hash[key] { 10 / 0 }
            .fmap { |x| x * 3 }
        RUBY
      end

      it 'accepts 3 aligned methods' do
        expect_no_offenses(<<~RUBY)
          a_class.new(severity, location, 'message', 'CopName')
                 .severity
                 .level
        RUBY
      end

      it 'registers an offense and corrects unaligned methods' do
        expect_offense(<<~RUBY)
          User.a
            .b
            ^^ Align `.b` with `.a` on line 1.
           .c
           ^^ Align `.c` with `.a` on line 1.
        RUBY

        expect_correction(<<~RUBY)
          User.a
              .b
              .c
        RUBY
      end

      it 'registers an offense and corrects unaligned method in block body' do
        expect_offense(<<~RUBY)
          a do
            b.c
              .d
              ^^ Align `.d` with `.c` on line 2.
          end
        RUBY

        expect_correction(<<~RUBY)
          a do
            b.c
             .d
          end
        RUBY
      end

      it 'accepts nested method calls' do
        expect_no_offenses(<<~RUBY)
          expect { post :action, params: params, format: :json }.to change { Foo.bar }.by(0)
                                                                .and change { Baz.quux }.by(0)
                                                                .and raise_error(StandardError)
        RUBY
      end
    end

    it 'accepts correctly aligned methods in operands' do
      expect_no_offenses(<<~RUBY)
        1 + a
            .b
            .c + d.
                 e
      RUBY
    end

    it 'accepts correctly aligned methods in assignment' do
      expect_no_offenses(<<~RUBY)
        def investigate(processed_source)
          @modifier = processed_source
                      .tokens
                      .select { |t| t.type == :k }
                      .map(&:pos)
        end
      RUBY
    end

    it 'accepts aligned methods in if + assignment' do
      expect_no_offenses(<<~RUBY)
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
      RUBY
    end

    it 'accepts indented method when there is nothing to align with' do
      expect_no_offenses(<<~RUBY)
        expect { custom_formatter_class('NonExistentClass') }
          .to raise_error(NameError)
      RUBY
    end

    it 'registers an offense and corrects one space indentation of 3rd line' do
      expect_offense(<<~RUBY)
        a
          .b
         .c
         ^^ Use 2 (not 1) spaces for indenting an expression spanning multiple lines.
      RUBY

      expect_correction(<<~RUBY)
        a
          .b
          .c
      RUBY
    end

    it 'accepts indented and aligned methods in binary operation' do
      # b is indented relative to a
      # .d is aligned with c
      expect_no_offenses(<<~RUBY)
        a.
          b + c
              .d
      RUBY
    end

    it 'accepts aligned methods in if condition' do
      expect_no_offenses(<<~RUBY)
        if a.
           b
          something
        end
      RUBY
    end

    it 'accepts aligned methods in a begin..end block' do
      expect_no_offenses(<<~RUBY)
        @dependencies ||= begin
          DEFAULT_DEPRUBYENCIES
            .reject { |e| e }
            .map { |e| e }
        end
      RUBY
    end

    it 'registers an offense and corrects misaligned methods in if condition' do
      expect_offense(<<~RUBY)
        if a.
            b
            ^ Align `b` with `a.` on line 1.
          something
        end
      RUBY

      expect_correction(<<~RUBY)
        if a.
           b
          something
        end
      RUBY
    end

    it 'does not check binary operations when string wrapped with backslash' do
      expect_no_offenses(<<~'RUBY')
        flash[:error] = 'Here is a string ' \
                        'That spans' <<
          'multiple lines'
      RUBY
    end

    it 'does not check binary operations when string wrapped with +' do
      expect_no_offenses(<<~RUBY)
        flash[:error] = 'Here is a string ' +
                        'That spans' <<
          'multiple lines'
      RUBY
    end

    it 'registers an offense and corrects misaligned method in []= call' do
      expect_offense(<<~RUBY)
        flash[:error] = here_is_a_string.
                        that_spans.
           multiple_lines
           ^^^^^^^^^^^^^^ Align `multiple_lines` with `here_is_a_string.` on line 1.
      RUBY

      expect_correction(<<~RUBY)
        flash[:error] = here_is_a_string.
                        that_spans.
                        multiple_lines
      RUBY
    end

    it 'registers an offense and corrects misaligned methods in unless condition' do
      expect_offense(<<~RUBY)
        unless a
        .b
        ^^ Align `.b` with `a` on line 1.
          something
        end
      RUBY

      expect_correction(<<~RUBY)
        unless a
               .b
          something
        end
      RUBY
    end

    it 'registers an offense and corrects misaligned methods in while condition' do
      expect_offense(<<~RUBY)
        while a.
            b
            ^ Align `b` with `a.` on line 1.
          something
        end
      RUBY

      expect_correction(<<~RUBY)
        while a.
              b
          something
        end
      RUBY
    end

    it 'registers an offense and corrects misaligned methods in until condition' do
      expect_offense(<<~RUBY)
        until a.
            b
            ^ Align `b` with `a.` on line 1.
          something
        end
      RUBY

      expect_correction(<<~RUBY)
        until a.
              b
          something
        end
      RUBY
    end

    it 'accepts aligned method in return' do
      expect_no_offenses(<<~RUBY)
        def a
          return b.
                 c
        end
      RUBY
    end

    it 'accepts aligned method in assignment + block + assignment' do
      expect_no_offenses(<<~RUBY)
        a = b do
          c.d = e.
                f
        end
      RUBY
    end

    it 'accepts aligned methods in assignment' do
      expect_no_offenses(<<~RUBY)
        formatted_int = int_part
                        .to_s
                        .reverse
                        .gsub(/...(?=.)/, '&_')
      RUBY
    end

    it 'registers an offense and corrects misaligned methods in local variable assignment' do
      expect_offense(<<~RUBY)
        a = b.c.
         d
         ^ Align `d` with `b.c.` on line 1.
      RUBY

      expect_correction(<<~RUBY)
        a = b.c.
            d
      RUBY
    end

    it 'accepts aligned methods in constant assignment' do
      expect_no_offenses(<<~RUBY)
        A = b
            .c
      RUBY
    end

    it 'accepts aligned methods in operator assignment' do
      expect_no_offenses(<<~RUBY)
        a +=
          b
          .c
      RUBY
    end

    it 'registers an offense and corrects unaligned methods in assignment' do
      expect_offense(<<~RUBY)
        bar = Foo
          .a
          ^^ Align `.a` with `Foo` on line 1.
              .b(c)
      RUBY

      expect_correction(<<~RUBY)
        bar = Foo
              .a
              .b(c)
      RUBY
    end
  end

  shared_examples 'both indented* styles' do
    # We call it semantic alignment when a dot is aligned with the first dot in
    # a chain of calls, and that first dot does not begin its line. But for the
    # indented style, it doesn't come into play.
    context 'for possible semantic alignment' do
      it 'accepts indented methods' do
        expect_no_offenses(<<~RUBY)
          User.a
            .c
            .b
        RUBY
      end
    end
  end

  context 'when EnforcedStyle is indented_relative_to_receiver' do
    let(:cop_config) { { 'EnforcedStyle' => 'indented_relative_to_receiver' } }

    include_examples 'common'
    include_examples 'both indented* styles'

    it "doesn't fail on unary operators" do
      expect_offense(<<~RUBY)
        def foo
          !0
          .nil?
          ^^^^^ Indent `.nil?` 2 spaces more than `0` on line 2.
        end
      RUBY
    end

    it 'accepts correctly indented methods in operation' do
      expect_no_offenses(<<~RUBY)
        1 + a
              .b
              .c
      RUBY
    end

    it 'accepts indentation of consecutive lines in typical RSpec code' do
      expect_no_offenses(<<~RUBY)
        expect { Foo.new }.to change { Bar.count }
                                .from(1).to(2)
      RUBY
    end

    it 'registers an offense and corrects no indentation of second line' do
      expect_offense(<<~RUBY)
        a.
        b
        ^ Indent `b` 2 spaces more than `a` on line 1.
      RUBY

      expect_correction(<<~RUBY)
        a.
          b
      RUBY
    end

    it 'registers an offense and corrects extra indentation of 3rd line in typical RSpec code' do
      expect_offense(<<~RUBY)
        expect { Foo.new }.
          to change { Bar.count }.
              from(1).to(2)
              ^^^^ Indent `from` 2 spaces more than `change { Bar.count }` on line 2.
      RUBY

      expect_correction(<<~RUBY)
        expect { Foo.new }.
          to change { Bar.count }.
               from(1).to(2)
      RUBY
    end

    it 'registers an offense and corrects proc call without a selector' do
      expect_offense(<<~RUBY)
        a
         .(args)
         ^^ Indent `.(` 2 spaces more than `a` on line 1.
      RUBY

      expect_correction(<<~RUBY)
        a
          .(args)
      RUBY
    end

    it 'does not register an offense when multiline method chain has expected indent width and ' \
       'the method is preceded by splat' do
      expect_no_offenses(<<~RUBY)
        [
          *foo
            .bar(
              arg)
        ]
      RUBY
    end

    it 'does not register an offense when multiline method chain has expected indent width and ' \
       'the method is preceded by double splat' do
      expect_no_offenses(<<~RUBY)
        [
          **foo
            .bar(
              arg)
        ]
      RUBY
    end

    it 'registers an offense and corrects one space indentation of 2nd line' do
      expect_offense(<<~RUBY)
        a
         .b
         ^^ Indent `.b` 2 spaces more than `a` on line 1.
      RUBY

      expect_correction(<<~RUBY)
        a
          .b
      RUBY
    end

    it 'registers an offense and corrects 3 spaces indentation of second line' do
      expect_offense(<<~RUBY)
        a.
           b
           ^ Indent `b` 2 spaces more than `a` on line 1.
        c.
           d
           ^ Indent `d` 2 spaces more than `c` on line 3.
      RUBY

      expect_correction(<<~RUBY)
        a.
          b
        c.
          d
      RUBY
    end

    it 'registers an offense and corrects extra indentation of 3rd line' do
      expect_offense(<<~RUBY)
        a.
          b.
            c
            ^ Indent `c` 2 spaces more than `a` on line 1.
      RUBY

      expect_correction(<<~RUBY)
        a.
          b.
          c
      RUBY
    end

    it 'registers an offense and corrects the emacs ruby-mode 1.1 ' \
       'indentation of an expression in an array' do
      expect_offense(<<~RUBY)
        [
         a.
         b
         ^ Indent `b` 2 spaces more than `a` on line 2.
        ]
      RUBY

      expect_correction(<<~RUBY)
        [
         a.
           b
        ]
      RUBY
    end
  end

  context 'when EnforcedStyle is indented' do
    let(:cop_config) { { 'EnforcedStyle' => 'indented' } }

    include_examples 'common'
    include_examples 'common for aligned and indented'
    include_examples 'both indented* styles'

    it "doesn't fail on unary operators" do
      expect_offense(<<~RUBY)
        def foo
          !0
          .nil?
          ^^^^^ Use 2 (not 0) spaces for indenting an expression spanning multiple lines.
        end
      RUBY
    end

    it 'accepts correctly indented methods in operation' do
      expect_no_offenses(<<~RUBY)
        1 + a
          .b
          .c
      RUBY
    end

    it 'registers an offense and corrects 1 space indentation of 3rd line' do
      expect_offense(<<~RUBY)
        a
          .b
         .c
         ^^ Use 2 (not 1) spaces for indenting an expression spanning multiple lines.
      RUBY

      expect_correction(<<~RUBY)
        a
          .b
          .c
      RUBY
    end

    it 'accepts indented methods in if condition' do
      expect_no_offenses(<<~RUBY)
        if a.
            b
          something
        end
      RUBY
    end

    it 'registers an offense and corrects 0 space indentation inside square brackets' do
      expect_offense(<<~RUBY)
        foo[
          bar
          .baz
          ^^^^ Use 2 (not 0) spaces for indenting an expression spanning multiple lines.
        ]
      RUBY

      expect_correction(<<~RUBY)
        foo[
          bar
            .baz
        ]
      RUBY
    end

    it 'registers an offense and corrects aligned methods in if condition' do
      expect_offense(<<~RUBY)
        if a.
           b
           ^ Use 4 (not 3) spaces for indenting a condition in an `if` statement spanning multiple lines.
          something
        end
      RUBY

      expect_correction(<<~RUBY)
        if a.
            b
          something
        end
      RUBY
    end

    it 'accepts normal indentation of method parameters' do
      expect_no_offenses(<<~RUBY)
        Parser::Source::Range.new(expr.source_buffer,
                                  begin_pos,
                                  begin_pos + line.length)
      RUBY
    end

    it 'accepts any indentation of method parameters' do
      expect_no_offenses(<<~RUBY)
        a(b.
            c
        .d)
      RUBY
    end

    it 'accepts normal indentation inside grouped expression' do
      expect_no_offenses(<<~RUBY)
        arg_array.size == a.size && (
          arg_array == a ||
          arg_array.map(&:children) == a.map(&:children)
        )
      RUBY
    end

    [
      %w[an if],
      %w[an unless],
      %w[a while],
      %w[an until]
    ].each do |article, keyword|
      it "accepts double indentation of #{keyword} condition" do
        expect_no_offenses(<<~RUBY)
          #{keyword} receiver.
              nil? &&
              !args.empty?
          end
        RUBY
      end

      it "registers an offense for a 2 space indentation of #{keyword} condition" do
        expect_offense(<<~RUBY)
          #{keyword} receiver
            .nil? &&
            ^^^^^ Use 4 (not 2) spaces for indenting a condition in #{article} `#{keyword}` statement spanning multiple lines.
            !args.empty?
          end
        RUBY
      end

      it "accepts indented methods in #{keyword} body" do
        expect_no_offenses(<<~RUBY)
          #{keyword} a
            something.
              something_else
          end
        RUBY
      end
    end

    %w[unless if].each do |keyword|
      it "accepts special indentation of return #{keyword} condition" do
        expect_no_offenses(<<~RUBY)
          return #{keyword} receiver.nil? &&
              !args.empty? &&
              FORBIDDEN_METHODS.include?(method_name)
        RUBY
      end
    end

    it 'registers an offense and corrects wrong indentation of for expression' do
      expect_offense(<<~RUBY)
        for n in a.
          b
          ^ Use 4 (not 2) spaces for indenting a collection in a `for` statement spanning multiple lines.
        end
      RUBY

      expect_correction(<<~RUBY)
        for n in a.
            b
        end
      RUBY
    end

    it 'accepts special indentation of for expression' do
      expect_no_offenses(<<~RUBY)
        for n in a.
            b
        end
      RUBY
    end

    shared_examples 'assignment' do |lhs|
      it "accepts indentation of assignment to #{lhs} with rhs on same line" do
        expect_no_offenses(<<~RUBY)
          #{lhs} = int_part
            .abs
            .to_s
            .reverse
            .gsub(/...(?=.)/, '&_')
            .reverse
        RUBY
      end

      it "accepts indentation of assignment to #{lhs} with newline after =" do
        expect_no_offenses(<<~RUBY)
          #{lhs} =
            int_part
              .abs
              .to_s
        RUBY
      end

      it "accepts indentation of assignment to obj.#{lhs} with newline after =" do
        expect_no_offenses(<<~RUBY)
          obj.#{lhs} =
            int_part
              .abs
              .to_s
        RUBY
      end
    end

    include_examples 'assignment', 'a'
    include_examples 'assignment', 'a[:key]'

    it 'registers an offense and corrects correct + unrecognized style' do
      expect_offense(<<~RUBY)
        a.
          b
        c.
            d
            ^ Use 2 (not 4) spaces for indenting an expression spanning multiple lines.
      RUBY

      expect_correction(<<~RUBY)
        a.
          b
        c.
          d
      RUBY
    end

    it 'registers an offense and corrects aligned operators in assignment' do
      expect_offense(<<~RUBY)
        formatted_int = int_part
                        .abs
                        ^^^^ Use 2 (not 16) spaces for indenting an expression in an assignment spanning multiple lines.
                        .reverse
                        ^^^^^^^^ Use 2 (not 16) spaces for indenting an expression in an assignment spanning multiple lines.
      RUBY

      expect_correction(<<~RUBY)
        formatted_int = int_part
          .abs
          .reverse
      RUBY
    end

    context 'when indentation width is overridden for this cop' do
      let(:cop_indent) { 7 }

      it 'accepts indented methods' do
        expect_no_offenses(<<~RUBY)
          User.a
                 .c
                 .b
        RUBY
      end

      it 'accepts correctly indented methods in operation' do
        expect_no_offenses(<<~RUBY)
          1 + a
                 .b
                 .c
        RUBY
      end

      it 'accepts indented methods in if condition' do
        expect_no_offenses(<<~RUBY)
          if a.
                   b
            something
          end
        RUBY
      end

      it 'accepts indentation of assignment' do
        expect_no_offenses(<<~RUBY)
          formatted_int = int_part
                 .abs
                 .to_s
                 .reverse
        RUBY
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
          expect_no_offenses(<<~RUBY)
            #{keyword} receiver.
                     nil? &&
                     !args.empty?
            end
          RUBY
        end

        it "registers an offense for a 4 space indentation of #{keyword} condition" do
          expect_offense(<<~RUBY)
            #{keyword} receiver
                .nil? &&
                ^^^^^ Use 9 (not 4) spaces for indenting a condition in #{article} `#{keyword}` statement spanning multiple lines.
                !args.empty?
            end
          RUBY
        end

        it "accepts indented methods in #{keyword} body" do
          expect_no_offenses(<<~RUBY)
            #{keyword} a
              something.
                     something_else
            end
          RUBY
        end
      end
    end
  end
end
