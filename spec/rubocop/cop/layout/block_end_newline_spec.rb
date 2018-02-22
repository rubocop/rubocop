# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::BlockEndNewline do
  subject(:cop) { described_class.new }

  it 'accepts a one-liner' do
    expect_no_offenses('test do foo end')
  end

  it 'accepts multiline blocks with newlines before the end' do
    expect_no_offenses(<<-RUBY.strip_indent)
      test do
        foo
      end
    RUBY
  end

  it 'registers an offense when multiline block end is not on its own line' do
    expect_offense(<<-RUBY.strip_indent)
      test do
        foo end
            ^^^ Expression at 2, 7 should be on its own line.
    RUBY
  end

  it 'registers an offense when multiline block } is not on its own line' do
    expect_offense(<<-RUBY.strip_indent)
      test {
        foo }
            ^ Expression at 2, 7 should be on its own line.
    RUBY
  end

  it 'autocorrects a do/end block where the end is not on its own line' do
    new_source = autocorrect_source(<<-RUBY.strip_indent)
      test do
        foo  end
    RUBY

    expect(new_source).to eq(<<-RUBY.strip_indent)
      test do
        foo
      end
    RUBY
  end

  it 'autocorrects a {} block where the } is not on its own line' do
    new_source = autocorrect_source(<<-RUBY.strip_indent)
      test {
        foo  }
    RUBY

    expect(new_source).to eq(<<-RUBY.strip_indent)
      test {
        foo
      }
    RUBY
  end

  it 'autocorrects a {} block where the } is top level code ' \
    'outside of a class' do
    new_source = autocorrect_source(<<-RUBY.strip_indent)
      # frozen_string_literal: true

      test {[
        foo
      ]}
    RUBY

    expect(new_source).to eq(<<-RUBY.strip_indent)
      # frozen_string_literal: true

      test {[
        foo
      ]
      }
    RUBY
  end
end
