# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::EmptyLineAfterMagicComment do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it 'registers an offense for code that immediately follows comment' do
    expect_offense(<<~RUBY)
      # frozen_string_literal: true
      class Foo; end
      ^ Add an empty line after magic comments.
    RUBY

    expect_correction(<<~RUBY)
      # frozen_string_literal: true

      class Foo; end
    RUBY
  end

  it 'registers an offense for documentation immediately following comment' do
    expect_offense(<<~RUBY)
      # frozen_string_literal: true
      # Documentation for Foo
      ^ Add an empty line after magic comments.
      class Foo; end
    RUBY

    expect_correction(<<~RUBY)
      # frozen_string_literal: true

      # Documentation for Foo
      class Foo; end
    RUBY
  end

  it 'registers an offense when multiple magic comments without empty line' do
    expect_offense(<<~RUBY)
      # encoding: utf-8
      # frozen_string_literal: true
      class Foo; end
      ^ Add an empty line after magic comments.
    RUBY

    expect_correction(<<~RUBY)
      # encoding: utf-8
      # frozen_string_literal: true

      class Foo; end
    RUBY
  end

  it 'accepts code that separates the comment from the code with a newline' do
    expect_no_offenses(<<~RUBY)
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
end
