# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::EmptyLambdaParameter do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it 'registers an offense for an empty block parameter with a lambda' do
    expect_offense(<<-RUBY.strip_indent)
      -> () { do_something }
         ^^ Omit parentheses for the empty lambda parameters.
    RUBY
  end

  it 'auto-corrects for a lambda' do
    new_source = autocorrect_source(<<-RUBY.strip_indent)
      -> () { do_something }
    RUBY

    expect(new_source).to eq(<<-RUBY.strip_indent)
      -> { do_something }
    RUBY
  end

  it 'accepts a keyword lambda' do
    expect_no_offenses(<<-RUBY)
      lambda { || do_something }
    RUBY
  end

  it 'does not crash on a super' do
    expect_no_offenses(<<-RUBY)
      def foo
        super { || do_something }
      end
    RUBY
  end
end
