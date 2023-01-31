# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::ElseAlignment, :config do
  let(:config) { RuboCop::Config.new('Layout/EndAlignment' => end_alignment_config) }
  let(:end_alignment_config) { { 'Enabled' => true, 'EnforcedStyleAlignWith' => 'variable' } }

  it 'accepts a ternary if' do
    expect_no_offenses('cond ? func1 : func2')
  end

  context 'with if statement' do
    it 'registers an offense for misaligned else' do
      expect_offense(<<~RUBY)
        if cond
          func1
         else
         ^^^^ Align `else` with `if`.
         func2
        end
      RUBY

      expect_correction(<<~RUBY)
        if cond
          func1
        else
         func2
        end
      RUBY
    end

    it 'registers an offense for misaligned elsif' do
      expect_offense(<<-RUBY.strip_margin('|'))
      |    if a1
      |      b1
      |  elsif a2
      |  ^^^^^ Align `elsif` with `if`.
      |      b2
      |    end
      RUBY

      expect_correction(<<-RUBY.strip_margin('|'))
      |    if a1
      |      b1
      |    elsif a2
      |      b2
      |    end
      RUBY
    end

    it 'accepts indentation after else when if is on new line after assignment' do
      expect_no_offenses(<<~RUBY)
        Rails.application.config.ideal_postcodes_key =
          if Rails.env.production? || Rails.env.staging?
            "AAAA-AAAA-AAAA-AAAA"
          else
            "BBBB-BBBB-BBBB-BBBB"
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

    context 'for a file with byte order mark' do
      let(:bom) { "\xef\xbb\xbf" }

      it 'accepts a correctly aligned if/elsif/else/end' do
        expect_no_offenses(<<~RUBY)
          #{bom}if a1
            b1
          elsif a2
            b2
          else
            c
          end
        RUBY
      end
    end

    context 'with assignment' do
      context 'when alignment style is variable' do
        context 'and end is aligned with variable' do
          it 'accepts an if-else with end aligned with setter' do
            expect_no_offenses(<<~RUBY)
              foo.bar = if baz
                derp1
              else
                derp2
              end
            RUBY
          end

          it 'accepts an if-elsif-else with end aligned with setter' do
            expect_no_offenses(<<~RUBY)
              foo.bar = if baz
                derp1
              elsif meh
                derp2
              else
                derp3
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
          it 'registers offenses for an if with setter' do
            expect_offense(<<~RUBY)
              foo.bar = if baz
                          derp1
                        elsif meh
                        ^^^^^ Align `elsif` with `foo.bar`.
                          derp2
                        else
                        ^^^^ Align `else` with `foo.bar`.
                          derp3
                        end
            RUBY
          end

          it 'registers an offense for an if with element assignment' do
            expect_offense(<<~RUBY)
              foo[bar] = if baz
                           derp1
                         else
                         ^^^^ Align `else` with `foo[bar]`.
                           derp2
                         end
            RUBY
          end

          it 'registers an offense for an if' do
            expect_offense(<<~RUBY)
              var = if a
                      0
                    else
                    ^^^^ Align `else` with `var`.
                      1
                    end
            RUBY
          end
        end
      end

      shared_examples 'assignment and if with keyword alignment' do
        context 'and end is aligned with variable' do
          it 'registers an offense for an if' do
            expect_offense(<<~RUBY)
              var = if a
                0
              elsif b
              ^^^^^ Align `elsif` with `if`.
                1
              end
            RUBY

            expect_correction(<<~RUBY)
              var = if a
                0
                    elsif b
                1
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
    it 'registers an offense for misaligned else' do
      expect_offense(<<~RUBY)
        unless cond
           func1
         else
         ^^^^ Align `else` with `unless`.
           func2
        end
      RUBY
    end

    it 'accepts a correctly aligned else in an otherwise empty unless' do
      expect_no_offenses(<<~RUBY)
        unless a
        else
        end
      RUBY
    end

    it 'accepts an empty unless' do
      expect_no_offenses(<<~RUBY)
        unless a
        end
      RUBY
    end
  end

  context 'with case' do
    it 'registers an offense for misaligned else' do
      expect_offense(<<~RUBY)
        case a
        when b
          c
        when d
          e
         else
         ^^^^ Align `else` with `when`.
          f
        end
      RUBY
    end

    it 'accepts correctly aligned case/when/else' do
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

    it 'accepts case without else' do
      expect_no_offenses(<<~'RUBY')
        case superclass
        when /\A(#{NAMESPACEMATCH})(?:\s|\Z)/
          $1
        when "self"
          namespace.path
        end
      RUBY
    end

    context '>= Ruby 2.7', :ruby27 do
      context 'with case match' do
        it 'registers an offense for misaligned else' do
          expect_offense(<<~RUBY)
            case 0
            in 0
              foo
            in -1..1
              bar
            in Integer
              baz
             else
             ^^^^ Align `else` with `in`.
              qux
            end
          RUBY
        end

        it 'accepts correctly aligned case/when/else' do
          expect_no_offenses(<<~RUBY)
            case 0
            in 0
              foo
            in -1..1
              bar
            in Integer
              baz
            else
              qux
            end
          RUBY
        end

        it 'accepts correctly aligned empty else' do
          expect_no_offenses(<<~RUBY)
            case 0
            in 0
              foo
            in -1..1
              bar
            in Integer
              baz
            else
            end
          RUBY
        end

        it 'accepts case match without else' do
          expect_no_offenses(<<~RUBY)
            case 0
            in a
              p a
            end
          RUBY
        end
      end
    end

    it 'accepts else aligned with when but not with case' do
      # "Indent when as deep as case" is the job of another cop, and this is
      # one of the possible styles supported by configuration.
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

  context 'with def/defs' do
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

    context 'when modifier and def are on the same line' do
      it 'accepts a correctly aligned body' do
        expect_no_offenses(<<~RUBY)
          private def test
            something
          rescue
            handling
          else
            something_else
          end
        RUBY
      end

      it 'registers an offense for else not aligned with private' do
        expect_offense(<<~RUBY)
          private def test
                    something
                  rescue
                    handling
                  else
                  ^^^^ Align `else` with `private`.
                    something_else
                  end
        RUBY
      end
    end
  end

  context 'with begin/rescue/else/ensure/end' do
    it 'registers an offense for misaligned else' do
      expect_offense(<<~RUBY)
        def my_func
          puts 'do something outside block'
          begin
            puts 'do something error prone'
          rescue SomeException, SomeOther => e
            puts 'wrongly intended error handling'
          rescue
            puts 'wrongly intended error handling'
        else
        ^^^^ Align `else` with `begin`.
            puts 'wrongly intended normal case handling'
          ensure
            puts 'wrongly intended common handling'
          end
        end
      RUBY
    end

    it 'accepts a correctly aligned else' do
      expect_no_offenses(<<~RUBY)
        begin
          raise StandardError.new('Fail') if rand(2).odd?
        rescue StandardError => error
          $stderr.puts error.message
        else
          $stdout.puts 'Lucky you!'
        end
      RUBY
    end
  end

  context 'with def/rescue/else/ensure/end' do
    it 'accepts a correctly aligned else' do
      expect_no_offenses(<<~RUBY)
        def my_func(string)
          puts string
        rescue => e
          puts e
        else
          puts e
        ensure
          puts 'I love methods that print'
        end
      RUBY
    end

    it 'registers an offense for misaligned else' do
      expect_offense(<<~RUBY)
        def my_func(string)
          puts string
        rescue => e
          puts e
          else
          ^^^^ Align `else` with `def`.
          puts e
        ensure
          puts 'I love methods that print'
        end
      RUBY
    end
  end

  context 'with def/rescue/else/end' do
    it 'accepts a correctly aligned else' do
      expect_no_offenses(<<~RUBY)
        def my_func
          puts 'do something error prone'
        rescue SomeException
          puts 'error handling'
        rescue
          puts 'error handling'
        else
          puts 'normal handling'
        end
      RUBY
    end

    it 'registers an offense for misaligned else' do
      expect_offense(<<~RUBY)
        def my_func
          puts 'do something error prone'
        rescue SomeException
          puts 'error handling'
        rescue
          puts 'error handling'
          else
          ^^^^ Align `else` with `def`.
          puts 'normal handling'
        end
      RUBY
    end
  end

  context 'ensure/rescue/else in Block Argument' do
    it 'accepts a correctly aligned else' do
      expect_no_offenses(<<~RUBY)
        array_like.each do |n|
          puts 'do something error prone'
        rescue SomeException
          puts 'error handling'
        rescue
          puts 'error handling'
        else
          puts 'normal handling'
        end
      RUBY
    end

    it 'accepts a correctly aligned else with assignment' do
      expect_no_offenses(<<~RUBY)
        result = array_like.each do |n|
          puts 'do something error prone'
        rescue SomeException
          puts 'error handling'
        rescue
          puts 'error handling'
        else
          puts 'normal handling'
        end
      RUBY
    end

    it 'registers an offense for misaligned else' do
      expect_offense(<<~RUBY)
        array_like.each do |n|
          puts 'do something error prone'
        rescue SomeException
          puts 'error handling'
        rescue
          puts 'error handling'
          else
          ^^^^ Align `else` with `array_like.each`.
          puts 'normal handling'
        end
      RUBY
    end
  end
end
