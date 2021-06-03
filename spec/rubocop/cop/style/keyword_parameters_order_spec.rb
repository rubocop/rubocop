# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::KeywordParametersOrder, :config do
  it 'registers an offense and corrects when `kwoptarg` is before `kwarg`' do
    expect_offense(<<~RUBY)
      def m(arg, optional: 1, required:)
                 ^^^^^^^^^^^ Place optional keyword parameters at the end of the parameters list.
      end
    RUBY

    expect_correction(<<~RUBY)
      def m(arg, required:, optional: 1)
      end
    RUBY
  end

  it 'registers an offense and corrects when `kwoptarg` is before `kwarg` and argument parentheses omitted' do
    expect_offense(<<~RUBY)
      def m arg, optional: 1, required:
                 ^^^^^^^^^^^ Place optional keyword parameters at the end of the parameters list.
        do_something
      end
    RUBY

    expect_correction(<<~RUBY)
      def m arg, required:, optional: 1
        do_something
      end
    RUBY
  end

  it 'registers an offense and corrects when multiple `kwoptarg` are before `kwarg` and argument parentheses omitted' do
    expect_offense(<<~RUBY)
      def m arg, optional1: 1, optional2: 2, required:
                               ^^^^^^^^^^^^ Place optional keyword parameters at the end of the parameters list.
                 ^^^^^^^^^^^^ Place optional keyword parameters at the end of the parameters list.
        do_something
      end
    RUBY

    expect_correction(<<~RUBY)
      def m arg, required:, optional1: 1, optional2: 2
        do_something
      end
    RUBY
  end

  it 'registers an offense and corrects when multiple `kwoptarg`s are interleaved with `kwarg`s' do
    expect_offense(<<~RUBY)
      def m(arg, optional1: 1, required1:, optional2: 2, required2:, **rest, &block)
                 ^^^^^^^^^^^^ Place optional keyword parameters at the end of the parameters list.
                                           ^^^^^^^^^^^^ Place optional keyword parameters at the end of the parameters list.
      end
    RUBY

    expect_correction(<<~RUBY)
      def m(arg, required1:, required2:, optional1: 1, optional2: 2, **rest, &block)
      end
    RUBY
  end

  it 'registers an offense and corrects when multiple `kwoptarg`s are interleaved with `kwarg`s' \
     'and last argument is `kwrestarg` and argument parentheses omitted' do
    expect_offense(<<~RUBY)
      def m arg, optional1: 1, required1:, optional2: 2, required2:, **rest
                 ^^^^^^^^^^^^ Place optional keyword parameters at the end of the parameters list.
                                           ^^^^^^^^^^^^ Place optional keyword parameters at the end of the parameters list.
        do_something
      end
    RUBY

    expect_correction(<<~RUBY)
      def m arg, required1:, required2:, optional1: 1, optional2: 2, **rest
        do_something
      end
    RUBY
  end

  it 'registers an offense and corrects when multiple `kwoptarg`s are interleaved with `kwarg`s' \
     'and last argument is `blockarg` and argument parentheses omitted' do
    expect_offense(<<~RUBY)
      def m arg, optional1: 1, required1:, optional2: 2, required2:, **rest, &block
                 ^^^^^^^^^^^^ Place optional keyword parameters at the end of the parameters list.
                                           ^^^^^^^^^^^^ Place optional keyword parameters at the end of the parameters list.
        do_something
      end
    RUBY

    expect_correction(<<~RUBY)
      def m arg, required1:, required2:, optional1: 1, optional2: 2, **rest, &block
        do_something
      end
    RUBY
  end

  it 'does not register an offense when there are no `kwoptarg`s before `kwarg`s' do
    expect_no_offenses(<<~RUBY)
      def m(arg, required:, optional: 1)
      end
    RUBY
  end

  context 'when using block keyword parameters' do
    it 'registers an offense and corrects when `kwoptarg` is before `kwarg`' do
      expect_offense(<<~RUBY)
        m(arg) do |block_arg, optional: 1, required:|
                              ^^^^^^^^^^^ Place optional keyword parameters at the end of the parameters list.
        end
      RUBY

      expect_correction(<<~RUBY)
        m(arg) do |block_arg, required:, optional: 1|
        end
      RUBY
    end

    it 'does not register an offense when there are no `kwoptarg`s before `kwarg`s' do
      expect_no_offenses(<<~RUBY)
        m(arg) do |block_arg, required:, optional: 1|
        end
      RUBY
    end
  end
end
