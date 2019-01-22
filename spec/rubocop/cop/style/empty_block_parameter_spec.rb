# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::EmptyBlockParameter do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it 'registers an offense for an empty block parameter with do-end wtyle' do
    expect_offense(<<-RUBY.strip_indent)
      a do ||
           ^^ Omit pipes for the empty block parameters.
      end
    RUBY

    expect_correction(<<-RUBY.strip_indent)
      a do
      end
    RUBY
  end

  it 'registers an offense for an empty block parameter with {} style' do
    expect_offense(<<-RUBY.strip_indent)
      a { || do_something }
          ^^ Omit pipes for the empty block parameters.
    RUBY

    expect_correction(<<-RUBY.strip_indent)
      a { do_something }
    RUBY
  end

  it 'registers an offense for an empty block parameter with super' do
    expect_offense(<<-RUBY.strip_indent)
      def foo
        super { || do_something }
                ^^ Omit pipes for the empty block parameters.
      end
    RUBY

    expect_correction(<<-RUBY.strip_indent)
      def foo
        super { do_something }
      end
    RUBY
  end

  it 'registers an offense for an empty block parameter with lambda' do
    expect_offense(<<-RUBY.strip_indent)
      lambda { || do_something }
               ^^ Omit pipes for the empty block parameters.
    RUBY

    expect_correction(<<-RUBY.strip_indent)
      lambda { do_something }
    RUBY
  end

  it 'accepts a block that is do-end style without parameter' do
    expect_no_offenses(<<-RUBY.strip_indent)
      a do
      end
    RUBY
  end

  it 'accepts a block that is {} style without parameter' do
    expect_no_offenses(<<-RUBY.strip_indent)
      a { }
    RUBY
  end

  it 'accepts a non-empty block parameter with do-end style' do
    expect_no_offenses(<<-RUBY.strip_indent)
      a do |x|
      end
    RUBY
  end

  it 'accepts a non-empty block parameter with {} style' do
    expect_no_offenses(<<-RUBY.strip_indent)
      a { |x| }
    RUBY
  end

  it 'accepts an empty block parameter with a lambda' do
    expect_no_offenses(<<-RUBY.strip_indent)
      -> () { do_something }
    RUBY
  end
end
