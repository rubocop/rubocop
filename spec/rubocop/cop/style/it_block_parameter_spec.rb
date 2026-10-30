# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ItBlockParameter, :config do
  context '>= Ruby 3.4', :ruby34 do
    context 'EnforcedStyle: allow_single_line' do
      let(:cop_config) { { 'EnforcedStyle' => 'allow_single_line' } }

      it 'registers an offense when using multiline `it` parameters', unsupported_on: :parser do
        expect_offense(<<~RUBY)
          block do
          ^^^^^^^^ Avoid using `it` block parameter for multi-line blocks.
            do_something(it)
          end
        RUBY

        expect_no_corrections
      end

      it 'registers no offense when using `it` block parameter with multi-line method chain' do
        expect_no_offenses(<<~RUBY)
          collection.each
                    .foo { puts it }
        RUBY
      end

      it 'registers an offense when using a single numbered parameters' do
        expect_offense(<<~RUBY)
          block { do_something(_1) }
                               ^^ Use `it` block parameter.
        RUBY

        expect_correction(<<~RUBY)
          block { do_something(it) }
        RUBY
      end

      it 'registers an offense when using twice a single numbered parameters' do
        expect_offense(<<~RUBY)
          block do
            foo(_1)
                ^^ Use `it` block parameter.
            bar(_1)
                ^^ Use `it` block parameter.
          end
        RUBY

        expect_correction(<<~RUBY)
          block do
            foo(it)
            bar(it)
          end
        RUBY
      end

      it 'does not register an offense when using `it` block parameters' do
        expect_no_offenses(<<~RUBY)
          block { do_something(it) }
        RUBY
      end

      it 'does not register an offense when using named block parameters' do
        expect_no_offenses(<<~RUBY)
          block { |arg| do_something(arg) }
        RUBY
      end

      it 'does not register an offense when using multiple numbered parameters' do
        expect_no_offenses(<<~RUBY)
          block { do_something(_1, _2) }
        RUBY
      end

      it 'does not register an offense when using a single numbered parameters `_2`' do
        expect_no_offenses(<<~RUBY)
          block { do_something(_2) }
        RUBY
      end

      it 'does not register an offense for a single numbered parameter when a local variable named `it` is in scope' do
        expect_no_offenses(<<~RUBY)
          it = do_something
          block { do_something(_1) }
        RUBY
      end
    end

    context 'EnforcedStyle: only_numbered_parameters' do
      let(:cop_config) { { 'EnforcedStyle' => 'only_numbered_parameters' } }

      it 'registers an offense when using a single numbered parameters' do
        expect_offense(<<~RUBY)
          block { do_something(_1) }
                               ^^ Use `it` block parameter.
        RUBY

        expect_correction(<<~RUBY)
          block { do_something(it) }
        RUBY
      end

      it 'registers an offense when using twice a single numbered parameters' do
        expect_offense(<<~RUBY)
          block do
            foo(_1)
                ^^ Use `it` block parameter.
            bar(_1)
                ^^ Use `it` block parameter.
          end
        RUBY

        expect_correction(<<~RUBY)
          block do
            foo(it)
            bar(it)
          end
        RUBY
      end

      it 'registers an offense when using a single numbered parameter after multiple numbered parameters in a method chain' do
        expect_offense(<<~RUBY)
          foo { bar(_1, _2) }.baz { qux(_1) }
                                        ^^ Use `it` block parameter.
        RUBY

        expect_correction(<<~RUBY)
          foo { bar(_1, _2) }.baz { qux(it) }
        RUBY
      end

      it 'does not register an offense when using `it` block parameters' do
        expect_no_offenses(<<~RUBY)
          block { do_something(it) }
        RUBY
      end

      it 'does not register an offense when using named block parameters' do
        expect_no_offenses(<<~RUBY)
          block { |arg| do_something(arg) }
        RUBY
      end

      it 'does not register an offense when using multiple numbered parameters' do
        expect_no_offenses(<<~RUBY)
          block { do_something(_1, _2) }
        RUBY
      end

      it 'does not register an offense when using a single numbered parameters `_2`' do
        expect_no_offenses(<<~RUBY)
          block { do_something(_2) }
        RUBY
      end
    end

    context 'EnforcedStyle: always' do
      let(:cop_config) { { 'EnforcedStyle' => 'always' } }

      it 'registers an offense when using a single numbered parameters' do
        expect_offense(<<~RUBY)
          block { do_something(_1) }
                               ^^ Use `it` block parameter.
        RUBY

        expect_correction(<<~RUBY)
          block { do_something(it) }
        RUBY
      end

      it 'registers an offense when using twice a single numbered parameters' do
        expect_offense(<<~RUBY)
          block do
            foo(_1)
                ^^ Use `it` block parameter.
            bar(_1)
                ^^ Use `it` block parameter.
          end
        RUBY

        expect_correction(<<~RUBY)
          block do
            foo(it)
            bar(it)
          end
        RUBY
      end

      it 'does not register an offense for a named parameter when a local variable named `it` is assigned before the block' do
        expect_no_offenses(<<~RUBY)
          it = do_something
          block { |arg| do_something(arg) }
        RUBY
      end

      it 'does not register an offense for a numbered parameter when a local variable named `it` is assigned before the block' do
        expect_no_offenses(<<~RUBY)
          it = do_something
          block { do_something(_1) }
        RUBY
      end

      it 'does not register an offense when a local variable named `it` is assigned in the block' do
        expect_no_offenses(<<~RUBY)
          block { |arg| it = do_something; do_something(arg, it) }
        RUBY
      end

      it 'does not register an offense when the method has a parameter named `it`' do
        expect_no_offenses(<<~RUBY)
          def foo(it)
            block { do_something(_1) }
          end
        RUBY
      end

      it 'does not register an offense when an outer block has a parameter named `it`' do
        expect_no_offenses(<<~RUBY)
          outer { |it| block { do_something(_1) } }
        RUBY
      end

      it 'registers an offense when a local variable named `it` is assigned after the block' do
        expect_offense(<<~RUBY)
          block { do_something(_1) }
                               ^^ Use `it` block parameter.
          it = do_something
        RUBY

        expect_correction(<<~RUBY)
          block { do_something(it) }
          it = do_something
        RUBY
      end

      it 'registers an offense when a local variable named `it` is assigned in another method' do
        expect_offense(<<~RUBY)
          def foo
            it = do_something
          end

          block { do_something(_1) }
                               ^^ Use `it` block parameter.
        RUBY

        expect_correction(<<~RUBY)
          def foo
            it = do_something
          end

          block { do_something(it) }
        RUBY
      end

      it 'does not register an offense when the parameter is used inside a nested block with parameters' do
        expect_no_offenses(<<~RUBY)
          block { |arg| other { |x, y| arg } }
        RUBY
      end

      it 'does not register an offense when the parameter is used inside a nested block without parameters' do
        expect_no_offenses(<<~RUBY)
          block { |arg| other { arg } }
        RUBY
      end

      it 'registers an offense for the nested block only when the parameter is used both inside ' \
         'and outside it' do
        expect_offense(<<~RUBY)
          block { |arg| use(arg); other { |x| log(arg, x) } }
                                                       ^ Use `it` block parameter.
        RUBY

        expect_correction(<<~RUBY)
          block { |arg| use(arg); other {  log(arg, it) } }
        RUBY
      end

      it 'registers an offense when the parameter is the receiver of a nested block' do
        expect_offense(<<~RUBY)
          block { |arg| arg.other { |x| x } }
                        ^^^ Use `it` block parameter.
        RUBY

        expect_correction(<<~RUBY)
          block {  it.other { |x| x } }
        RUBY
      end

      it 'registers an offense for a numbered parameter of a nested block only' do
        expect_offense(<<~RUBY)
          block { |arg| other { _1 + arg } }
                                ^^ Use `it` block parameter.
        RUBY

        expect_correction(<<~RUBY)
          block { |arg| other { it + arg } }
        RUBY
      end

      it 'registers an offense when using a single named block parameters' do
        expect_offense(<<~RUBY)
          block { |arg| do_something(arg) }
                                     ^^^ Use `it` block parameter.
        RUBY

        expect_correction(<<~RUBY)
          block {  do_something(it) }
        RUBY
      end

      it 'registers an offense when using a single named block parameter as an omitted hash value' do
        expect_offense(<<~RUBY)
          block { |arg| do_something(arg:, key: {arg:}) }
                                     ^^^ Use `it` block parameter.
                                                 ^^^ Use `it` block parameter.
        RUBY

        expect_correction(<<~RUBY)
          block {  do_something(arg: it, key: {arg: it}) }
        RUBY
      end

      it 'registers an offense when using twice a single named parameters' do
        expect_offense(<<~RUBY)
          block do |arg|
            foo(arg)
                ^^^ Use `it` block parameter.
            bar(arg)
                ^^^ Use `it` block parameter.
          end
        RUBY

        expect_correction(<<~RUBY)
          block do#{' '}
            foo(it)
            bar(it)
          end
        RUBY
      end

      it 'does not register an offense when using `it` block parameters' do
        expect_no_offenses(<<~RUBY)
          block { do_something(it) }
        RUBY
      end

      it 'does not register an offense when using multiple numbered parameters' do
        expect_no_offenses(<<~RUBY)
          block { do_something(_1, _2) }
        RUBY
      end

      it 'does not register an offense when using a single numbered parameters `_2`' do
        expect_no_offenses(<<~RUBY)
          block { do_something(_2) }
        RUBY
      end

      it 'does not register an offense when using multiple named block parameters' do
        expect_no_offenses(<<~RUBY)
          block { |foo, bar| do_something(foo, bar) }
        RUBY
      end

      it 'does not register an offense for block with parameter and missing body' do
        expect_no_offenses(<<~RUBY)
          block do |_|
          end
        RUBY
      end

      it 'does not register an offense when the block assigns its parameter' do
        expect_no_offenses(<<~RUBY)
          block { |arg| arg = arg.do_something; arg }
        RUBY
      end

      it 'does not register an offense when the block assigns its parameter with an operator' do
        expect_no_offenses(<<~RUBY)
          block { |arg| arg += 1; arg }
        RUBY
      end

      it 'does not register an offense when the block assigns its parameter with a named capture' do
        expect_no_offenses(<<~RUBY)
          block { |arg| /(?<arg>foo)/ =~ arg; arg }
        RUBY
      end

      it 'does not register an offense when the block assigns its parameter with pattern matching' do
        expect_no_offenses(<<~RUBY)
          block { |arg| arg => {key: arg}; arg }
        RUBY
      end

      it 'registers an offense when the block assigns another variable' do
        expect_offense(<<~RUBY)
          block { |arg| other = arg.do_something; other }
                                ^^^ Use `it` block parameter.
        RUBY

        expect_correction(<<~RUBY)
          block {  other = it.do_something; other }
        RUBY
      end
    end

    context 'EnforcedStyle: disallow' do
      let(:cop_config) { { 'EnforcedStyle' => 'disallow' } }

      it 'registers an offense when using `it` block parameters' do
        expect_offense(<<~RUBY)
          block { do_something(it) }
                               ^^ Avoid using `it` block parameter.
        RUBY

        expect_no_corrections
      end

      it 'registers an offense when using twice `it` block parameters' do
        expect_offense(<<~RUBY)
          block do
            foo(it)
                ^^ Avoid using `it` block parameter.
            bar(it)
                ^^ Avoid using `it` block parameter.
          end
        RUBY

        expect_no_corrections
      end

      it 'does not register an offense when using a single numbered parameters' do
        expect_no_offenses(<<~RUBY)
          block { do_something(_1) }
        RUBY
      end

      it 'does not register an offense when using named block parameters' do
        expect_no_offenses(<<~RUBY)
          block { |arg| do_something(arg) }
        RUBY
      end

      it 'does not register an offense when using multiple numbered parameters' do
        expect_no_offenses(<<~RUBY)
          block { do_something(_1, _2) }
        RUBY
      end

      it 'does not register an offense when using a single numbered parameters `_2`' do
        expect_no_offenses(<<~RUBY)
          block { do_something(_2) }
        RUBY
      end
    end
  end

  context '<= Ruby 3.3', :ruby33 do
    context 'EnforcedStyle: only_numbered_parameters' do
      let(:cop_config) { { 'EnforcedStyle' => 'only_numbered_parameters' } }

      it 'does not register an offense when using a single numbered parameters' do
        expect_no_offenses(<<~RUBY)
          block { do_something(_1) }
        RUBY
      end
    end

    context 'EnforcedStyle: always' do
      let(:cop_config) { { 'EnforcedStyle' => 'always' } }

      it 'does not register an offense when using a single numbered parameters' do
        expect_no_offenses(<<~RUBY)
          block { do_something(_1) }
        RUBY
      end

      it 'does not register an offense when using a single named block parameters' do
        expect_no_offenses(<<~RUBY)
          block { |arg| do_something(arg) }
        RUBY
      end
    end

    context 'EnforcedStyle: disallow' do
      let(:cop_config) { { 'EnforcedStyle' => 'disallow' } }

      it 'does not register an offense when using `it` block parameters' do
        expect_no_offenses(<<~RUBY)
          block { do_something(it) }
        RUBY
      end
    end
  end
end
