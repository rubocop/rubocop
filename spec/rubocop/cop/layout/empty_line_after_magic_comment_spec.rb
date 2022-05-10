# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::EmptyLineAfterMagicComment, :config do
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

  it 'registers an offense when code that immediately follows typed comment' do
    expect_offense(<<~RUBY)
      # typed: true
      class Foo; end
      ^ Add an empty line after magic comments.
    RUBY

    expect_correction(<<~RUBY)
      # typed: true

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

  it 'accepts magic comment followed by encoding' do
    expect_no_offenses(<<~RUBY)
      # frozen_string_literal: true
      # encoding: utf-8

      class Foo; end
    RUBY
  end

  it 'accepts magic comment with shareable_constant_value' do
    expect_no_offenses(<<~RUBY)
      # frozen_string_literal: true
      # shareable_constant_value: literal

      class Foo; end
    RUBY

    expect_no_offenses(<<~RUBY)
      # shareable_constant_value: experimental_everything
      # frozen_string_literal: true

      class Foo; end
    RUBY
  end

  it 'accepts magic comment with typed' do
    expect_no_offenses(<<~RUBY)
      # frozen_string_literal: true
      # typed: true

      class Foo; end
    RUBY

    expect_no_offenses(<<~RUBY)
      # typed: true
      # frozen_string_literal: true

      class Foo; end
    RUBY
  end

  it 'registers offense when frozen_string_literal used with shareable_constant_value without empty line' do
    expect_offense(<<~RUBY)
      # frozen_string_literal: true
      # shareable_constant_value: none
      class Foo; end
      ^ Add an empty line after magic comments.
    RUBY

    expect_correction(<<~RUBY)
      # frozen_string_literal: true
      # shareable_constant_value: none

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
