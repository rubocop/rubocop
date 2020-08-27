# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::KeywordParametersOrder do
  subject(:cop) { described_class.new }

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

  it 'does not register an offense when there are no `kwoptarg`s before `kwarg`s' do
    expect_no_offenses(<<~RUBY)
      def m(arg, required:, optional: 1)
      end
    RUBY
  end
end
