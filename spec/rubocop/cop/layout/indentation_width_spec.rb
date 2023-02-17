# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::IndentationWidth, :config do
  let(:config) do
    RuboCop::Config.new(
      'Layout/IndentationWidth' => cop_config,
      'Layout/AccessModifierIndentation' => access_modifier_config,
      'Layout/IndentationConsistency' => consistency_config,
      'Layout/EndAlignment' => end_alignment_config,
      'Layout/DefEndAlignment' => def_end_alignment_config
    )
  end
  let(:access_modifier_config) { { 'EnforcedStyle' => 'indent' } }
  let(:consistency_config) { { 'EnforcedStyle' => 'normal' } }
  let(:end_alignment_config) { { 'Enabled' => true, 'EnforcedStyleAlignWith' => 'variable' } }
  let(:def_end_alignment_config) do
    { 'Enabled' => true, 'EnforcedStyleAlignWith' => 'start_of_line' }
  end

  context 'with Width set to 4' do
    let(:cop_config) { { 'Width' => 4 } }

    context 'for a file with byte order mark' do
      let(:bom) { "\xef\xbb\xbf" }

      it 'accepts correctly indented method definition' do
        expect_no_offenses(<<~RUBY)
          #{bom}class Test
              def method
              end
          end
        RUBY
      end
    end

    context 'with ignored patterns set' do
      let(:cop_config) do
        {
          'Width' => 4,
          'AllowedPatterns' => ['^\s*module', '^\s*(els)?if.*[A-Z][a-z]+']
        }
      end

      it 'accepts unindented lines for those keywords' do
        expect_no_offenses(<<~RUBY)
          module Foo
          class Test
              if blah
                  if blah == Apple
          puts "sweet"
                  elsif blah == Lemon
          puts "sour"
                  elsif blah == popcorn
                      puts "salty"
                  end
              end
          end
          end
        RUBY
      end
    end

    context 'with if statement' do
      it 'registers an offense for bad indentation of an if body' do
        expect_offense(<<~RUBY)
          if cond
           func
          ^ Use 4 (not 1) spaces for indentation.
          end
        RUBY
      end
    end

    it 'registers and corrects offense for bad indentation' do
      expect_offense(<<~RUBY)
        if a1
           b1
        ^^^ Use 4 (not 3) spaces for indentation.
           b1
        elsif a2
         b2
        ^ Use 4 (not 1) spaces for indentation.
        else
            c
        end
      RUBY

      # The second `b1` will be corrected by IndentationConsistency.
      expect_correction(<<~RUBY)
        if a1
            b1
           b1
        elsif a2
            b2
        else
            c
        end
      RUBY
    end
  end

  context 'with Width set to 2' do
    let(:cop_config) { { 'Width' => 2 } }

    context 'with if statement' do
      it 'registers an offense for bad indentation of an if body' do
        expect_offense(<<~RUBY)
          if cond
           func
          ^ Use 2 (not 1) spaces for indentation.
          end
        RUBY
      end

      it 'registers an offense for bad indentation of an else body' do
        expect_offense(<<~RUBY)
          if cond
            func1
          else
           func2
          ^ Use 2 (not 1) spaces for indentation.
          end
        RUBY
      end

      it 'registers an offense for bad indentation of an else body when if body contains no code' do
        expect_offense(<<~RUBY)
          if cond
            # nothing here
          else
           func2
          ^ Use 2 (not 1) spaces for indentation.
          end
        RUBY
      end

      it 'registers an offense for bad indentation of an else body when if ' \
         'and elsif body contains no code' do
        expect_offense(<<~RUBY)
          if cond
            # nothing here
          elsif cond2
            # nothing here either
          else
           func2
          ^ Use 2 (not 1) spaces for indentation.
          end
        RUBY
      end

      it 'registers an offense for bad indentation of an elsif body' do
        expect_offense(<<~RUBY)
          if a1
            b1
          elsif a2
           b2
          ^ Use 2 (not 1) spaces for indentation.
          else
            c
          end
        RUBY
      end

      it 'registers offense for bad indentation of ternary inside else' do
        expect_offense(<<~RUBY)
          if a
            b
          else
               x ? y : z
          ^^^^^ Use 2 (not 5) spaces for indentation.
          end
        RUBY
      end

      it 'registers offense for bad indentation of modifier if in else' do
        expect_offense(<<~RUBY)
          if a
            b
          else
             x if y
          ^^^ Use 2 (not 3) spaces for indentation.
          end
        RUBY
      end

      it 'accepts indentation after if on new line after assignment' do
        expect_no_offenses(<<~RUBY)
          Rails.application.config.ideal_postcodes_key =
            if Rails.env.production? || Rails.env.staging?
              "AAAA-AAAA-AAAA-AAAA"
            end
        RUBY
      end

      it 'accepts `rescue` after an empty body' do
        expect_no_offenses(<<~RUBY)
          begin
          rescue
            handle_error
          end
        RUBY
      end

      it 'accepts `ensure` after an empty body' do
        expect_no_offenses(<<~RUBY)
          begin
          ensure
            something
          end
        RUBY
      end

      it 'accepts `rescue`/`ensure` after an empty body' do
        expect_no_offenses(<<~RUBY)
          begin
          rescue
            handle_error
          ensure
            something
          end
        RUBY
      end

      it 'accepts `rescue` after an empty def' do
        expect_no_offenses(<<~RUBY)
          def foo
          rescue
            handle_error
          end
        RUBY
      end

      it 'accepts `ensure` after an empty def' do
        expect_no_offenses(<<~RUBY)
          def foo
          ensure
            something
          end
        RUBY
      end

      it 'accepts `rescue`/`ensure` after an empty def' do
        expect_no_offenses(<<~RUBY)
          def foo
          rescue
            handle_error
          ensure
            something
          end
        RUBY
      end

      it 'does not raise any error with empty braces' do
        expect_no_offenses(<<~RUBY)
          if cond
            ()
          else
            ()
          end
        RUBY
      end

      it 'registers and corrects on offense for bad indentation' do
        expect_offense(<<~RUBY)
          if a1
             b1
          ^^^ Use 2 (not 3) spaces for indentation.
             b1
          elsif a2
           b2
          ^ Use 2 (not 1) spaces for indentation.
          else
              c
          ^^^^ Use 2 (not 4) spaces for indentation.
          end
        RUBY

        # The second `b1` will be corrected by IndentationConsistency.
        expect_correction(<<~RUBY)
          if a1
            b1
             b1
          elsif a2
            b2
          else
            c
          end
        RUBY
      end

      it 'does not correct in scopes that contain block comments' do
        expect_offense(<<~RUBY)
          module Foo
          # The class has a block comment within, so it's not corrected.
          class Bar
          ^{} Use 2 (not 0) spaces for indentation.
          =begin
          This is a nice long
          comment
          which spans a few lines
          =end
          # The method has no block comment inside,
          # but it's within a class that has a block
          # comment, so it's not corrected either.
          def baz
          ^{} Use 2 (not 0) spaces for indentation.
          do_something
          ^{} Use 2 (not 0) spaces for indentation.
          end
          end
          end
        RUBY

        expect_no_corrections
      end

      it 'does not indent heredoc strings' do
        expect_offense(<<~'RUBY')
          module Foo
          module Bar
          ^{} Use 2 (not 0) spaces for indentation.
            SOMETHING = <<GOO
          text
          more text
          foo
          GOO
            def baz
              do_something("#{x}")
            end
          end
          end
        RUBY

        expect_correction(<<~'RUBY')
          module Foo
            module Bar
              SOMETHING = <<GOO
          text
          more text
          foo
          GOO
              def baz
                do_something("#{x}")
              end
            end
          end
        RUBY
      end

      it 'indents parenthesized expressions' do
        expect_offense(<<~RUBY)
          var1 = nil
          array_list = []
          if var1.attr1 != 0 || array_list.select{ |w|
                                  (w.attr2 == var1.attr2)
                           ^^^^^^^ Use 2 (not 7) spaces for indentation.
                           }.blank?
            array_list << var1
          end
        RUBY

        expect_correction(<<~RUBY)
          var1 = nil
          array_list = []
          if var1.attr1 != 0 || array_list.select{ |w|
                             (w.attr2 == var1.attr2)
                           }.blank?
            array_list << var1
          end
        RUBY
      end

      it 'leaves rescue ; end unchanged' do
        expect_no_offenses(<<~RUBY)
          if variable
            begin
              do_something
            rescue ; end # consume any exception
          end
        RUBY
      end

      it 'leaves block unchanged if block end is not on its own line' do
        expect_no_offenses(<<~RUBY)
          a_function {
            # a comment
            result = AObject.find_by_attr(attr) if attr
            result || AObject.make(
                :attr => attr,
                :attr2 => Other.get_value(),
                :attr3 => Another.get_value()) }
        RUBY
      end

      it 'handles lines with only whitespace' do
        expect_offense(<<~RUBY)
          def x
              y
          ^^^^ Use 2 (not 4) spaces for indentation.

          rescue
          end
        RUBY

        expect_correction(<<~RUBY)
          def x
            y

          rescue
          end
        RUBY
      end

      it 'accepts a one line if statement' do
        expect_no_offenses('if cond then func1 else func2 end')
      end

      it 'accepts a correctly aligned if/elsif/else/end' do
        expect_no_offenses(<<~RUBY)
          if a1
            b1
          elsif a2
            b2
          else
            c
          end
        RUBY
      end

      it 'accepts a correctly aligned if/elsif/else/end as a method argument' do
        expect_no_offenses(<<~RUBY)
          foo(
            if a1
              b1
            elsif a2
              b2
            else
              c
            end
          )
        RUBY
      end

      it 'accepts if/elsif/else/end laid out as a table' do
        expect_no_offenses(<<~RUBY)
          if    @io == $stdout then str << "$stdout"
          elsif @io == $stdin  then str << "$stdin"
          elsif @io == $stderr then str << "$stderr"
          else                      str << @io.class.to_s
          end
        RUBY
      end

      it 'accepts if/then/else/end laid out as another table' do
        expect_no_offenses(<<~RUBY)
          if File.exist?('config.save')
          then ConfigTable.load
          else ConfigTable.new
          end
        RUBY
      end

      it 'accepts an empty if' do
        expect_no_offenses(<<~RUBY)
          if a
          else
          end
        RUBY
      end

      context 'with assignment' do
        shared_examples 'assignment with if statement' do
          context 'and end is aligned with variable' do
            it 'accepts an if with end aligned with setter' do
              expect_no_offenses(<<~RUBY)
                foo.bar = if baz
                  derp
                end
              RUBY
            end

            it 'accepts an if with end aligned with element assignment' do
              expect_no_offenses(<<~RUBY)
                foo[bar] = if baz
                  derp
                end
              RUBY
            end

            it 'accepts an if with end aligned with variable' do
              expect_no_offenses(<<~RUBY)
                var = if a
                  0
                end
                @var = if a
                  0
                end
                $var = if a
                  0
                end
                var ||= if a
                  0
                end
                var &&= if a
                  0
                end
                var -= if a
                  0
                end
                VAR = if a
                  0
                end
              RUBY
            end

            it 'accepts an if/else' do
              expect_no_offenses(<<~RUBY)
                var = if a
                  0
                else
                  1
                end
              RUBY
            end

            it 'accepts an if/else with chaining after the end' do
              expect_no_offenses(<<~RUBY)
                var = if a
                  0
                else
                  1
                end.abc.join("")
              RUBY
            end

            it 'accepts an if/else with chaining with a block after the end' do
              expect_no_offenses(<<~RUBY)
                var = if a
                  0
                else
                  1
                end.abc.tap {}
              RUBY
            end
          end

          context 'and end is aligned with keyword' do
            it 'registers an offense for an if with setter' do
              expect_offense(<<~RUBY)
                foo.bar = if baz
                            derp
                ^^^^^^^^^^^^ Use 2 (not 12) spaces for indentation.
                          end
              RUBY
            end

            it 'registers an offense for an if with element assignment' do
              expect_offense(<<~RUBY)
                foo[bar] = if baz
                             derp
                ^^^^^^^^^^^^^ Use 2 (not 13) spaces for indentation.
                           end
              RUBY
            end

            it 'registers an offense for an if' do
              expect_offense(<<~RUBY)
                var = if a
                        0
                ^^^^^^^^ Use 2 (not 8) spaces for indentation.
                      end
              RUBY
            end

            it 'accepts an if/else in assignment on next line' do
              expect_no_offenses(<<~RUBY)
                var =
                  if a
                    0
                  else
                    1
                  end
              RUBY
            end

            it 'registers an offense for a while' do
              expect_offense(<<~RUBY)
                var = while a
                        b
                ^^^^^^^^ Use 2 (not 8) spaces for indentation.
                      end
              RUBY
            end

            it 'registers an offense for an until' do
              expect_offense(<<~RUBY)
                var = until a
                        b
                ^^^^^^^^ Use 2 (not 8) spaces for indentation.
                      end
              RUBY
            end
          end

          context 'and end is aligned randomly' do
            it 'registers an offense for an if' do
              expect_offense(<<~RUBY)
                var = if a
                          0
                ^^^^^^^^^^ Use 2 (not 10) spaces for indentation.
                      end
              RUBY
            end

            it 'registers an offense for a while' do
              expect_offense(<<~RUBY)
                var = while a
                          b
                ^^^^^^^^^^ Use 2 (not 10) spaces for indentation.
                      end
              RUBY
            end

            it 'registers an offense for an until' do
              expect_offense(<<~RUBY)
                var = until a
                          b
                ^^^^^^^^^^ Use 2 (not 10) spaces for indentation.
                      end
              RUBY
            end
          end
        end

        context 'when alignment style is variable' do
          let(:end_alignment_config) do
            { 'Enabled' => true, 'EnforcedStyleAlignWith' => 'variable' }
          end

          include_examples 'assignment with if statement'
        end

        context 'when alignment style is start_of_line' do
          let(:end_alignment_config) do
            { 'Enabled' => true, 'EnforcedStyleAlignWith' => 'start_of_line' }
          end

          include_examples 'assignment with if statement'
        end

        context 'when alignment style is keyword' do
          let(:end_alignment_config) do
            { 'Enabled' => true, 'EnforcedStyleAlignWith' => 'keyword' }
          end

          context 'and end is aligned with variable' do
            it 'registers an offense for an if' do
              expect_offense(<<~RUBY)
                var = if a
                  0
                  ^ Use 2 (not -4) spaces for indentation.
                end
              RUBY
            end

            it 'registers an offense for a while' do
              expect_offense(<<~RUBY)
                var = while a
                  b
                  ^ Use 2 (not -4) spaces for indentation.
                end
              RUBY
            end

            it 'registers and corrects bad indentation' do
              expect_offense(<<~RUBY)
                var = if a
                  b
                  ^ Use 2 (not -4) spaces for indentation.
                end

                var = while a
                  b
                  ^ Use 2 (not -4) spaces for indentation.
                end
              RUBY
              # Not this cop's job to fix the `end`.
              expect_correction(<<~RUBY)
                var = if a
                        b
                end

                var = while a
                        b
                end
              RUBY
            end
          end

          context 'and end is aligned with keyword' do
            it 'accepts an if in assignment' do
              expect_no_offenses(<<~RUBY)
                var = if a
                        0
                      end
              RUBY
            end

            it 'accepts an if/else in assignment' do
              expect_no_offenses(<<~RUBY)
                var = if a
                        0
                      else
                        1
                      end
              RUBY
            end

            it 'accepts an if/else in assignment on next line' do
              expect_no_offenses(<<~RUBY)
                var =
                  if a
                    0
                  else
                    1
                  end
              RUBY
            end

            it 'accepts a while in assignment' do
              expect_no_offenses(<<~RUBY)
                var = while a
                        b
                      end
              RUBY
            end

            it 'accepts an until in assignment' do
              expect_no_offenses(<<~RUBY)
                var = until a
                        b
                      end
              RUBY
            end
          end
        end
      end

      it 'accepts an if/else branches with rescue clauses' do
        # Because of how the rescue clauses come out of Parser, these are
        # special and need to be tested.
        expect_no_offenses(<<~RUBY)
          if a
            a rescue nil
          else
            a rescue nil
          end
        RUBY
      end
    end

    context 'with unless' do
      it 'registers an offense for bad indentation of an unless body' do
        expect_offense(<<~RUBY)
          unless cond
           func
          ^ Use 2 (not 1) spaces for indentation.
          end
        RUBY
      end

      it 'accepts an empty unless' do
        expect_no_offenses(<<~RUBY)
          unless a
          else
          end
        RUBY
      end
    end

    context 'with case' do
      it 'registers an offense for bad indentation in a case/when body' do
        expect_offense(<<~RUBY)
          case a
          when b
           c
          ^ Use 2 (not 1) spaces for indentation.
          end
        RUBY
      end

      it 'registers an offense for bad indentation in a case/else body' do
        expect_offense(<<~RUBY)
          case a
          when b
            c
          when d
            e
          else
             f
          ^^^ Use 2 (not 3) spaces for indentation.
          end
        RUBY
      end

      it 'accepts correctly indented case/when/else' do
        expect_no_offenses(<<~RUBY)
          case a
          when b
            c
            c
          when d
          else
            f
          end
        RUBY
      end

      it 'accepts aligned values in when clause' do
        expect_no_offenses(<<~'RUBY')
          case superclass
          when /\A(#{NAMESPACEMATCH})(?:\s|\Z)/,
               /\A(Struct|OStruct)\.new/,
               /\ADelegateClass\((.+?)\)\s*\Z/,
               /\A(#{NAMESPACEMATCH})\(/
            $1
          when "self"
            namespace.path
          end
        RUBY
      end

      it 'accepts case/when/else laid out as a table' do
        expect_no_offenses(<<~RUBY)
          case sexp.loc.keyword.source
          when 'if'     then cond, body, _else = *sexp
          when 'unless' then cond, _else, body = *sexp
          else               cond, body = *sexp
          end
        RUBY
      end

      it 'accepts case/when/else with then beginning a line' do
        expect_no_offenses(<<~RUBY)
          case sexp.loc.keyword.source
          when 'if'
          then cond, body, _else = *sexp
          end
        RUBY
      end

      it 'accepts indented when/else plus indented body' do
        # "Indent when as deep as case" is the job of another cop.
        expect_no_offenses(<<~RUBY)
          case code_type
            when 'ruby', 'sql', 'plain'
              code_type
            when 'erb'
              'ruby; html-script: true'
            when "html"
              'xml'
            else
              'plain'
          end
        RUBY
      end
    end

    context 'with case match', :ruby27 do
      it 'registers an offense for bad indentation in a case/in body' do
        expect_offense(<<~RUBY)
          case a
          in b
           c
          ^ Use 2 (not 1) spaces for indentation.
          end
        RUBY
      end

      it 'registers an offense for bad indentation in a case/else body' do
        expect_offense(<<~RUBY)
          case a
          in b
            c
          in d
            e
          else
             f
          ^^^ Use 2 (not 3) spaces for indentation.
          end
        RUBY
      end

      it 'accepts correctly indented case/in/else' do
        expect_no_offenses(<<~RUBY)
          case a
          in b
            c
            c
          in d
          else
            f
          end
        RUBY
      end

      it 'accepts aligned values in `in` clause' do
        expect_no_offenses(<<~RUBY)
          case condition
          in [42]
            foo
          in [43]
            bar
          end
        RUBY
      end

      it 'accepts aligned value in `in` clause and `else` is empty' do
        expect_no_offenses(<<~RUBY)
          case x
          in 42
            foo
          else
          end
        RUBY
      end

      it 'accepts case/in/else laid out as a table' do
        expect_no_offenses(<<~RUBY)
          case sexp.loc.keyword.source
          in 'if'     then cond, body, _else = *sexp
          in 'unless' then cond, _else, body = *sexp
          else             cond, body = *sexp
          end
        RUBY
      end

      it 'accepts case/in/else with then beginning a line' do
        expect_no_offenses(<<~RUBY)
          case sexp.loc.keyword.source
          in 'if'
          then cond, body, _else = *sexp
          end
        RUBY
      end

      it 'accepts indented in/else plus indented body' do
        # "Indent `in` as deep as `case`" is the job of another cop.
        expect_no_offenses(<<~RUBY)
          case code_type
            in 'ruby' | 'sql' | 'plain'
              code_type
            in 'erb'
              'ruby; html-script: true'
            in "html"
              'xml'
            else
              'plain'
          end
        RUBY
      end
    end

    context 'with while/until' do
      it 'registers an offense for bad indentation of a while body' do
        expect_offense(<<~RUBY)
          while cond
           func
          ^ Use 2 (not 1) spaces for indentation.
          end
        RUBY
      end

      it 'registers an offense for bad indentation of begin/end/while' do
        expect_offense(<<~RUBY)
          something = begin
           func1
          ^ Use 2 (not 1) spaces for indentation.
             func2
          end while cond
        RUBY
      end

      it 'registers an offense for bad indentation of an until body' do
        expect_offense(<<~RUBY)
          until cond
           func
          ^ Use 2 (not 1) spaces for indentation.
          end
        RUBY
      end

      it 'accepts an empty while' do
        expect_no_offenses(<<~RUBY)
          while a
          end
        RUBY
      end
    end

    context 'with for' do
      it 'registers an offense for bad indentation of a for body' do
        expect_offense(<<~RUBY)
          for var in 1..10
           func
          ^ Use 2 (not 1) spaces for indentation.
          end
        RUBY
      end

      it 'accepts an empty for' do
        expect_no_offenses(<<~RUBY)
          for var in 1..10
          end
        RUBY
      end
    end

    context 'with def/defs' do
      shared_examples 'without modifier on the same line' do
        it 'registers an offense for bad indentation of a def body' do
          expect_offense(<<~RUBY)
            def test
                func1
            ^^^^ Use 2 (not 4) spaces for indentation.
                 func2 # No offense registered for this.
            end
          RUBY
        end

        it 'registers an offense for bad indentation of a defs body' do
          expect_offense(<<~RUBY)
            def self.test
               func
            ^^^ Use 2 (not 3) spaces for indentation.
            end
          RUBY
        end

        it 'accepts an empty def body' do
          expect_no_offenses(<<~RUBY)
            def test
            end
          RUBY
        end

        it 'accepts an empty defs body' do
          expect_no_offenses(<<~RUBY)
            def self.test
            end
          RUBY
        end

        it 'with an assignment' do
          expect_no_offenses(<<~RUBY)
            something = def self.foo
            end
          RUBY
        end
      end

      context 'when end is aligned with start of line' do
        let(:def_end_alignment_config) do
          { 'Enabled' => true, 'EnforcedStyleAlignWith' => 'start_of_line' }
        end

        include_examples 'without modifier on the same line'

        context 'when modifier and def are on the same line' do
          it 'accepts a correctly aligned body' do
            expect_no_offenses(<<~RUBY)
              foo def test
                something
              end
            RUBY
          end

          it 'registers an offense for bad indentation of a def body' do
            expect_offense(<<~RUBY)
              foo def test
                    something
              ^^^^^^ Use 2 (not 6) spaces for indentation.
                  end
            RUBY
          end

          it 'registers an offense for bad indentation of a defs body' do
            expect_offense(<<~RUBY)
              foo def self.test
                    something
              ^^^^^^ Use 2 (not 6) spaces for indentation.
                  end
            RUBY
          end
        end

        context 'when multiple modifiers and def are on the same line' do
          it 'accepts a correctly aligned body' do
            expect_no_offenses(<<~RUBY)
              public foo def test
                something
              end
            RUBY
          end

          it 'registers an offense for bad indentation of a def body' do
            expect_offense(<<~RUBY)
              public foo def test
                    something
              ^^^^^^ Use 2 (not 6) spaces for indentation.
              end
            RUBY
          end

          it 'registers an offense for bad indentation of a defs body' do
            expect_offense(<<~RUBY)
              public foo def self.test
                    something
              ^^^^^^ Use 2 (not 6) spaces for indentation.
              end
            RUBY
          end

          context 'when multiple modifiers are used in a block and' \
                  'a method call is made at end of the block' do
            it 'accepts a correctly aligned body' do
              expect_no_offenses(<<~RUBY)
                obj = Class.new do
                  private def private_property
                    "That would be great."
                  end
                end.new
              RUBY
            end

            it 'registers an offense for bad indentation of a def' do
              expect_offense(<<~RUBY)
                obj = Class.new do
                    private def private_property
                ^^^^ Use 2 (not 4) spaces for indentation.
                    end
                end.new
              RUBY
            end

            it 'registers an offense for bad indentation of a def body' do
              expect_offense(<<~RUBY)
                obj = Class.new do
                  private def private_property
                      "That would be great."
                  ^^^^ Use 2 (not 4) spaces for indentation.
                  end
                end.new
              RUBY
            end
          end
        end
      end

      context 'when end is aligned with def' do
        let(:def_end_alignment_config) do
          { 'Enabled' => true, 'EnforcedStyleAlignWith' => 'def' }
        end

        include_examples 'without modifier on the same line'

        context 'when modifier and def are on the same line' do
          it 'accepts a correctly aligned body' do
            expect_no_offenses(<<~RUBY)
              foo def test
                    something
              end
            RUBY
          end

          it 'registers an offense for bad indentation of a def body' do
            expect_offense(<<~RUBY)
              foo def test
                something
                ^^ Use 2 (not -2) spaces for indentation.
                  end
            RUBY
          end

          it 'registers an offense for bad indentation of a defs body' do
            expect_offense(<<~RUBY)
              foo def self.test
                something
                ^^ Use 2 (not -2) spaces for indentation.
                  end
            RUBY
          end
        end
      end
    end

    context 'with class' do
      it 'registers an offense for bad indentation of a class body' do
        expect_offense(<<~RUBY)
          class Test
              def func
          ^^^^ Use 2 (not 4) spaces for indentation.
              end
          end
        RUBY
      end

      it 'leaves body unchanged if the first body line is on the same line with class keyword' do
        # The class body will be corrected by IndentationConsistency.
        expect_no_offenses(<<~RUBY)
          class Test foo
              def func1
              end
                def func2
                end
          end
        RUBY
      end

      it 'accepts an empty class body' do
        expect_no_offenses(<<~RUBY)
          class Test
          end
        RUBY
      end

      it 'leaves body unchanged if the first body line is on the same line with an opening of singleton class' do
        # The class body will be corrected by IndentationConsistency.
        expect_no_offenses(<<~RUBY)
          class << self; foo
              def func1
              end
                def func2
                end
          end
        RUBY
      end

      context 'with access modifier' do
        it 'registers an offense for bad indentation of sections' do
          expect_offense(<<~RUBY)
            class Test
              public
                def e
            ^^^^ Use 2 (not 4) spaces for indentation.
                end

                def f
            ^^^^ Use 2 (not 4) spaces for indentation.
                end
            end
          RUBY
        end

        it 'registers an offense and corrects for bad modifier indentation ' \
           'before good method definition' do
          expect_offense(<<~RUBY)
            class Foo
                  private
            ^^^^^^ Use 2 (not 6) spaces for indentation.

              def foo
              end
            end
          RUBY

          expect_correction(<<~RUBY)
            class Foo
              private

              def foo
              end
            end
          RUBY
        end
      end

      context 'when consistency style is normal' do
        it 'accepts indented public, protected, and private' do
          expect_no_offenses(<<~RUBY)
            class Test
              public

              def e
              end

              protected

              def f
              end

              private

              def g
              end
            end
          RUBY
        end

        it 'registers offenses for indented_internal_methods indentation' do
          expect_offense(<<~RUBY)
            class Test
              def e
              end

              protected

                def f
            ^^^^ Use 2 (not 4) spaces for indentation.
                end

              private

                def g
            ^^^^ Use 2 (not 4) spaces for indentation.
                end
            end
          RUBY
        end
      end

      context 'when consistency style is outdent' do
        let(:access_modifier_config) { { 'EnforcedStyle' => 'outdent' } }

        it 'accepts access modifier is outdent' do
          expect_no_offenses(<<~RUBY)
            class Test
            private

              def foo
              end
            end
          RUBY
        end
      end

      context 'when consistency style is indented_internal_methods' do
        let(:consistency_config) { { 'EnforcedStyle' => 'indented_internal_methods' } }

        it 'registers an offense for normal non-indented internal methods indentation' do
          expect_offense(<<~RUBY)
            class Test
              public

              def e
              end

              protected

              def f
              ^{} Use 2 (not 0) spaces for indented_internal_methods indentation.
              end

              private

              def g
              ^{} Use 2 (not 0) spaces for indented_internal_methods indentation.
              end
            end
          RUBY
        end

        it 'registers an offense for normal non-indented internal methods ' \
           'indentation when defined in a singleton class' do
          expect_offense(<<~RUBY)
            class << self
              public

              def e
              end

              protected

              def f
              ^{} Use 2 (not 0) spaces for indented_internal_methods indentation.
              end

              private

              def g
              ^{} Use 2 (not 0) spaces for indented_internal_methods indentation.
              end
            end
          RUBY
        end
      end
    end

    context 'with module' do
      context 'when consistency style is normal' do
        it 'registers an offense for bad indentation of a module body' do
          expect_offense(<<~RUBY)
            module Test
                def func
            ^^^^ Use 2 (not 4) spaces for indentation.
                end
            end
          RUBY
        end

        it 'accepts an empty module body' do
          expect_no_offenses(<<~RUBY)
            module Test
            end
          RUBY
        end
      end

      it 'leaves body unchanged if the first body line is on the same line with module keyword' do
        # The module body will be corrected by IndentationConsistency.
        expect_no_offenses(<<~RUBY)
          module Test foo
              def func1
              end
                def func2
                end
          end
        RUBY
      end

      context 'when consistency style is indented_internal_methods' do
        let(:consistency_config) { { 'EnforcedStyle' => 'indented_internal_methods' } }

        it 'registers an offense for bad indentation of a module body' do
          expect_offense(<<~RUBY)
            module Test
               def func1
            ^^^ Use 2 (not 3) spaces for indentation.
               end
              private
             def func2
             ^ Use 2 (not -1) spaces for indented_internal_methods indentation.
             end
            end
          RUBY
        end

        it 'accepts normal non-indented internal methods of module functions' do
          expect_no_offenses(<<~RUBY)
            module Test
              module_function
              def func
              end
            end
          RUBY
        end
      end
    end

    context 'with begin/rescue/else/ensure/end' do
      it 'registers an offense for bad indentation of bodies' do
        expect_offense(<<~RUBY)
          def my_func
            puts 'do something outside block'
            begin
            puts 'do something error prone'
            ^{} Use 2 (not 0) spaces for indentation.
            rescue SomeException, SomeOther => e
             puts 'wrongly indented error handling'
            ^ Use 2 (not 1) spaces for indentation.
            rescue
             puts 'wrongly indented error handling'
            ^ Use 2 (not 1) spaces for indentation.
            else
               puts 'wrongly indented normal case handling'
            ^^^ Use 2 (not 3) spaces for indentation.
            ensure
                puts 'wrongly indented common handling'
            ^^^^ Use 2 (not 4) spaces for indentation.
            end
          end
        RUBY
      end
    end

    context 'with def/rescue/end' do
      it 'registers an offense for bad indentation of bodies' do
        expect_offense(<<~RUBY)
          def my_func
            puts 'do something error prone'
          rescue SomeException
           puts 'wrongly indented error handling'
          ^ Use 2 (not 1) spaces for indentation.
          rescue
           puts 'wrongly indented error handling'
          ^ Use 2 (not 1) spaces for indentation.
          end
        RUBY

        expect_correction(<<~RUBY)
          def my_func
            puts 'do something error prone'
          rescue SomeException
            puts 'wrongly indented error handling'
          rescue
            puts 'wrongly indented error handling'
          end
        RUBY
      end

      it 'registers an offense for bad indent of defs bodies with a modifier' do
        expect_offense(<<~RUBY)
          foo def self.my_func
            puts 'do something error prone'
          rescue SomeException
           puts 'wrongly indented error handling'
          ^ Use 2 (not 1) spaces for indentation.
          rescue
           puts 'wrongly indented error handling'
          ^ Use 2 (not 1) spaces for indentation.
          end
        RUBY
      end
    end

    context 'with block' do
      context 'when consistency style is indented_internal_methods' do
        let(:consistency_config) { { 'EnforcedStyle' => 'indented_internal_methods' } }

        it 'registers an offense for bad indentation in a do/end body' do
          expect_offense(<<~RUBY)
            concern :Authenticatable do
              def foo
                puts "foo"
              end

              private

              def bar
              ^{} Use 2 (not 0) spaces for indented_internal_methods indentation.
                puts "bar"
              end
            end
          RUBY
        end
      end

      it 'registers an offense for bad indentation of a do/end body' do
        expect_offense(<<~RUBY)
          a = func do
           b
          ^ Use 2 (not 1) spaces for indentation.
          end
        RUBY
      end

      it 'registers an offense for bad indentation of a {} body' do
        expect_offense(<<~RUBY)
          func {
             b
          ^^^ Use 2 (not 3) spaces for indentation.
          }
        RUBY
      end

      it 'accepts a correctly indented block body' do
        expect_no_offenses(<<~RUBY)
          a = func do
            b
          end
        RUBY
      end

      it 'accepts an empty block body' do
        expect_no_offenses(<<~RUBY)
          a = func do
          end
        RUBY
      end

      it 'does not register an offense for good indentation of `do` ... `ensure` ... `end` block' do
        expect_no_offenses(<<~RUBY)
          do_something do
            foo
          ensure
            handle_error
          end
        RUBY
      end

      it 'registers an offense for bad indentation of `do` ... `ensure` ... `end` block' do
        expect_offense(<<~RUBY)
          do_something do
              foo
          ^^^^ Use 2 (not 4) spaces for indentation.
          ensure
            handle_error
          end
        RUBY
      end

      context 'when using safe navigation operator' do
        it 'registers an offense for bad indentation of a {} body' do
          expect_offense(<<~RUBY)
            func {
               receiver&.b
            ^^^ Use 2 (not 3) spaces for indentation.
            }
          RUBY
        end

        it 'registers an offense for an if with setter' do
          expect_offense(<<~RUBY)
            foo&.bar = if baz
                         derp
            ^^^^^^^^^^^^^ Use 2 (not 13) spaces for indentation.
                       end
          RUBY
        end
      end

      context 'Ruby 2.7', :ruby27 do
        it 'registers an offense for bad indentation of a {} body' do
          expect_offense(<<~RUBY)
            func {
               _1&.foo
            ^^^ Use 2 (not 3) spaces for indentation.
            }
          RUBY
        end

        it 'registers an offense for bad indentation of a do-end body' do
          expect_offense(<<~RUBY)
            func do
               _1&.foo
            ^^^ Use 2 (not 3) spaces for indentation.
            end
          RUBY
        end
      end

      # The cop uses the block end/} as the base for indentation, so if it's not
      # on its own line, all bets are off.
      it 'accepts badly indented code if block end is not on separate line' do
        expect_no_offenses(<<~RUBY)
          foo {
          def baz
          end }
        RUBY
      end
    end
  end

  it 'does not register an offense for blocks with a very large offset' do
    expect_no_offenses(<<~RUBY)
      foo {
      #{' ' * 100_001}}
    RUBY
  end
end
