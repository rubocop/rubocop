# frozen_string_literal: true

describe RuboCop::Cop::Style::TrailingUnderscoreVariable do
  subject(:cop) { described_class.new(config) }

  shared_examples 'common functionality' do
    it 'registers an offense when the last variable of parallel assignment ' \
       'is an underscore' do
      expect_offense(<<-RUBY.strip_indent)
        a, b, _ = foo()
              ^^ Do not use trailing `_`s in parallel assignment. Prefer `a, b, = foo()`.
      RUBY
    end

    it 'registers an offense when multiple underscores are used '\
       'as the last variables of parallel assignment ' do
      expect_offense(<<-RUBY.strip_indent)
        a, _, _ = foo()
           ^^^^^ Do not use trailing `_`s in parallel assignment. Prefer `a, = foo()`.
      RUBY
    end

    it 'registers an offense for splat underscore as the last variable' do
      expect_offense(<<-RUBY.strip_indent)
        a, *_ = foo()
           ^^^ Do not use trailing `_`s in parallel assignment. Prefer `a, = foo()`.
      RUBY
    end

    it 'registers an offense when underscore is the second to last variable ' \
       'and blank is the last variable' do
      expect_offense(<<-RUBY.strip_indent)
        a, _, = foo()
           ^^^ Do not use trailing `_`s in parallel assignment. Prefer `a, = foo()`.
      RUBY
    end

    it 'registers an offense when underscore is the only variable ' \
       'in parallel assignment' do
      expect_offense(<<-RUBY.strip_indent)
        _, = foo()
        ^^^^^ Do not use trailing `_`s in parallel assignment. Prefer `foo()`.
      RUBY
    end

    it 'registers an offense for an underscore as the last param ' \
       'when there is also an underscore as the first param' do
      expect_offense(<<-RUBY.strip_indent)
        _, b, _ = foo()
              ^^ Do not use trailing `_`s in parallel assignment. Prefer `_, b, = foo()`.
      RUBY
    end

    it 'does not register an offense when there are no underscores' do
      expect_no_offenses('a, b, c = foo()')
    end

    it 'does not register an offense for underscores at the beginning' do
      expect_no_offenses('_, a, b = foo()')
    end

    it 'does not register an offense for an underscore preceded by a ' \
       'splat variable anywhere in the argument chain' do
      expect_no_offenses('*a, b, _ = foo()')
    end

    it 'does not register an offense for an underscore preceded by a ' \
       'splat variable' do
      expect_no_offenses('a, *b, _ = foo()')
    end

    it 'does not register an offense for an underscore preceded by a ' \
       'splat variable and another underscore' do
      expect_no_offenses('_, *b, _ = *foo')
    end

    it 'does not register an offense for multiple underscores preceded by a ' \
       'splat variable' do
      expect_no_offenses('a, *b, _, _ = foo()')
    end

    it 'does not register an offense for multiple named underscores ' \
       'preceded by a splat variable' do
      expect_no_offenses('a, *b, _c, _d = foo()')
    end

    it 'registers an offense for multiple underscore variables preceded by ' \
       'a splat underscore variable' do
      expect_offense(<<-RUBY.strip_indent)
        a, *_, _, _ = foo()
           ^^^^^^^^^ Do not use trailing `_`s in parallel assignment. Prefer `a, = foo()`.
      RUBY
    end

    it 'registers an offense for nested assignments with trailing ' \
      'underscores' do
      expect_offense(<<-RUBY.strip_indent)
        a, (b, _) = foo()
              ^^ Do not use trailing `_`s in parallel assignment. Prefer `a, (b,) = foo()`.
      RUBY
    end

    it 'registers an offense for complex nested assignments with trailing ' \
      'underscores' do
      expect_offense(<<-RUBY.strip_indent)
        a, (_, (b, _), *_) = foo()
                  ^^ Do not use trailing `_`s in parallel assignment. Prefer `a, (_, (b,), *_) = foo()`.
                      ^^^ Do not use trailing `_`s in parallel assignment. Prefer `a, (_, (b, _),) = foo()`.
      RUBY
    end

    it 'does not register an offense for a named underscore variable ' \
       'preceded by a splat variable' do
      expect_no_offenses('a, *b, _c = foo()')
    end

    it 'does not register an offense for a named variable preceded by a ' \
       'names splat underscore variable' do
      expect_no_offenses('a, *b, _c = foo()')
    end

    it 'does not register an offense for nested assignments without ' \
      'trailing underscores' do
      expect_no_offenses('a, (_, b) = foo()')
    end

    it 'does not register an offense for complex nested assignments without ' \
      'trailing underscores' do
      expect_no_offenses('a, (_, (b,), c, (d, e),) = foo()')
    end

    describe 'autocorrect' do
      it 'removes trailing underscores automatically' do
        new_source = autocorrect_source('a, b, _ = foo()')

        expect(new_source).to eq('a, b, = foo()')
      end

      it 'removes trailing underscores and commas' do
        new_source = autocorrect_source('a, b, _, = foo()')

        expect(new_source).to eq('a, b, = foo()')
      end

      it 'removes multiple trailing underscores' do
        new_source = autocorrect_source('a, _, _ = foo()')

        expect(new_source).to eq('a, = foo()')
      end

      it 'removes trailing underscores and commas and preserves assignments' do
        new_source = autocorrect_source('a, _, _, = foo()')

        expect(new_source).to eq('a, = foo()')
      end

      it 'removes trailing comma when it is the only variable' do
        new_source = autocorrect_source('_, = foo()')

        expect(new_source).to eq('foo()')
      end

      it 'removes all assignments when every assignment is to `_`' do
        new_source = autocorrect_source('_, _, _, = foo()')

        expect(new_source).to eq('foo()')
      end

      it 'remove splat underscore' do
        new_source = autocorrect_source('a, *_ = foo()')

        expect(new_source).to eq('a, = foo()')
      end

      it 'removes underscores inside nested assignments' do
        new_source = autocorrect_source('a, (b, _) = foo()')

        expect(new_source).to eq('a, (b,) = foo()')
      end

      it 'removes trailing underscores inside complex nested assignments ' do
        new_source = autocorrect_source('a, (_, (b, _), *_) = foo()')

        expect(new_source).to eq('a, (_, (b,),) = foo()')
      end

      context 'with parentheses' do
        it 'leaves parentheses but removes trailing underscores' do
          new_source = autocorrect_source('(a, b, _) = foo()')

          expect(new_source).to eq('(a, b,) = foo()')
        end

        it 'removes assignment part when every assignment is to `_`' do
          new_source = autocorrect_source('(_, _, _,) = foo()')

          expect(new_source).to eq('foo()')
        end

        it 'removes assignment part when it is the only variable' do
          new_source = autocorrect_source('(_,) = foo()')

          expect(new_source).to eq('foo()')
        end

        it 'leaves parentheses but removes trailing underscores and commas' do
          new_source = autocorrect_source('(a, _, _,) = foo()')

          expect(new_source).to eq('(a,) = foo()')
        end
      end
    end
  end

  context 'configured to allow named underscore variables' do
    let(:config) do
      RuboCop::Config.new(
        'Style/TrailingUnderscoreVariable' => {
          'Enabled' => true,
          'AllowNamedUnderscoreVariables' => true
        }
      )
    end

    include_examples 'common functionality'

    it 'does not register an offense for an underscore variable preceded ' \
       'by a named splat underscore variable' do
      expect_no_offenses('a, *_b, _ = foo()')
    end

    it 'does not register an offense for named variables ' \
       'that start with an underscore' do
      expect_no_offenses('a, b, _c = foo()')
    end

    it 'does not register an offense for a named splat underscore ' \
       'as the last variable' do
      expect_no_offenses('a, *_b = foo()')
    end

    it 'does not register an offense for an underscore preceded by ' \
       'a named splat underscore' do
      expect_no_offenses('a, *_b, _ = foo()')
    end

    it 'does not register an offense for multiple underscore variables ' \
       'preceded by a named splat underscore variable' do
      expect_no_offenses('a, *_b, _, _ = foo()')
    end
  end

  context 'configured to not allow named underscore variables' do
    let(:config) do
      RuboCop::Config.new(
        'Style/TrailingUnderscoreVariable' => {
          'Enabled' => true,
          'AllowNamedUnderscoreVariables' => false
        }
      )
    end

    include_examples 'common functionality'

    it 'registers an offense for named variables ' \
       'that start with an underscore' do
      expect_offense(<<-RUBY.strip_indent)
        a, b, _c = foo()
              ^^^ Do not use trailing `_`s in parallel assignment. Prefer `a, b, = foo()`.
      RUBY
    end

    it 'registers an offense for a named splat underscore ' \
       'as the last variable' do
      expect_offense(<<-RUBY.strip_indent)
        a, *_b = foo()
           ^^^^ Do not use trailing `_`s in parallel assignment. Prefer `a, = foo()`.
      RUBY
    end

    it 'does not register an offense for a named underscore preceded by a ' \
       'splat variable' do
      expect_no_offenses('a, *b, _c = foo()')
    end

    it 'registers an offense for an underscore variable preceded ' \
       'by a named splat underscore variable' do
      expect_offense(<<-RUBY.strip_indent)
        a, *_b, _ = foo()
           ^^^^^^^ Do not use trailing `_`s in parallel assignment. Prefer `a, = foo()`.
      RUBY
    end

    it 'registers an offense for an underscore preceded by ' \
       'a named splat underscore' do
      expect_offense(<<-RUBY.strip_indent)
        a, b, *_c, _ = foo()
              ^^^^^^^ Do not use trailing `_`s in parallel assignment. Prefer `a, b, = foo()`.
      RUBY
    end

    it 'registers an offense for multiple underscore variables ' \
       'preceded by a named splat underscore variable' do
      expect_offense(<<-RUBY.strip_indent)
        a, *_b, _, _ = foo()
           ^^^^^^^^^^ Do not use trailing `_`s in parallel assignment. Prefer `a, = foo()`.
      RUBY
    end

    context 'autocorrect' do
      it 'removes named underscore variables' do
        new_source = autocorrect_source('a, _b = foo()')

        expect(new_source).to eq('a, = foo()')
      end

      it 'removes named splat underscore variables' do
        new_source = autocorrect_source('a, *_b = foo()')

        expect(new_source).to eq('a, = foo()')
      end

      it 'removes named splat underscore and named underscore variables' do
        new_source = autocorrect_source('a, *_b, _c = foo()')

        expect(new_source).to eq('a, = foo()')
      end

      it 'works when last underscore is followed by a comma' do
        new_source = autocorrect_source('a, _, = foo()')

        expect(new_source).to eq('a, = foo()')
      end
    end
  end
end
