# frozen_string_literal: true

describe RuboCop::Cop::Layout::EmptyLineAfterMagicComment do
  let(:config) { RuboCop::Config.new }
  subject(:cop) { described_class.new(config) }

  it 'registers an offense for code that immediately follows comment' do
    expect_offense(<<-RUBY.strip_indent)
      # frozen_string_literal: true
      class Foo; end
      ^ Add an empty line after magic comments.
    RUBY
  end

  it 'registers an offense for documentation immediately following comment' do
    expect_offense(<<-RUBY.strip_indent)
      # frozen_string_literal: true
      # Documentation for Foo
      ^ Add an empty line after magic comments.
      class Foo; end
    RUBY
  end

  it 'registers an offense when multiple magic comments without empty line' do
    expect_offense(<<-RUBY.strip_indent)
      # encoding: utf-8
      # frozen_string_literal: true
      class Foo; end
      ^ Add an empty line after magic comments.
    RUBY
  end

  it 'accepts code that separates the comment from the code with a newline' do
    expect_no_offenses(<<-RUBY.strip_indent)
      # frozen_string_literal: true

      class Foo; end
    RUBY
  end

  it 'accepts an empty source file' do
    expect_no_offenses('')
  end

  it 'accepts a source file with only a magic comment' do
    expect_no_offenses('# frozen_string_literal: true')
  end

  it 'autocorrects by adding a newline' do
    new_source = autocorrect_source(cop, <<-RUBY.strip_indent)
      # frozen_string_literal: true
      class Foo; end
    RUBY

    expect(new_source).to eq(<<-RUBY.strip_indent)
      # frozen_string_literal: true\n
      class Foo; end
    RUBY
  end

  it 'autocorrects by adding a newline above the documentation' do
    new_source = autocorrect_source(cop, <<-RUBY.strip_indent)
      # frozen_string_literal: true
      # Documentation for Foo
      class Foo; end
    RUBY

    expect(new_source).to eq(<<-RUBY.strip_indent)
      # frozen_string_literal: true

      # Documentation for Foo
      class Foo; end
    RUBY
  end
end
