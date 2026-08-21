# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::MisplacedMagicComment, :config do
  it 'registers an offense for an encoding comment below a documentation comment' do
    expect_offense(<<~RUBY)
      # Documentation comment
      # encoding: ascii-8bit
      ^^^^^^^^^^^^^^^^^^^^^^ The `encoding` magic comment is ignored unless placed on the first line (or below a shebang on the first line).
      puts 'hello'
    RUBY

    expect_correction(<<~RUBY)
      # encoding: ascii-8bit
      # Documentation comment
      puts 'hello'
    RUBY
  end

  it 'registers an offense for an encoding comment below a blank line' do
    expect_offense(<<~RUBY)

      # encoding: ascii-8bit
      ^^^^^^^^^^^^^^^^^^^^^^ The `encoding` magic comment is ignored unless placed on the first line (or below a shebang on the first line).
      puts 'hello'
    RUBY
  end

  it 'registers an offense for an encoding comment on the third line below a shebang' do
    expect_offense(<<~RUBY)
      #!/usr/bin/env ruby
      # Documentation comment
      # encoding: ascii-8bit
      ^^^^^^^^^^^^^^^^^^^^^^ The `encoding` magic comment is ignored unless placed on the first line (or below a shebang on the first line).
      puts 'hello'
    RUBY

    expect_correction(<<~RUBY)
      #!/usr/bin/env ruby
      # encoding: ascii-8bit
      # Documentation comment
      puts 'hello'
    RUBY
  end

  it 'registers an offense for a `frozen_string_literal` comment after code' do
    expect_offense(<<~RUBY)
      require 'foo'
      # frozen_string_literal: true
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ The `frozen_string_literal` magic comment is ignored after any code.
    RUBY

    expect_correction(<<~RUBY)
      # frozen_string_literal: true
      require 'foo'
    RUBY
  end

  it 'registers an offense for a trailing `frozen_string_literal` comment on a code line' do
    expect_offense(<<~RUBY)
      require 'foo' # frozen_string_literal: true
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ The `frozen_string_literal` magic comment is ignored after any code.
    RUBY
  end

  it 'registers an offense for a magic comment above a shebang' do
    expect_offense(<<~RUBY)
      # frozen_string_literal: true
      #!/usr/bin/env ruby
      ^^^^^^^^^^^^^^^^^^^ A magic comment above a shebang renders the shebang ineffective.
      puts 'hello'
    RUBY
  end

  it 'does not register an offense for prose that starts with `Encoding:`' do
    expect_no_offenses(<<~RUBY)
      case enc
      when Encoding, false, nil
        # Encoding: force given encoding
        # false/nil: do not force encoding
      end
    RUBY
  end

  it 'does not register an offense for an encoding comment on the first line' do
    expect_no_offenses(<<~RUBY)
      # encoding: ascii-8bit
      puts 'hello'
    RUBY
  end

  it 'does not register an offense for an encoding comment below a shebang' do
    expect_no_offenses(<<~RUBY)
      #!/usr/bin/env ruby
      # encoding: ascii-8bit
      puts 'hello'
    RUBY
  end

  it 'does not register an offense for an encoding comment below other magic comments' do
    # Lint/OrderedMagicComments already handles reordering magic comments.
    expect_no_offenses(<<~RUBY)
      # frozen_string_literal: true
      # encoding: ascii-8bit
      puts 'hello'
    RUBY
  end

  it 'does not register an offense for `frozen_string_literal` below a documentation comment' do
    # Ruby honors `frozen_string_literal` anywhere before the first code token.
    expect_no_offenses(<<~RUBY)
      # Copyright Acme Corp.
      # frozen_string_literal: true
      puts 'hello'
    RUBY
  end

  it 'does not register an offense for `frozen_string_literal` below a blank line' do
    expect_no_offenses(<<~RUBY)

      # frozen_string_literal: true
      puts 'hello'
    RUBY
  end

  it 'does not register an offense for `frozen_string_literal` below a `=begin` block' do
    expect_no_offenses(<<~RUBY)
      =begin
      docs
      =end
      # frozen_string_literal: true
      puts 'hello'
    RUBY
  end

  it 'does not register an offense for `shareable_constant_value` after code' do
    # `shareable_constant_value` is scoped and legal mid-file.
    expect_no_offenses(<<~RUBY)
      A = ['a']
      # shareable_constant_value: literal
      X = ['a']
    RUBY
  end

  it 'does not register an offense for an empty file' do
    expect_no_offenses('')
  end

  it 'does not register an offense for an all-comments file' do
    expect_no_offenses(<<~RUBY)
      # frozen_string_literal: true
      # just comments here
    RUBY
  end
end
