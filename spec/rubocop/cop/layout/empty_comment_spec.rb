# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::EmptyComment do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it 'registers an offense when using single line empty comment' do
    expect_offense(<<-RUBY.strip_indent)
      #
      ^ Source code comment is empty.
    RUBY
  end

  it 'registers an offense when using multiline empty comments' do
    expect_offense(<<-RUBY.strip_indent)
      #
      ^ Source code comment is empty.
      #
      ^ Source code comment is empty.
    RUBY
  end

  it 'does not register an offense when using comment text' do
    expect_no_offenses(<<-RUBY.strip_indent)
      # Description of `Foo` class.
      class Foo
        # Description of `hello` method.
        def hello
        end
      end
    RUBY
  end

  it 'does not register an offense when using comment text with ' \
     'leading and trailing blank lines' do
    expect_no_offenses(<<-RUBY.strip_indent)
      #
      # Description of `Foo` class.
      #
      class Foo
        #
        # Description of `hello` method.
        #
        def hello
        end
      end
    RUBY
  end

  it 'does not register an offense when using border comment' do
    expect_no_offenses(<<-RUBY.strip_indent)
      #################################
    RUBY
  end

  it 'autocorrects empty comment' do
    new_source = autocorrect_source(<<-RUBY.strip_indent)
      #
      class Foo
        #
        def hello
        end
      end
    RUBY

    expect(new_source).to eq <<-RUBY.strip_indent
      class Foo
        def hello
        end
      end
    RUBY
  end
end
