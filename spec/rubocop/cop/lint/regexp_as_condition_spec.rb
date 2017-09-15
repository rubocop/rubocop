# frozen_string_literal: true

describe RuboCop::Cop::Lint::RegexpAsCondition do
  let(:config) { RuboCop::Config.new }

  subject(:cop) { described_class.new(config) }

  it 'registers an offense for a regexp literal in `if` condition' do
    expect_offense(<<-RUBY.strip_indent)
      if /foo/
         ^^^^^ Do not use regexp literal as a condition. The regexp literal matches `$_` implicitly.
      end
    RUBY
  end

  it 'does not register an offense for a regexp literal outside conditions' do
    expect_no_offenses(<<-RUBY.strip_indent)
      /foo/
    RUBY
  end

  it 'does not register an offense for a regexp literal with `=~` operator' do
    expect_no_offenses(<<-RUBY.strip_indent)
      if /foo/ =~ str
      end
    RUBY
  end
end
