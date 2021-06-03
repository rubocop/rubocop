# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::OrderedMagicComments, :config do
  it 'registers an offense and corrects when an `encoding` magic comment ' \
     'does not precede all other magic comments' do
    expect_offense(<<~RUBY)
      # frozen_string_literal: true
      # encoding: ascii
      ^^^^^^^^^^^^^^^^^ The encoding magic comment should precede all other magic comments.
    RUBY

    expect_correction(<<~RUBY)
      # encoding: ascii
      # frozen_string_literal: true
    RUBY
  end

  it 'registers an offense and corrects when `coding` magic comment ' \
     'does not precede all other magic comments' do
    expect_offense(<<~RUBY)
      # frozen_string_literal: true
      # coding: ascii
      ^^^^^^^^^^^^^^^ The encoding magic comment should precede all other magic comments.
    RUBY

    expect_correction(<<~RUBY)
      # coding: ascii
      # frozen_string_literal: true
    RUBY
  end

  it 'registers an offense and corrects when `-*- encoding : ascii-8bit -*-` ' \
     'magic comment does not precede all other magic comments' do
    expect_offense(<<~RUBY)
      # frozen_string_literal: true
      # -*- encoding : ascii-8bit -*-
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ The encoding magic comment should precede all other magic comments.
    RUBY

    expect_correction(<<~RUBY)
      # -*- encoding : ascii-8bit -*-
      # frozen_string_literal: true
    RUBY
  end

  it 'registers an offense and corrects when using `frozen_string_literal` ' \
     'magic comment is next of shebang' do
    expect_offense(<<~RUBY)
      #!/usr/bin/env ruby
      # frozen_string_literal: true
      # encoding: ascii
      ^^^^^^^^^^^^^^^^^ The encoding magic comment should precede all other magic comments.
    RUBY

    expect_correction(<<~RUBY)
      #!/usr/bin/env ruby
      # encoding: ascii
      # frozen_string_literal: true
    RUBY
  end

  it 'does not register an offense when using `encoding` magic comment is first line' do
    expect_no_offenses(<<~RUBY)
      # encoding: ascii
      # frozen_string_literal: true
    RUBY
  end

  it 'does not register an offense when using `encoding` magic comment is next of shebang' do
    expect_no_offenses(<<~RUBY)
      #!/usr/bin/env ruby
      # encoding: ascii
      # frozen_string_literal: true
    RUBY
  end

  it 'does not register an offense when using `encoding` magic comment only' do
    expect_no_offenses(<<~RUBY)
      # encoding: ascii
    RUBY
  end

  it 'does not register an offense when using `frozen_string_literal` magic comment only' do
    expect_no_offenses(<<~RUBY)
      # frozen_string_literal: true
    RUBY
  end

  it 'does not register an offense when using ' \
     '`encoding: Encoding::SJIS` Hash notation after' \
     '`frozen_string_literal` magic comment' do
    expect_no_offenses(<<~RUBY)
      # frozen_string_literal: true

      x = { encoding: Encoding::SJIS }
      puts x
    RUBY
  end
end
