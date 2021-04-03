# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::SpaceAroundMethodCallOperator, :config do
  # FIXME: Remove unused vars
  shared_examples 'offense' do |name, _code, offense, correction|
    it "registers an offense and corrects when #{name}" do
      expect_offense(offense)

      expect_correction(correction)
    end
  end

  context 'dot operator' do
    include_examples 'offense', 'space after method call',
                     <<-CODE, <<-OFFENSE, <<-CORRECTION
      foo. bar
    CODE
      foo. bar
          ^ Avoid using spaces around a method call operator.
    OFFENSE
      foo.bar
    CORRECTION

    include_examples 'offense', 'space before method call',
                     <<-CODE, <<-OFFENSE, <<-CORRECTION
      foo .bar
    CODE
      foo .bar
         ^ Avoid using spaces around a method call operator.
    OFFENSE
      foo.bar
    CORRECTION

    include_examples 'offense', 'spaces before method call',
                     <<-CODE, <<-OFFENSE, <<-CORRECTION
      foo  .bar
    CODE
      foo  .bar
         ^^ Avoid using spaces around a method call operator.
    OFFENSE
      foo.bar
    CORRECTION

    include_examples 'offense', 'spaces after method call',
                     <<-CODE, <<-OFFENSE, <<-CORRECTION
      foo.  bar
    CODE
      foo.  bar
          ^^ Avoid using spaces around a method call operator.
    OFFENSE
      foo.bar
    CORRECTION

    include_examples 'offense', 'spaces around method call',
                     <<-CODE, <<-OFFENSE, <<-CORRECTION
      foo . bar
    CODE
      foo . bar
           ^ Avoid using spaces around a method call operator.
         ^ Avoid using spaces around a method call operator.
    OFFENSE
      foo.bar
    CORRECTION

    include_examples 'offense', 'spaces after `Proc#call` shorthand call',
                     <<-CODE, <<-OFFENSE, <<-CORRECTION
      foo. ()
    CODE
      foo. ()
          ^ Avoid using spaces around a method call operator.
    OFFENSE
      foo.()
    CORRECTION

    context 'when multi line method call' do
      include_examples 'offense', 'space before method call',
                       <<-CODE, <<-OFFENSE, <<-CORRECTION
        foo
          . bar
      CODE
        foo
          . bar
           ^ Avoid using spaces around a method call operator.
      OFFENSE
        foo
          .bar
      CORRECTION

      include_examples 'offense', 'space before method call in suffix chaining',
                       <<-CODE, <<-OFFENSE, <<-CORRECTION
        foo .
          bar
      CODE
        foo .
           ^ Avoid using spaces around a method call operator.
          bar
      OFFENSE
        foo.
          bar
      CORRECTION

      it 'does not register an offense when no space after the `.`' do
        expect_no_offenses(<<~RUBY)
          foo
            .bar
        RUBY
      end
    end

    it 'does not register an offense when no space around method call' do
      expect_no_offenses(<<~RUBY)
        'foo'.bar
      RUBY
    end

    include_examples 'offense', 'space after last method call operator',
                     <<-CODE, <<-OFFENSE, <<-CORRECTION
      foo.bar. buzz
    CODE
      foo.bar. buzz
              ^ Avoid using spaces around a method call operator.
    OFFENSE
      foo.bar.buzz
    CORRECTION

    include_examples 'offense', 'space after first method call operator',
                     <<-CODE, <<-OFFENSE, <<-CORRECTION
      foo. bar.buzz
    CODE
      foo. bar.buzz
          ^ Avoid using spaces around a method call operator.
    OFFENSE
      foo.bar.buzz
    CORRECTION

    include_examples 'offense', 'space before first method call operator',
                     <<-CODE, <<-OFFENSE, <<-CORRECTION
      foo .bar.buzz
    CODE
      foo .bar.buzz
         ^ Avoid using spaces around a method call operator.
    OFFENSE
      foo.bar.buzz
    CORRECTION

    include_examples 'offense', 'space before last method call operator',
                     <<-CODE, <<-OFFENSE, <<-CORRECTION
      foo.bar .buzz
    CODE
      foo.bar .buzz
             ^ Avoid using spaces around a method call operator.
    OFFENSE
      foo.bar.buzz
    CORRECTION

    include_examples 'offense',
                     'space around intermediate method call operator',
                     <<-CODE, <<-OFFENSE, <<-CORRECTION
      foo.bar .buzz.bat
    CODE
      foo.bar .buzz.bat
             ^ Avoid using spaces around a method call operator.
    OFFENSE
      foo.bar.buzz.bat
    CORRECTION

    include_examples 'offense', 'space around multiple method call operator',
                     <<-CODE, <<-OFFENSE, <<-CORRECTION
      foo. bar. buzz.bat
    CODE
      foo. bar. buzz.bat
               ^ Avoid using spaces around a method call operator.
          ^ Avoid using spaces around a method call operator.
    OFFENSE
      foo.bar.buzz.bat
    CORRECTION

    it 'does not register an offense when no space around any `.` operators' do
      expect_no_offenses(<<~RUBY)
        foo.bar.buzz
      RUBY
    end

    context 'when there is a space between `.` operator and a comment' do
      it 'does not register an offense when there is not a space before `.`' do
        expect_no_offenses(<<~RUBY)
          foo. # comment
            bar.baz
        RUBY
      end

      it 'registers an offense when there is a space before `.`' do
        expect_offense(<<~RUBY)
          foo . # comment
             ^ Avoid using spaces around a method call operator.
            bar.baz
        RUBY

        expect_correction(<<~RUBY)
          foo. # comment
            bar.baz
        RUBY
      end
    end
  end

  context 'safe navigation operator' do
    include_examples 'offense', 'space after method call',
                     <<-CODE, <<-OFFENSE, <<-CORRECTION
      foo&. bar
    CODE
      foo&. bar
           ^ Avoid using spaces around a method call operator.
    OFFENSE
      foo&.bar
    CORRECTION

    include_examples 'offense', 'space before method call',
                     <<-CODE, <<-OFFENSE, <<-CORRECTION
      foo &.bar
    CODE
      foo &.bar
         ^ Avoid using spaces around a method call operator.
    OFFENSE
      foo&.bar
    CORRECTION

    include_examples 'offense', 'spaces before method call',
                     <<-CODE, <<-OFFENSE, <<-CORRECTION
      foo  &.bar
    CODE
      foo  &.bar
         ^^ Avoid using spaces around a method call operator.
    OFFENSE
      foo&.bar
    CORRECTION

    include_examples 'offense', 'spaces after method call',
                     <<-CODE, <<-OFFENSE, <<-CORRECTION
      foo&.  bar
    CODE
      foo&.  bar
           ^^ Avoid using spaces around a method call operator.
    OFFENSE
      foo&.bar
    CORRECTION

    include_examples 'offense', 'spaces around method call',
                     <<-CODE, <<-OFFENSE, <<-CORRECTION
      foo &. bar
    CODE
      foo &. bar
            ^ Avoid using spaces around a method call operator.
         ^ Avoid using spaces around a method call operator.
    OFFENSE
      foo&.bar
    CORRECTION

    context 'when multi line method call' do
      include_examples 'offense', 'space before method call',
                       <<-CODE, <<-OFFENSE, <<-CORRECTION
        foo
          &. bar
      CODE
        foo
          &. bar
            ^ Avoid using spaces around a method call operator.
      OFFENSE
        foo
          &.bar
      CORRECTION

      include_examples 'offense', 'space before method call in suffix chaining',
                       <<-CODE, <<-OFFENSE, <<-CORRECTION
        foo &.
          bar
      CODE
        foo &.
           ^ Avoid using spaces around a method call operator.
          bar
      OFFENSE
        foo&.
          bar
      CORRECTION

      it 'does not register an offense when no space after the `&.`' do
        expect_no_offenses(<<~RUBY)
          foo
            &.bar
        RUBY
      end
    end

    it 'does not register an offense when no space around method call' do
      expect_no_offenses(<<~RUBY)
        foo&.bar
      RUBY
    end

    include_examples 'offense', 'space after last method call operator',
                     <<-CODE, <<-OFFENSE, <<-CORRECTION
      foo&.bar&. buzz
    CODE
      foo&.bar&. buzz
                ^ Avoid using spaces around a method call operator.
    OFFENSE
      foo&.bar&.buzz
    CORRECTION

    include_examples 'offense', 'space after first method call operator',
                     <<-CODE, <<-OFFENSE, <<-CORRECTION
      foo&. bar&.buzz
    CODE
      foo&. bar&.buzz
           ^ Avoid using spaces around a method call operator.
    OFFENSE
      foo&.bar&.buzz
    CORRECTION

    include_examples 'offense', 'space before first method call operator',
                     <<-CODE, <<-OFFENSE, <<-CORRECTION
      foo &.bar&.buzz
    CODE
      foo &.bar&.buzz
         ^ Avoid using spaces around a method call operator.
    OFFENSE
      foo&.bar&.buzz
    CORRECTION

    include_examples 'offense', 'space before last method call operator',
                     <<-CODE, <<-OFFENSE, <<-CORRECTION
      foo&.bar &.buzz
    CODE
      foo&.bar &.buzz
              ^ Avoid using spaces around a method call operator.
    OFFENSE
      foo&.bar&.buzz
    CORRECTION

    include_examples 'offense',
                     'space around intermediate method call operator',
                     <<-CODE, <<-OFFENSE, <<-CORRECTION
      foo&.bar &.buzz&.bat
    CODE
      foo&.bar &.buzz&.bat
              ^ Avoid using spaces around a method call operator.
    OFFENSE
      foo&.bar&.buzz&.bat
    CORRECTION

    include_examples 'offense', 'space around multiple method call operator',
                     <<-CODE, <<-OFFENSE, <<-CORRECTION
      foo&. bar&. buzz&.bat
    CODE
      foo&. bar&. buzz&.bat
                 ^ Avoid using spaces around a method call operator.
           ^ Avoid using spaces around a method call operator.
    OFFENSE
      foo&.bar&.buzz&.bat
    CORRECTION

    it 'does not register an offense when no space around any `.` operators' do
      expect_no_offenses(<<~RUBY)
        foo&.bar&.buzz
      RUBY
    end
  end

  context ':: operator' do
    include_examples 'offense', 'space after method call',
                     <<-CODE, <<-OFFENSE, <<-CORRECTION
      RuboCop:: Cop
    CODE
      RuboCop:: Cop
               ^ Avoid using spaces around a method call operator.
    OFFENSE
      RuboCop::Cop
    CORRECTION

    include_examples 'offense', 'spaces after method call',
                     <<-CODE, <<-OFFENSE, <<-CORRECTION
      RuboCop::  Cop
    CODE
      RuboCop::  Cop
               ^^ Avoid using spaces around a method call operator.
    OFFENSE
      RuboCop::Cop
    CORRECTION

    context 'when multi line method call' do
      include_examples 'offense', 'space before method call',
                       <<-CODE, <<-OFFENSE, <<-CORRECTION
        RuboCop
          :: Cop
      CODE
        RuboCop
          :: Cop
            ^ Avoid using spaces around a method call operator.
      OFFENSE
        RuboCop
          ::Cop
      CORRECTION

      it 'does not register an offense when no space after the `::`' do
        expect_no_offenses(<<~RUBY)
          RuboCop
            ::Cop
        RUBY
      end
    end

    it 'does not register an offense when no space around method call' do
      expect_no_offenses(<<~RUBY)
        RuboCop::Cop
      RUBY
    end

    include_examples 'offense', 'space after last method call operator',
                     <<-CODE, <<-OFFENSE, <<-CORRECTION
      RuboCop::Cop:: Cop
    CODE
      RuboCop::Cop:: Cop
                    ^ Avoid using spaces around a method call operator.
    OFFENSE
      RuboCop::Cop::Cop
    CORRECTION

    include_examples 'offense',
                     'space around intermediate method call operator',
                     <<-CODE, <<-OFFENSE, <<-CORRECTION
      RuboCop::Cop:: Cop::Cop
    CODE
      RuboCop::Cop:: Cop::Cop
                    ^ Avoid using spaces around a method call operator.
    OFFENSE
      RuboCop::Cop::Cop::Cop
    CORRECTION

    include_examples 'offense', 'space around multiple method call operator',
                     <<-CODE, <<-OFFENSE, <<-CORRECTION
      :: RuboCop:: Cop:: Cop::Cop
    CODE
      :: RuboCop:: Cop:: Cop::Cop
                        ^ Avoid using spaces around a method call operator.
                  ^ Avoid using spaces around a method call operator.
        ^ Avoid using spaces around a method call operator.
    OFFENSE
      ::RuboCop::Cop::Cop::Cop
    CORRECTION

    include_examples 'offense', 'space after first operator with assignment',
                     <<-CODE, <<-OFFENSE, <<-CORRECTION
      klass = :: RuboCop::Cop
    CODE
      klass = :: RuboCop::Cop
                ^ Avoid using spaces around a method call operator.
    OFFENSE
      klass = ::RuboCop::Cop
    CORRECTION

    it 'does not register an offense when no space around any `.` operators' do
      expect_no_offenses(<<~RUBY)
        RuboCop::Cop::Cop
      RUBY
    end

    it 'does not register an offense if no space before `::` operator with assignment' do
      expect_no_offenses(<<~RUBY)
        klass = ::RuboCop::Cop
      RUBY
    end

    it 'does not register an offense if no space before `::` operator with inheritance' do
      expect_no_offenses(<<~RUBY)
        class Test <  ::RuboCop::Cop
        end
      RUBY
    end

    it 'does not register an offense if no space with conditionals' do
      expect_no_offenses(<<~RUBY)
        ::RuboCop::Cop || ::RuboCop
      RUBY
    end

    include_examples 'offense', 'multiple spaces with assignment',
                     <<-CODE, <<-OFFENSE, <<-CORRECTION
      :: RuboCop:: Cop || :: RuboCop
    CODE
      :: RuboCop:: Cop || :: RuboCop
                            ^ Avoid using spaces around a method call operator.
                  ^ Avoid using spaces around a method call operator.
        ^ Avoid using spaces around a method call operator.
    OFFENSE
      ::RuboCop::Cop || ::RuboCop
    CORRECTION
  end

  it 'does not register an offense when no method call operator' do
    expect_no_offenses(<<~RUBY)
      'foo' + 'bar'
    RUBY
  end

  it 'does not register an offense when using `__ENCODING__`' do
    expect_no_offenses(<<~RUBY)
      __ENCODING__
    RUBY
  end
end
