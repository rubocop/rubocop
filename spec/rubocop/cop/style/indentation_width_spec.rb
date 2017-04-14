# frozen_string_literal: true

describe RuboCop::Cop::Layout::IndentationWidth do
  subject(:cop) { described_class.new(config) }
  let(:config) do
    RuboCop::Config.new('Layout/IndentationWidth' => cop_config,
                        'Layout/IndentationConsistency' => consistency_config,
                        'Lint/EndAlignment' => end_alignment_config,
                        'Lint/DefEndAlignment' => def_end_alignment_config)
  end
  let(:consistency_config) { { 'EnforcedStyle' => 'normal' } }
  let(:end_alignment_config) do
    { 'Enabled' => true, 'EnforcedStyleAlignWith' => 'variable' }
  end
  let(:def_end_alignment_config) do
    { 'Enabled' => true, 'EnforcedStyleAlignWith' => 'start_of_line' }
  end

  context 'with Width set to 4' do
    let(:cop_config) { { 'Width' => 4 } }

    context 'for a file with byte order mark' do
      let(:bom) { "\xef\xbb\xbf" }

      it 'accepts correctly indented method definition' do
        inspect_source(cop, <<-END.strip_indent)
          #{bom}class Test
              def method
              end
          end
        END
        expect(cop.offenses).to be_empty
      end
    end

    context 'with ignored patterns set' do
      let(:cop_config) do
        {
          'Width' => 4,
          'IgnoredPatterns' => ['^\s*module', '^\s*(els)?if.*[A-Z][a-z]+']
        }
      end

      it 'accepts unindented lines for those keywords' do
        inspect_source(cop, <<-END.strip_indent)
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
        END
        expect(cop.offenses).to be_empty
      end
    end

    context 'with if statement' do
      it 'registers an offense for bad indentation of an if body' do
        inspect_source(cop, <<-END.strip_indent)
          if cond
           func
          end
        END
        expect(cop.messages).to eq(['Use 4 (not 1) spaces for indentation.'])
        expect(cop.highlights).to eq([' '])
      end
    end

    describe '#autocorrect' do
      it 'corrects bad indentation' do
        corrected = autocorrect_source(cop, <<-END.strip_indent)
          if a1
             b1
             b1
          elsif a2
           b2
          else
              c
          end
        END
        # The second `b1` will be corrected by IndentationConsistency.
        expect(corrected).to eq <<-END.strip_indent
          if a1
              b1
             b1
          elsif a2
              b2
          else
              c
          end
        END
      end
    end
  end

  context 'with Width set to 2' do
    let(:cop_config) { { 'Width' => 2 } }

    context 'with if statement' do
      it 'registers an offense for bad indentation of an if body' do
        inspect_source(cop, <<-END.strip_indent)
          if cond
           func
          end
        END
        expect(cop.messages).to eq(['Use 2 (not 1) spaces for indentation.'])
        expect(cop.highlights).to eq([' '])
      end

      it 'registers an offense for bad indentation of an else body' do
        inspect_source(cop, <<-END.strip_indent)
          if cond
            func1
          else
           func2
          end
        END
        expect(cop.messages).to eq(['Use 2 (not 1) spaces for indentation.'])
        expect(cop.highlights).to eq([' '])
      end

      it 'registers an offense for bad indentation of an elsif body' do
        inspect_source(cop, <<-END.strip_indent)
          if a1
            b1
          elsif a2
           b2
          else
            c
          end
        END
        expect(cop.messages).to eq(['Use 2 (not 1) spaces for indentation.'])
      end

      it 'registers offense for bad indentation of ternary inside else' do
        inspect_source(cop, <<-END.strip_indent)
          if a
            b
          else
               x ? y : z
          end
        END
        expect(cop.messages)
          .to eq(['Use 2 (not 5) spaces for indentation.'])
        expect(cop.highlights).to eq(['     '])
      end

      it 'registers offense for bad indentation of modifier if in else' do
        inspect_source(cop, <<-END.strip_indent)
          if a
            b
          else
             x if y
          end
        END
        expect(cop.messages)
          .to eq(['Use 2 (not 3) spaces for indentation.'])
      end

      it 'accepts indentation after if on new line after assignment' do
        inspect_source(cop, <<-END.strip_indent)
          Rails.application.config.ideal_postcodes_key =
            if Rails.env.production? || Rails.env.staging?
              "AAAA-AAAA-AAAA-AAAA"
            end
        END
        expect(cop.offenses).to be_empty
      end

      it 'accepts `rescue` after an empty body' do
        inspect_source(cop, <<-END.strip_indent)
          begin
          rescue
            handle_error
          end
        END
        expect(cop.offenses).to be_empty
      end

      it 'accepts `ensure` after an empty body' do
        inspect_source(cop, <<-END.strip_indent)
          begin
          ensure
            something
          end
        END
        expect(cop.offenses).to be_empty
      end

      describe '#autocorrect' do
        it 'corrects bad indentation' do
          corrected = autocorrect_source(cop, <<-END.strip_indent)
            if a1
               b1
               b1
            elsif a2
             b2
            else
                c
            end
          END
          # The second `b1` will be corrected by IndentationConsistency.
          expect(corrected).to eq <<-END.strip_indent
            if a1
              b1
               b1
            elsif a2
              b2
            else
              c
            end
          END
        end

        it 'does not correct in scopes that contain block comments' do
          source = <<-END.strip_indent
            module Foo
            # The class has a block comment within, so it's not corrected.
            class Bar
            =begin
            This is a nice long
            comment
            which spans a few lines
            =end
            # The method has no block comment inside,
            # but it's within a class that has a block
            # comment, so it's not corrected either.
            def baz
            do_something
            end
            end
            end
          END

          expect(autocorrect_source(cop, source)).to eq source
        end

        it 'does not indent heredoc strings' do
          corrected = autocorrect_source(cop, <<-'END'.strip_indent)
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
          END
          expect(corrected).to eq <<-'END'.strip_indent
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
          END
        end

        it 'indents parenthesized expressions' do
          src = <<-END.strip_indent
            var1 = nil
            array_list = []
            if var1.attr1 != 0 || array_list.select{ |w|
                                    (w.attr2 == var1.attr2)
                             }.blank?
              array_list << var1
            end
          END
          corrected = autocorrect_source(cop, src)
          expect(corrected)
            .to eq <<-END.strip_indent
              var1 = nil
              array_list = []
              if var1.attr1 != 0 || array_list.select{ |w|
                                 (w.attr2 == var1.attr2)
                               }.blank?
                array_list << var1
              end
            END
        end

        it 'leaves rescue ; end unchanged' do
          src = <<-END.strip_indent
            if variable
              begin
                do_something
              rescue ; end # consume any exception
            end
          END
          corrected = autocorrect_source(cop, src)
          expect(corrected).to eq src
        end

        it 'leaves block unchanged if block end is not on its own line' do
          src = <<-END.strip_indent
            a_function {
              # a comment
              result = AObject.find_by_attr(attr) if attr
              result || AObject.make(
                  :attr => attr,
                  :attr2 => Other.get_value(),
                  :attr3 => Another.get_value()) }
          END
          corrected = autocorrect_source(cop, src)
          expect(corrected).to eq src
        end

        it 'handles lines with only whitespace' do
          corrected = autocorrect_source(cop, ['def x',
                                               '    y',
                                               ' ',
                                               'rescue',
                                               'end'])

          expect(corrected).to eq ['def x',
                                   '  y',
                                   ' ',
                                   'rescue',
                                   'end'].join("\n")
        end
      end

      it 'accepts a one line if statement' do
        inspect_source(cop, 'if cond then func1 else func2 end')
        expect(cop.offenses).to be_empty
      end

      it 'accepts a correctly aligned if/elsif/else/end' do
        inspect_source(cop, <<-END.strip_indent)
          if a1
            b1
          elsif a2
            b2
          else
            c
          end
        END
        expect(cop.offenses).to be_empty
      end

      it 'accepts a correctly aligned if/elsif/else/end as a method argument' do
        inspect_source(cop, <<-END.strip_indent)
          foo(
            if a1
              b1
            elsif a2
              b2
            else
              c
            end
          )
        END
        expect(cop.offenses).to be_empty
      end

      it 'accepts if/elsif/else/end laid out as a table' do
        inspect_source(cop, <<-END.strip_indent)
          if    @io == $stdout then str << "$stdout"
          elsif @io == $stdin  then str << "$stdin"
          elsif @io == $stderr then str << "$stderr"
          else                      str << @io.class.to_s
          end
        END
        expect(cop.offenses).to be_empty
      end

      it 'accepts if/then/else/end laid out as another table' do
        inspect_source(cop, <<-END.strip_indent)
          if File.exist?('config.save')
          then ConfigTable.load
          else ConfigTable.new
          end
        END
        expect(cop.offenses).to be_empty
      end

      it 'accepts an empty if' do
        inspect_source(cop, <<-END.strip_indent)
          if a
          else
          end
        END
        expect(cop.offenses).to be_empty
      end

      context 'with assignment' do
        context 'when alignment style is variable' do
          context 'and end is aligned with variable' do
            it 'accepts an if with end aligned with setter' do
              inspect_source(cop, <<-END.strip_indent)
                foo.bar = if baz
                  derp
                end
              END
              expect(cop.offenses).to be_empty
            end

            it 'accepts an if with end aligned with element assignment' do
              inspect_source(cop, <<-END.strip_indent)
                foo[bar] = if baz
                  derp
                end
              END
              expect(cop.offenses).to be_empty
            end

            it 'accepts an if with end aligned with variable' do
              inspect_source(cop, <<-END.strip_indent)
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
              END
              expect(cop.offenses).to be_empty
            end

            it 'accepts an if/else' do
              inspect_source(cop, <<-END.strip_indent)
                var = if a
                  0
                else
                  1
                end
              END
              expect(cop.offenses).to be_empty
            end

            it 'accepts an if/else with chaining after the end' do
              inspect_source(cop, <<-END.strip_indent)
                var = if a
                  0
                else
                  1
                end.abc.join("")
              END
              expect(cop.offenses).to be_empty
            end

            it 'accepts an if/else with chaining with a block after the end' do
              inspect_source(cop, <<-END.strip_indent)
                var = if a
                  0
                else
                  1
                end.abc.tap {}
              END
              expect(cop.offenses).to be_empty
            end
          end

          context 'and end is aligned with keyword' do
            it 'registers an offense for an if with setter' do
              inspect_source(cop, <<-END.strip_indent)
                foo.bar = if baz
                            derp
                          end
              END
              expect(cop.messages)
                .to eq(['Use 2 (not 12) spaces for indentation.'])
            end

            it 'registers an offense for an if with element assignment' do
              inspect_source(cop, <<-END.strip_indent)
                foo[bar] = if baz
                             derp
                           end
              END
              expect(cop.messages)
                .to eq(['Use 2 (not 13) spaces for indentation.'])
            end

            it 'registers an offense for an if' do
              inspect_source(cop, <<-END.strip_indent)
                var = if a
                        0
                      end
              END
              expect(cop.messages)
                .to eq(['Use 2 (not 8) spaces for indentation.'])
            end

            it 'registers an offense for a while' do
              inspect_source(cop, <<-END.strip_indent)
                var = while a
                        b
                      end
              END
              expect(cop.messages)
                .to eq(['Use 2 (not 8) spaces for indentation.'])
            end

            it 'registers an offense for an until' do
              inspect_source(cop, <<-END.strip_indent)
                var = until a
                        b
                      end
              END
              expect(cop.messages)
                .to eq(['Use 2 (not 8) spaces for indentation.'])
            end
          end

          context 'and end is aligned randomly' do
            it 'registers an offense for an if' do
              inspect_source(cop, <<-END.strip_indent)
                var = if a
                          0
                      end
              END
              expect(cop.messages)
                .to eq(['Use 2 (not 10) spaces for indentation.'])
            end

            it 'registers an offense for a while' do
              inspect_source(cop, <<-END.strip_indent)
                var = while a
                          b
                      end
              END
              expect(cop.messages)
                .to eq(['Use 2 (not 10) spaces for indentation.'])
            end

            it 'registers an offense for an until' do
              inspect_source(cop, <<-END.strip_indent)
                var = until a
                          b
                      end
              END
              expect(cop.messages)
                .to eq(['Use 2 (not 10) spaces for indentation.'])
            end
          end
        end

        shared_examples 'assignment and if with keyword alignment' do
          context 'and end is aligned with variable' do
            it 'registers an offense for an if' do
              inspect_source(cop, <<-END.strip_indent)
                var = if a
                  0
                end
              END
              expect(cop.messages)
                .to eq(['Use 2 (not -4) spaces for indentation.'])
            end

            it 'registers an offense for a while' do
              inspect_source(cop, <<-END.strip_indent)
                var = while a
                  b
                end
              END
              expect(cop.messages)
                .to eq(['Use 2 (not -4) spaces for indentation.'])
            end

            it 'autocorrects bad indentation' do
              corrected = autocorrect_source(cop, <<-END.strip_indent)
                var = if a
                  b
                end

                var = while a
                  b
                end
              END
              # Not this cop's job to fix the `end`.
              expect(corrected).to eq <<-END.strip_indent
                var = if a
                        b
                end

                var = while a
                        b
                end
              END
            end
          end

          context 'and end is aligned with keyword' do
            it 'accepts an if in assignment' do
              inspect_source(cop, <<-END.strip_indent)
                var = if a
                        0
                      end
              END
              expect(cop.offenses).to be_empty
            end

            it 'accepts an if/else in assignment' do
              inspect_source(cop, <<-END.strip_indent)
                var = if a
                        0
                      else
                        1
                      end
              END
              expect(cop.offenses).to be_empty
            end

            it 'accepts an if/else in assignment on next line' do
              inspect_source(cop, <<-END.strip_indent)
                var =
                  if a
                    0
                  else
                    1
                  end
              END
              expect(cop.offenses).to be_empty
            end

            it 'accepts a while in assignment' do
              inspect_source(cop, <<-END.strip_indent)
                var = while a
                        b
                      end
              END
              expect(cop.offenses).to be_empty
            end

            it 'accepts an until in assignment' do
              inspect_source(cop, <<-END.strip_indent)
                var = until a
                        b
                      end
              END
              expect(cop.offenses).to be_empty
            end
          end
        end

        context 'when alignment style is keyword by choice' do
          let(:end_alignment_config) do
            { 'Enabled' => true, 'EnforcedStyleAlignWith' => 'keyword' }
          end

          include_examples 'assignment and if with keyword alignment'
        end
      end

      it 'accepts an if/else branches with rescue clauses' do
        # Because of how the rescue clauses come out of Parser, these are
        # special and need to be tested.
        inspect_source(cop, <<-END.strip_indent)
          if a
            a rescue nil
          else
            a rescue nil
          end
        END
        expect(cop.offenses).to be_empty
      end
    end

    context 'with unless' do
      it 'registers an offense for bad indentation of an unless body' do
        inspect_source(cop, <<-END.strip_indent)
          unless cond
           func
          end
        END
        expect(cop.messages).to eq(['Use 2 (not 1) spaces for indentation.'])
      end

      it 'accepts an empty unless' do
        inspect_source(cop, <<-END.strip_indent)
          unless a
          else
          end
        END
        expect(cop.offenses).to be_empty
      end
    end

    context 'with case' do
      it 'registers an offense for bad indentation in a case/when body' do
        inspect_source(cop, <<-END.strip_indent)
          case a
          when b
           c
          end
        END
        expect(cop.messages).to eq(['Use 2 (not 1) spaces for indentation.'])
      end

      it 'registers an offense for bad indentation in a case/else body' do
        inspect_source(cop, <<-END.strip_indent)
          case a
          when b
            c
          when d
            e
          else
             f
          end
        END
        expect(cop.messages).to eq(['Use 2 (not 3) spaces for indentation.'])
      end

      it 'accepts correctly indented case/when/else' do
        inspect_source(cop, <<-END.strip_indent)
          case a
          when b
            c
            c
          when d
          else
            f
          end
        END
        expect(cop.offenses).to be_empty
      end

      it 'accepts aligned values in when clause' do
        inspect_source(cop, <<-'END'.strip_indent)
          case superclass
          when /\A(#{NAMESPACEMATCH})(?:\s|\Z)/,
               /\A(Struct|OStruct)\.new/,
               /\ADelegateClass\((.+?)\)\s*\Z/,
               /\A(#{NAMESPACEMATCH})\(/
            $1
          when "self"
            namespace.path
          end
        END
        expect(cop.offenses).to be_empty
      end

      it 'accepts case/when/else laid out as a table' do
        inspect_source(cop, <<-END.strip_indent)
          case sexp.loc.keyword.source
          when 'if'     then cond, body, _else = *sexp
          when 'unless' then cond, _else, body = *sexp
          else               cond, body = *sexp
          end
        END
        expect(cop.offenses).to be_empty
      end

      it 'accepts case/when/else with then beginning a line' do
        inspect_source(cop, <<-END.strip_indent)
          case sexp.loc.keyword.source
          when 'if'
          then cond, body, _else = *sexp
          end
        END
        expect(cop.offenses).to be_empty
      end

      it 'accepts indented when/else plus indented body' do
        # "Indent when as deep as case" is the job of another cop.
        inspect_source(cop, <<-END.strip_indent)
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
        END
        expect(cop.offenses).to be_empty
      end
    end

    context 'with while/until' do
      it 'registers an offense for bad indentation of a while body' do
        inspect_source(cop, <<-END.strip_indent)
          while cond
           func
          end
        END
        expect(cop.messages).to eq(['Use 2 (not 1) spaces for indentation.'])
      end

      it 'registers an offense for bad indentation of begin/end/while' do
        inspect_source(cop, <<-END.strip_indent)
          something = begin
           func1
             func2
          end while cond
        END
        expect(cop.messages).to eq(['Use 2 (not 1) spaces for indentation.'])
      end

      it 'registers an offense for bad indentation of an until body' do
        inspect_source(cop, <<-END.strip_indent)
          until cond
           func
          end
        END
        expect(cop.messages).to eq(['Use 2 (not 1) spaces for indentation.'])
      end

      it 'accepts an empty while' do
        inspect_source(cop, <<-END.strip_indent)
          while a
          end
        END
        expect(cop.offenses).to be_empty
      end
    end

    context 'with for' do
      it 'registers an offense for bad indentation of a for body' do
        inspect_source(cop, <<-END.strip_indent)
          for var in 1..10
           func
          end
        END
        expect(cop.messages).to eq(['Use 2 (not 1) spaces for indentation.'])
      end

      it 'accepts an empty for' do
        inspect_source(cop, <<-END.strip_indent)
          for var in 1..10
          end
        END
        expect(cop.offenses).to be_empty
      end
    end

    context 'with def/defs' do
      shared_examples 'without modifier on the same line' do
        it 'registers an offense for bad indentation of a def body' do
          inspect_source(cop, <<-END.strip_indent)
            def test
                func1
                 func2 # No offense registered for this.
            end
          END
          expect(cop.messages).to eq(['Use 2 (not 4) spaces for indentation.'])
        end

        it 'registers an offense for bad indentation of a defs body' do
          inspect_source(cop, <<-END.strip_indent)
            def self.test
               func
            end
          END
          expect(cop.messages).to eq(['Use 2 (not 3) spaces for indentation.'])
        end

        it 'accepts an empty def body' do
          inspect_source(cop, <<-END.strip_indent)
            def test
            end
          END
          expect(cop.offenses).to be_empty
        end

        it 'accepts an empty defs body' do
          inspect_source(cop, <<-END.strip_indent)
            def self.test
            end
          END
          expect(cop.offenses).to be_empty
        end

        it 'with an assignment' do
          inspect_source(cop, <<-END.strip_indent)
            something = def self.foo
            end
          END
          expect(cop.offenses).to be_empty
        end
      end

      context 'when end is aligned with start of line' do
        let(:def_end_alignment_config) do
          { 'Enabled' => true, 'EnforcedStyleAlignWith' => 'start_of_line' }
        end

        include_examples 'without modifier on the same line'

        if RUBY_VERSION >= '2.1'
          context 'when modifier and def are on the same line' do
            it 'accepts a correctly aligned body' do
              inspect_source(cop, <<-END.strip_indent)
                foo def test
                  something
                end
              END
              expect(cop.offenses).to be_empty
            end

            it 'registers an offense for bad indentation of a def body' do
              inspect_source(cop, <<-END.strip_indent)
                foo def test
                      something
                    end
              END
              expect(cop.messages)
                .to eq(['Use 2 (not 6) spaces for indentation.'])
            end

            it 'registers an offense for bad indentation of a defs body' do
              inspect_source(cop, <<-END.strip_indent)
                foo def self.test
                      something
                    end
              END
              expect(cop.messages)
                .to eq(['Use 2 (not 6) spaces for indentation.'])
            end
          end
        end
      end

      context 'when end is aligned with def' do
        let(:def_end_alignment_config) do
          { 'Enabled' => true, 'EnforcedStyleAlignWith' => 'def' }
        end

        include_examples 'without modifier on the same line'

        if RUBY_VERSION >= '2.1'
          context 'when modifier and def are on the same line' do
            it 'accepts a correctly aligned body' do
              inspect_source(cop, <<-END.strip_indent)
                foo def test
                      something
                end
              END
              expect(cop.offenses).to be_empty
            end

            it 'registers an offense for bad indentation of a def body' do
              inspect_source(cop, <<-END.strip_indent)
                foo def test
                  something
                    end
              END
              expect(cop.messages)
                .to eq(['Use 2 (not -2) spaces for indentation.'])
            end

            it 'registers an offense for bad indentation of a defs body' do
              inspect_source(cop, <<-END.strip_indent)
                foo def self.test
                  something
                    end
              END
              expect(cop.messages)
                .to eq(['Use 2 (not -2) spaces for indentation.'])
            end
          end
        end
      end
    end

    context 'with class' do
      it 'registers an offense for bad indentation of a class body' do
        inspect_source(cop, <<-END.strip_indent)
          class Test
              def func
              end
          end
        END
        expect(cop.messages).to eq(['Use 2 (not 4) spaces for indentation.'])
      end

      it 'accepts an empty class body' do
        inspect_source(cop, <<-END.strip_indent)
          class Test
          end
        END
        expect(cop.offenses).to be_empty
      end

      context 'when consistency style is normal' do
        it 'accepts indented public, protected, and private' do
          inspect_source(cop, <<-END.strip_indent)
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
          END
          expect(cop.offenses).to be_empty
        end
      end

      context 'when consistency style is rails' do
        let(:consistency_config) { { 'EnforcedStyle' => 'rails' } }

        it 'registers an offense for normal non-rails indentation' do
          inspect_source(cop, <<-END.strip_indent)
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
          END
          expect(cop.messages)
            .to eq(['Use 2 (not 0) spaces for rails indentation.'] * 2)
          expect(cop.offenses.map(&:line)).to eq([9, 14])
        end
      end
    end

    context 'with module' do
      context 'when consistency style is normal' do
        it 'registers an offense for bad indentation of a module body' do
          inspect_source(cop, <<-END.strip_indent)
            module Test
                def func
                end
            end
          END
          expect(cop.messages).to eq(['Use 2 (not 4) spaces for indentation.'])
        end

        it 'accepts an empty module body' do
          inspect_source(cop, <<-END.strip_indent)
            module Test
            end
          END
          expect(cop.offenses).to be_empty
        end
      end

      context 'when consistency style is rails' do
        let(:consistency_config) { { 'EnforcedStyle' => 'rails' } }

        it 'registers an offense for bad indentation of a module body' do
          inspect_source(cop, <<-END.strip_indent)
            module Test
               def func1
               end
              private
             def func2
             end
            end
          END
          expect(cop.messages)
            .to eq(['Use 2 (not 3) spaces for indentation.',
                    'Use 2 (not -1) spaces for rails indentation.'])
        end

        it 'accepts normal non-rails indentation of module functions' do
          inspect_source(cop, <<-END.strip_indent)
            module Test
              module_function
              def func
              end
            end
          END
          expect(cop.offenses).to be_empty
        end
      end
    end

    context 'with begin/rescue/else/ensure/end' do
      it 'registers an offense for bad indentation of bodies' do
        inspect_source(cop, <<-END.strip_indent)
          def my_func
            puts 'do something outside block'
            begin
            puts 'do something error prone'
            rescue SomeException, SomeOther => e
             puts 'wrongly intended error handling'
            rescue
             puts 'wrongly intended error handling'
            else
               puts 'wrongly intended normal case handling'
            ensure
                puts 'wrongly intended common handling'
            end
          end
        END
        expect(cop.messages).to eq(['Use 2 (not 0) spaces for indentation.',
                                    'Use 2 (not 1) spaces for indentation.',
                                    'Use 2 (not 1) spaces for indentation.',
                                    'Use 2 (not 3) spaces for indentation.',
                                    'Use 2 (not 4) spaces for indentation.'])
      end
    end

    context 'with def/rescue/end' do
      it 'registers an offense for bad indentation of bodies' do
        inspect_source(cop, <<-END.strip_indent)
          def my_func
            puts 'do something error prone'
          rescue SomeException
           puts 'wrongly intended error handling'
          rescue
           puts 'wrongly intended error handling'
          end
        END
        expect(cop.messages).to eq(['Use 2 (not 1) spaces for indentation.',
                                    'Use 2 (not 1) spaces for indentation.'])
      end

      it 'registers an offense for bad indent of defs bodies with a modifier' do
        inspect_source(cop, <<-END.strip_indent)
          foo def self.my_func
            puts 'do something error prone'
          rescue SomeException
           puts 'wrongly intended error handling'
          rescue
           puts 'wrongly intended error handling'
          end
        END
        expect(cop.messages).to eq(['Use 2 (not 1) spaces for indentation.',
                                    'Use 2 (not 1) spaces for indentation.'])
      end
    end

    context 'with block' do
      context 'when consistency style is rails' do
        let(:consistency_config) { { 'EnforcedStyle' => 'rails' } }

        it 'registers an offense for bad indentation in a do/end body' do
          inspect_source(cop, <<-END.strip_indent)
            concern :Authenticatable do
              def foo
                puts "foo"
              end

              private

              def bar
                puts "bar"
              end
            end
          END
          expect(cop.messages)
            .to eq(['Use 2 (not 0) spaces for rails indentation.'])
        end
      end

      it 'registers an offense for bad indentation of a do/end body' do
        inspect_source(cop, <<-END.strip_indent)
          a = func do
           b
          end
        END
        expect(cop.messages).to eq(['Use 2 (not 1) spaces for indentation.'])
      end

      it 'registers an offense for bad indentation of a {} body' do
        inspect_source(cop, <<-END.strip_indent)
          func {
             b
          }
        END
        expect(cop.messages).to eq(['Use 2 (not 3) spaces for indentation.'])
      end

      it 'accepts a correctly indented block body' do
        inspect_source(cop, <<-END.strip_indent)
          a = func do
            b
          end
        END
        expect(cop.offenses).to be_empty
      end

      it 'accepts an empty block body' do
        inspect_source(cop, <<-END.strip_indent)
          a = func do
          end
        END
        expect(cop.offenses).to be_empty
      end

      # The cop uses the block end/} as the base for indentation, so if it's not
      # on its own line, all bets are off.
      it 'accepts badly indented code if block end is not on separate line' do
        inspect_source(cop, <<-END.strip_indent)
          foo {
          def baz
          end }
        END
        expect(cop.offenses).to be_empty
      end
    end
  end
end
