# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::OutOfRangeRegexpRef, :config do
  it 'registers an offense when references are used before any regexp' do
    expect_offense(<<~RUBY)
      puts $3
           ^^ $3 is out of range (no regexp capture groups detected).
    RUBY
  end

  it 'registers an offense when out of range references are used for named captures' do
    expect_offense(<<~RUBY)
      /(?<foo>FOO)(?<bar>BAR)/ =~ "FOOBAR"
      puts $3
           ^^ $3 is out of range (2 regexp capture groups detected).
    RUBY
  end

  it 'registers an offense when out of range references are used for numbered captures' do
    expect_offense(<<~RUBY)
      /(foo)(bar)/ =~ "foobar"
      puts $3
           ^^ $3 is out of range (2 regexp capture groups detected).
    RUBY
  end

  it 'registers an offense when out of range references are used for mix of numbered and named captures' do
    expect_offense(<<~RUBY)
      /(?<foo>FOO)(BAR)/ =~ "FOOBAR"
      puts $2
           ^^ $2 is out of range (1 regexp capture group detected).
    RUBY
  end

  it 'registers an offense when out of range references are used for non captures' do
    expect_offense(<<~RUBY)
      /bar/ =~ 'foo'
      puts $1
           ^^ $1 is out of range (no regexp capture groups detected).
    RUBY
  end

  it 'does not register offense to a regexp with valid references for named captures' do
    expect_no_offenses(<<~RUBY)
      /(?<foo>FOO)(?<bar>BAR)/ =~ "FOOBAR"
      puts $1
      puts $2
    RUBY
  end

  it 'does not register offense to a regexp with valid references for numbered captures' do
    expect_no_offenses(<<~RUBY)
      /(foo)(bar)/ =~ "foobar"
      puts $1
      puts $2
    RUBY
  end

  it 'does not register offense to a regexp with valid references for a mix named and numbered captures' do
    expect_no_offenses(<<~RUBY)
      /(?<foo>FOO)(BAR)/ =~ "FOOBAR"
      puts $1
    RUBY
  end

  it 'does not register offense to a regexp with encoding option and valid references for numbered captures' do
    expect_no_offenses(<<~RUBY)
      /(foo)(bar)/u =~ "foobar"
      puts $1
      puts $2
    RUBY
  end

  # RuboCop does not know a value of variables that it will contain in the regexp literal.
  # For example, `/(?<foo>#{var}*)` is interpreted as `/(?<foo>*)`.
  # So it does not offense when variables are used in regexp literals.
  it 'does not register an offense regexp containing non literal' do
    expect_no_offenses(<<~'RUBY')
      var = '(\d+)'
      /(?<foo>#{var}*)/ =~ "12"
      puts $1
      puts $2
    RUBY
  end

  it 'registers an offense when the regexp appears on the right hand side of `=~`' do
    expect_offense(<<~RUBY)
      "foobar" =~ /(foo)(bar)/
      puts $3
           ^^ $3 is out of range (2 regexp capture groups detected).
    RUBY
  end

  it 'registers an offense when the regexp is matched with `===`' do
    expect_offense(<<~RUBY)
      /(foo)(bar)/ === "foobar"
      puts $3
           ^^ $3 is out of range (2 regexp capture groups detected).
    RUBY
  end

  it 'registers an offense when the regexp is matched with `match`' do
    expect_offense(<<~RUBY)
      /(foo)(bar)/.match("foobar")
      puts $3
           ^^ $3 is out of range (2 regexp capture groups detected).
    RUBY
  end

  it 'ignores calls to `match?`' do
    expect_offense(<<~RUBY)
      /(foo)(bar)/.match("foobar")
      /(foo)(bar)(baz)/.match?("foobarbaz")
      puts $3
           ^^ $3 is out of range (2 regexp capture groups detected).
    RUBY
  end

  it 'ignores `match` with no arguments' do
    expect_no_offenses(<<~RUBY)
      foo.match
    RUBY
  end

  it 'ignores `match` with no receiver' do
    expect_no_offenses(<<~RUBY)
      match(bar)
    RUBY
  end

  it 'only registers an offense when the regexp is matched as a literal' do
    expect_no_offenses(<<~RUBY)
      foo_bar_regexp = /(foo)(bar)/
      foo_regexp = /(foo)/

      foo_bar_regexp =~ 'foobar'
      puts $2
    RUBY
  end

  it 'does not register an offense when in range references are used inside a when clause' do
    expect_no_offenses(<<~RUBY)
      case "foobar"
      when /(foo)(bar)/
        $2
      end
    RUBY
  end

  it 'registers an offense when out of range references are used inside a when clause' do
    expect_offense(<<~RUBY)
      case "foobar"
      when /(foo)(bar)/
        $3
        ^^ $3 is out of range (2 regexp capture groups detected).
      end
    RUBY
  end

  it 'uses the maximum number of captures for when clauses with multiple conditions' do
    expect_no_offenses(<<~RUBY)
      case "foobarbaz"
      when /(foo)(bar)/, /(bar)baz/
        $2
      end
    RUBY

    expect_offense(<<~RUBY)
      case "foobarbaz"
      when /(foo)(bar)/, /(bar)baz/
        $3
        ^^ $3 is out of range (2 regexp capture groups detected).
      end
    RUBY
  end

  it 'only registers an offense for when clauses when the regexp is matched as a literal' do
    expect_no_offenses(<<~RUBY)
      case some_string
      when some_regexp
        $2
      end
    RUBY
  end

  it 'ignores regexp when clause conditions that contain interpolations' do
    expect_offense(<<~'RUBY')
      case "foobarbaz"
      when /(foo)(bar)/, /#{var}/
        $3
        ^^ $3 is out of range (2 regexp capture groups detected).
      end
    RUBY
  end

  context 'pattern matching', :ruby27 do
    context 'matching variable' do
      it 'does not register an offense when in range references are used' do
        expect_no_offenses(<<~RUBY)
          case "foobar"
          in /(foo)(bar)/
            $2
          end
        RUBY
      end

      it 'registers an offense when out of range references are used' do
        expect_offense(<<~RUBY)
          case "foobar"
          in /(foo)(bar)/
            $3
            ^^ $3 is out of range (2 regexp capture groups detected).
          end
        RUBY
      end
    end

    context 'matching arrays' do
      it 'uses the maximum number of captures with multiple patterns' do
        expect_no_offenses(<<~RUBY)
          case array
          in [/(foo)(bar)/, /(bar)baz/]
            $2
          end
        RUBY

        expect_offense(<<~RUBY)
          case array
          in [/(foo)(bar)/, /(bar)baz/]
            $3
            ^^ $3 is out of range (2 regexp capture groups detected).
          end
        RUBY
      end
    end

    context 'matching hashes' do
      it 'does not register an offense when in range references are used' do
        expect_no_offenses(<<~RUBY)
          case hash
          in a: /(foo)(bar)/
            $2
          end
        RUBY
      end

      it 'registers an offense when out of range references are used' do
        expect_offense(<<~RUBY)
          case hash
          in a: /(foo)(bar)/, b: /(bar)baz/
            $3
            ^^ $3 is out of range (2 regexp capture groups detected).
          end
        RUBY
      end
    end

    context 'matching pins' do
      it 'does not register an offense when in range references are used' do
        expect_no_offenses(<<~RUBY)
          a = 1
          case array
          in [^a, /(foo)(bar)/]
            $2
          end
        RUBY
      end

      it 'registers an offense when out of range references are used' do
        expect_offense(<<~RUBY)
          a = 1
          case array
          in [^a, /(foo)(bar)/, /(foo)bar/]
            $3
            ^^ $3 is out of range (2 regexp capture groups detected).
          end
        RUBY
      end
    end

    context 'matching with aliases' do
      context 'variable aliases' do
        it 'does not register an offense when in range references are used' do
          expect_no_offenses(<<~RUBY)
            case "foobar"
            in /(foo)(bar)/ => x
              $2
            end
          RUBY
        end

        it 'registers an offense when out of range references are used' do
          expect_offense(<<~RUBY)
            case "foobar"
            in /(foo)(bar)/ => x
              $3
              ^^ $3 is out of range (2 regexp capture groups detected).
            end
          RUBY
        end
      end

      context 'array aliases' do
        it 'uses the maximum number of captures with multiple patterns' do
          expect_no_offenses(<<~RUBY)
            case array
            in [/(foo)(bar)/, /(bar)baz/] => x
              $2
            end
          RUBY

          expect_offense(<<~RUBY)
            case array
            in [/(foo)(bar)/, /(bar)baz/] => x
              $3
              ^^ $3 is out of range (2 regexp capture groups detected).
            end
          RUBY
        end
      end
    end

    context 'matching alternatives' do
      it 'does not register an offense when in range references are used' do
        expect_no_offenses(<<~RUBY)
          case "foobar"
          in /(foo)(bar)/ | "foo"
            $2
          end
        RUBY

        expect_no_offenses(<<~RUBY)
          case "foobar"
          in /(foo)(bar)/ | "foo" => x
            $2
          end
        RUBY
      end

      it 'registers an offense when out of range references are used' do
        expect_offense(<<~RUBY)
          case "foobar"
          in /(foo)(bar)/ | "foo"
            $3
            ^^ $3 is out of range (2 regexp capture groups detected).
          end
        RUBY
      end

      it 'uses the maximum number of captures with multiple patterns' do
        expect_no_offenses(<<~RUBY)
          case "foobar"
          in /(foo)baz/ | /(foo)(bar)/
            $2
          end
        RUBY

        expect_offense(<<~RUBY)
          case "foobar"
          in /(foo)baz/ | /(foo)(bar)/
            $3
            ^^ $3 is out of range (2 regexp capture groups detected).
          end
        RUBY
      end
    end

    it 'only registers an offense when the regexp is matched as a literal' do
      expect_no_offenses(<<~RUBY)
        case some_string
        in some_regexp
          $2
        end
      RUBY
    end

    it 'ignores regexp when clause conditions contain interpolations' do
      expect_offense(<<~'RUBY')
        case array
        in [/(foo)(bar)/, /#{var}/]
          $3
          ^^ $3 is out of range (2 regexp capture groups detected).
        end
      RUBY
    end
  end

  context 'matching with `grep`' do
    it 'does not register an offense when in range references are used' do
      expect_no_offenses(<<~RUBY)
        %w[foo foobar].grep(/(foo)/) { $1 }
      RUBY
    end

    it 'registers an offense when out of range references are used' do
      expect_offense(<<~RUBY)
        %w[foo foobar].grep(/(foo)/) { $2 }
                                       ^^ $2 is out of range (1 regexp capture group detected).
      RUBY
    end

    it 'only registers an offense when the regexp is matched as a literal' do
      expect_no_offenses(<<~RUBY)
        %w[foo foobar].grep(some_regexp) { $2 }
      RUBY
    end
  end

  context 'matching with `[]`' do
    it 'does not register an offense when in range references are used' do
      expect_no_offenses(<<~RUBY)
        "foobar"[/(foo)(bar)/]
        puts $2
      RUBY
    end

    it 'registers an offense when out of range references are used' do
      expect_offense(<<~RUBY)
        "foobar"[/(foo)(bar)/]
        puts $3
             ^^ $3 is out of range (2 regexp capture groups detected).
      RUBY
    end

    it 'only registers an offense when the regexp is matched as a literal' do
      expect_no_offenses(<<~RUBY)
        "foobar"[some_regexp]
        puts $3
      RUBY
    end
  end

  context 'when both the LHS and RHS use regexp' do
    it 'only considers the RHS regexp' do
      expect_no_offenses(<<~RUBY)
        if "foo bar".gsub(/\s+/, "") =~ /foo(bar)/
          p $1
        end
      RUBY

      expect_offense(<<~RUBY)
        if "foo bar".gsub(/(\s+)/, "") =~ /foobar/
          p $1
            ^^ $1 is out of range (no regexp capture groups detected).
        end
      RUBY
    end
  end

  context 'when calling a regexp method on a nth-ref node' do
    it 'does not register an offense when calling gsub on a valid nth-ref' do
      expect_no_offenses(<<~RUBY)
        if "some : line " =~ / : (.+)/
          $1.gsub(/\s{2}/, " ")
        end
      RUBY
    end

    it 'registers an offense when calling gsub on an invalid nth-ref' do
      expect_offense(<<~RUBY)
        if "some : line " =~ / : (.+)/
          $2.gsub(/\s{2}/, " ")
          ^^ $2 is out of range (1 regexp capture group detected).
        end
      RUBY
    end

    it 'registers an offense if the capturing groups have changed' do
      expect_offense(<<~RUBY)
        "some : line " =~ / : (.+)/
        $1.gsub(/\s{2}/, " ")
        puts $1
             ^^ $1 is out of range (no regexp capture groups detected).
      RUBY
    end
  end

  %i[gsub gsub! sub sub! scan].each do |method|
    context "matching with #{method}" do
      it 'does not register an offense when in range references are used' do
        expect_no_offenses(<<~RUBY)
          "foobar".#{method}(/(foo)(bar)/) { $2 }
        RUBY
      end

      it 'registers an offense when out of range references are used' do
        expect_offense(<<~RUBY, method: method)
          "foobar".%{method}(/(foo)(bar)/) { $3 }
                   _{method}                 ^^ $3 is out of range (2 regexp capture groups detected).
        RUBY
      end

      it 'only registers an offense when the regexp is matched as a literal' do
        expect_no_offenses(<<~RUBY)
          some_string.#{method}(some_regexp) { $3 }
        RUBY
      end
    end
  end

  %i[match slice slice! index rindex partition rpartition start_with? end_with?].each do |method|
    context "matching with #{method}" do
      it 'does not register an offense when in range references are used' do
        expect_no_offenses(<<~RUBY)
          "foobar".#{method}(/(foo)(bar)/)
          puts $2
        RUBY
      end

      it 'registers an offense when out of range references are used' do
        expect_offense(<<~RUBY)
          "foobar".#{method}(/(foo)(bar)/)
          puts $3
               ^^ $3 is out of range (2 regexp capture groups detected).
        RUBY
      end

      it 'only registers an offense when the regexp is matched as a literal' do
        expect_no_offenses(<<~RUBY)
          "foobar".#{method}(some_regexp)
          puts $3
        RUBY
      end
    end
  end
end
