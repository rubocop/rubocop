# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ItBlockParameter, :config do
  context '>= Ruby 3.4', :ruby34 do
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

      it 'registers an offense when using a single named block parameters' do
        expect_offense(<<~RUBY)
          block { |arg| do_something(arg) }
                                     ^^^ Use `it` block parameter.
        RUBY

        expect_correction(<<~RUBY)
          block {  do_something(it) }
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
