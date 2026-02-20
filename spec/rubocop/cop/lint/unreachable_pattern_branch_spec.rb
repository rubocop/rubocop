# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::UnreachablePatternBranch, :config, :ruby27 do
  it 'registers an offense for `in` branch after bare variable catch-all' do
    expect_offense(<<~RUBY)
      case value
      in x
        handle_other
      in Integer
      ^^^^^^^^^^ Unreachable `in` pattern branch detected.
        handle_integer
      end
    RUBY
  end

  it 'registers an offense for `in` branch after underscore catch-all' do
    expect_offense(<<~RUBY)
      case value
      in _
        handle_other
      in Integer
      ^^^^^^^^^^ Unreachable `in` pattern branch detected.
        handle_integer
      end
    RUBY
  end

  it 'registers offenses for multiple `in` branches after catch-all' do
    expect_offense(<<~RUBY)
      case value
      in Integer
        handle_integer
      in x
        handle_other
      in String
      ^^^^^^^^^ Unreachable `in` pattern branch detected.
        handle_string
      in Symbol
      ^^^^^^^^^ Unreachable `in` pattern branch detected.
        handle_symbol
      end
    RUBY
  end

  context 'when catch-all is followed by else' do
    it 'registers an offense for unreachable else branch' do
      expect_offense(<<~RUBY)
        case value
        in Integer
          handle_integer
        in _
          handle_other
        else
        ^^^^ Unreachable `else` branch detected.
          handle_else
        end
      RUBY
    end

    it 'registers offenses for both unreachable `in` and `else` branches' do
      expect_offense(<<~RUBY)
        case value
        in x
          handle_other
        in Integer
        ^^^^^^^^^^ Unreachable `in` pattern branch detected.
          handle_integer
        else
        ^^^^ Unreachable `else` branch detected.
          handle_else
        end
      RUBY
    end

    it 'registers an offense for a single catch-all with else' do
      expect_offense(<<~RUBY)
        case value
        in x
          handle_any
        else
        ^^^^ Unreachable `else` branch detected.
          handle_else
        end
      RUBY
    end
  end

  context 'with match_as patterns' do
    it 'registers an offense when catch-all uses pattern alias with underscore' do
      expect_offense(<<~RUBY)
        case value
        in _ => y
          handle_other
        in Integer
        ^^^^^^^^^^ Unreachable `in` pattern branch detected.
          handle_integer
        end
      RUBY
    end

    it 'registers an offense when catch-all uses pattern alias with variable' do
      expect_offense(<<~RUBY)
        case value
        in x => y
          handle_other
        in Integer
        ^^^^^^^^^^ Unreachable `in` pattern branch detected.
          handle_integer
        end
      RUBY
    end

    it 'does not register an offense for match_as wrapping non-catch-all' do
      expect_no_offenses(<<~RUBY)
        case value
        in Integer => y
          handle_integer
        in String
          handle_string
        end
      RUBY
    end
  end

  context 'with match_alt patterns' do
    it 'registers an offense when alternation includes a catch-all on the left' do
      expect_offense(<<~RUBY)
        case value
        in _ | Integer
          handle_other
        in String
        ^^^^^^^^^ Unreachable `in` pattern branch detected.
          handle_string
        end
      RUBY
    end

    it 'registers an offense when alternation has catch-all on the right' do
      expect_offense(<<~RUBY)
        case value
        in Integer | _
          handle_other
        in String
        ^^^^^^^^^ Unreachable `in` pattern branch detected.
          handle_string
        end
      RUBY
    end

    it 'does not register an offense for alternation of non-catch-all patterns' do
      expect_no_offenses(<<~RUBY)
        case value
        in Integer | String
          handle_int_or_string
        in Symbol
          handle_symbol
        end
      RUBY
    end
  end

  context 'with guard clauses' do
    it 'does not register an offense when catch-all has an if guard' do
      expect_no_offenses(<<~RUBY)
        case value
        in x if x.positive?
          handle_positive
        in Integer
          handle_integer
        end
      RUBY
    end

    it 'does not register an offense when catch-all has an unless guard' do
      expect_no_offenses(<<~RUBY)
        case value
        in x unless x.nil?
          handle_not_nil
        in Integer
          handle_integer
        end
      RUBY
    end

    it 'registers an offense for branch after unguarded catch-all even with guarded catch-all before it' do
      expect_offense(<<~RUBY)
        case value
        in x if x.positive?
          handle_positive
        in y
          handle_other
        in Integer
        ^^^^^^^^^^ Unreachable `in` pattern branch detected.
          handle_integer
        end
      RUBY
    end
  end

  context 'with non-catch-all patterns' do
    it 'does not register an offense for only specific patterns' do
      expect_no_offenses(<<~RUBY)
        case value
        in Integer
          handle_integer
        in String
          handle_string
        else
          handle_other
        end
      RUBY
    end

    it 'does not register an offense when catch-all is the last branch' do
      expect_no_offenses(<<~RUBY)
        case value
        in Integer
          handle_integer
        in String
          handle_string
        in x
          handle_other
        end
      RUBY
    end

    it 'does not register an offense for array pattern' do
      expect_no_offenses(<<~RUBY)
        case value
        in [*]
          handle_array
        in Integer
          handle_integer
        end
      RUBY
    end

    it 'does not register an offense for hash pattern' do
      expect_no_offenses(<<~RUBY)
        case value
        in **rest
          handle_hash
        in Integer
          handle_integer
        end
      RUBY
    end

    it 'does not register an offense for literal patterns' do
      expect_no_offenses(<<~RUBY)
        case value
        in 1
          handle_one
        in 2
          handle_two
        end
      RUBY
    end

    it 'does not register an offense for find pattern', :ruby30 do
      expect_no_offenses(<<~RUBY)
        case value
        in [*, 1, *]
          handle_contains_one
        in Integer
          handle_integer
        end
      RUBY
    end
  end

  context 'with edge cases' do
    it 'does not register an offense for a single in branch' do
      expect_no_offenses(<<~RUBY)
        case value
        in x
          handle_any
        end
      RUBY
    end

    it 'registers an offense for match_as wrapping a match_alt with catch-all' do
      expect_offense(<<~RUBY)
        case value
        in (_ | Integer) => y
          handle_other
        in String
        ^^^^^^^^^ Unreachable `in` pattern branch detected.
          handle_string
        end
      RUBY
    end
  end
end
