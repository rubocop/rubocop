# frozen_string_literal: true

describe RuboCop::Cop::Style::IndentationConsistency, :config do
  subject(:cop) { described_class.new(config) }

  let(:cop_config) { { 'EnforcedStyle' => 'normal' } }

  context 'with if statement' do
    it 'registers an offense for bad indentation in an if body' do
      inspect_source(cop, <<-END.strip_indent)
        if cond
         func
          func
        end
      END
      expect(cop.messages).to eq(['Inconsistent indentation detected.'])
    end

    it 'registers an offense for bad indentation in an else body' do
      inspect_source(cop, <<-END.strip_indent)
        if cond
          func1
        else
         func2
          func2
        end
      END
      expect(cop.messages).to eq(['Inconsistent indentation detected.'])
    end

    it 'registers an offense for bad indentation in an elsif body' do
      inspect_source(cop, <<-END.strip_indent)
        if a1
          b1
        elsif a2
         b2
        b3
        else
          c
        end
      END
      expect(cop.messages).to eq(['Inconsistent indentation detected.'])
    end

    it 'autocorrects bad indentation' do
      corrected = autocorrect_source(cop, <<-END.strip_indent)
        if a1
           b1
        elsif a2
         b2
          b3
        else
            c
        end
      END
      expect(corrected).to eq <<-END.strip_indent
        if a1
           b1
        elsif a2
         b2
         b3
        else
            c
        end
      END
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

    it 'accepts if/elsif/else/end with fullwidth characters' do
      inspect_source(cop, <<-END.strip_indent)
        p 'Ｒｕｂｙ', if a then b
                                c
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

    it 'accepts an if in assignment with end aligned with variable' do
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

    it 'accepts an if/else in assignment with end aligned with variable' do
      inspect_source(cop, <<-END.strip_indent)
        var = if a
          0
        else
          1
        end
      END
      expect(cop.offenses).to be_empty
    end

    it 'accepts an if/else in assignment with end aligned with variable ' \
       'and chaining after the end' do
      inspect_source(cop, <<-END.strip_indent)
        var = if a
          0
        else
          1
        end.abc.join("")
      END
      expect(cop.offenses).to be_empty
    end

    it 'accepts an if/else in assignment with end aligned with variable ' \
       'and chaining with a block after the end' do
      inspect_source(cop, <<-END.strip_indent)
        var = if a
          0
        else
          1
        end.abc.tap {}
      END
      expect(cop.offenses).to be_empty
    end

    it 'accepts an if in assignment with end aligned with if' do
      inspect_source(cop, <<-END.strip_indent)
        var = if a
                0
              end
      END
      expect(cop.offenses).to be_empty
    end

    it 'accepts an if/else in assignment with end aligned with if' do
      inspect_source(cop, <<-END.strip_indent)
        var = if a
                0
              else
                1
              end
      END
      expect(cop.offenses).to be_empty
    end

    it 'accepts an if/else in assignment on next line with end aligned ' \
       'with if' do
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
    it 'registers an offense for bad indentation in an unless body' do
      inspect_source(cop, <<-END.strip_indent)
        unless cond
         func
          func
        end
      END
      expect(cop.messages).to eq(['Inconsistent indentation detected.'])
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
            d
        end
      END
      expect(cop.messages).to eq(['Inconsistent indentation detected.'])
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
          g
        end
      END
      expect(cop.messages).to eq(['Inconsistent indentation detected.'])
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
    it 'registers an offense for bad indentation in a while body' do
      inspect_source(cop, <<-END.strip_indent)
        while cond
         func
          func
        end
      END
      expect(cop.messages).to eq(['Inconsistent indentation detected.'])
    end

    it 'registers an offense for bad indentation in begin/end/while' do
      inspect_source(cop, <<-END.strip_indent)
        something = begin
         func1
           func2
        end while cond
      END
      expect(cop.messages).to eq(['Inconsistent indentation detected.'])
    end

    it 'registers an offense for bad indentation in an until body' do
      inspect_source(cop, <<-END.strip_indent)
        until cond
         func
          func
        end
      END
      expect(cop.messages).to eq(['Inconsistent indentation detected.'])
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
    it 'registers an offense for bad indentation in a for body' do
      inspect_source(cop, <<-END.strip_indent)
        for var in 1..10
         func
        func
        end
      END
      expect(cop.messages).to eq(['Inconsistent indentation detected.'])
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
    it 'registers an offense for bad indentation in a def body' do
      inspect_source(cop, <<-END.strip_indent)
        def test
            func1
             func2
        end
      END
      expect(cop.messages)
        .to eq(['Inconsistent indentation detected.'])
    end

    it 'registers an offense for bad indentation in a defs body' do
      inspect_source(cop, <<-END.strip_indent)
        def self.test
           func
            func
        end
      END
      expect(cop.messages).to eq(['Inconsistent indentation detected.'])
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
  end

  context 'with class' do
    context 'with rails style configured' do
      let(:cop_config) { { 'EnforcedStyle' => 'rails' } }

      it 'accepts different indentation in different visibility sections' do
        inspect_source(cop, <<-END.strip_indent)
          class Cat
            def meow
              puts('Meow!')
            end

            protected

              def can_we_be_friends?(another_cat)
                # some logic
              end

              def related_to?(another_cat)
                # some logic
              end

            private

                        # Here we go back an indentation level again. This is a
                        # violation of the Rails style, but it's not for this
                        # cop to report. Style/IndentationWidth will handle it.
            def meow_at_3am?
              rand < 0.8
            end

                        # As long as the indentation of this method is
                        # consistent with that of the last one, we're fine.
            def meow_at_4am?
              rand < 0.8
            end
          end
        END
        expect(cop.offenses).to be_empty
      end
    end

    context 'with normal style configured' do
      it 'registers an offense for bad indentation in a class body' do
        inspect_source(cop, <<-END.strip_indent)
          class Test
              def func1
              end
            def func2
            end
          end
        END
        expect(cop.messages)
          .to eq(['Inconsistent indentation detected.'])
      end

      it 'accepts an empty class body' do
        inspect_source(cop, <<-END.strip_indent)
          class Test
          end
        END
        expect(cop.offenses).to be_empty
      end

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

      it 'registers an offense for bad indentation in def but not for ' \
         'outdented public, protected, and private' do
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
        expect(cop.messages).to eq(['Inconsistent indentation detected.'])
        expect(cop.highlights).to eq(["def g\n end"])
      end
    end
  end

  context 'with module' do
    it 'registers an offense for bad indentation in a module body' do
      inspect_source(cop, <<-END.strip_indent)
        module Test
            def func1
            end
             def func2
             end
        end
      END
      expect(cop.messages).to eq(['Inconsistent indentation detected.'])
    end

    it 'accepts an empty module body' do
      inspect_source(cop, <<-END.strip_indent)
        module Test
        end
      END
      expect(cop.offenses).to be_empty
    end
  end

  context 'with block' do
    it 'registers an offense for bad indentation in a do/end body' do
      inspect_source(cop, <<-END.strip_indent)
        a = func do
         b
          c
        end
      END
      expect(cop.messages).to eq(['Inconsistent indentation detected.'])
    end

    it 'registers an offense for bad indentation in a {} body' do
      inspect_source(cop, <<-END.strip_indent)
        func {
           b
          c
        }
      END
      expect(cop.messages).to eq(['Inconsistent indentation detected.'])
    end

    it 'accepts a correctly indented block body' do
      inspect_source(cop, <<-END.strip_indent)
        a = func do
          b
          c
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

    it 'does not auto-correct an offense within another offense' do
      corrected = autocorrect_source(cop, <<-END.strip_indent)
        require 'spec_helper'
        describe ArticlesController do
          render_views
            describe "GET \'index\'" do
                    it "returns success" do
                    end
                describe "admin user" do
                     before(:each) do
                    end
                end
            end
        end
      END
      expect(cop.offenses.map(&:line)).to eq [4, 7] # Two offenses are found.

      # The offense on line 4 is corrected, affecting lines 4 to 11.
      expect(corrected).to eq <<-END.strip_indent
        require 'spec_helper'
        describe ArticlesController do
          render_views
          describe \"GET 'index'\" do
                  it "returns success" do
                  end
              describe "admin user" do
                   before(:each) do
                  end
              end
          end
        end
      END
    end
  end
end
