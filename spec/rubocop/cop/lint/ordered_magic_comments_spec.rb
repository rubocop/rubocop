# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::OrderedMagicComments, :config do
  subject(:cop) { described_class.new(config) }

  it 'registers an offense when `encoding` magic comment does not ' \
     'precede all other magic comments' do
    expect_offense(<<-RUBY.strip_indent)
      # frozen_string_literal: true
      # encoding: ascii
      ^^^^^^^^^^^^^^^^^ The encoding magic comment should precede all other magic comments.
    RUBY
  end

  it 'registers an offense when `coding` magic comment ' \
     'does not precede all other magic comments' do
    expect_offense(<<-RUBY.strip_indent)
      # frozen_string_literal: true
      # coding: ascii
      ^^^^^^^^^^^^^^^ The encoding magic comment should precede all other magic comments.
    RUBY
  end

  it 'registers an offense when `-*- encoding : ascii-8bit -*-` ' \
     'magic comment does not precede all other magic comments' do
    expect_offense(<<-RUBY.strip_indent)
      # frozen_string_literal: true
      # -*- encoding : ascii-8bit -*-
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ The encoding magic comment should precede all other magic comments.
    RUBY
  end

  it 'registers an offense when using `frozen_string_literal` magic comment ' \
     'is next of shebang' do
    expect_offense(<<-RUBY.strip_indent)
      #!/usr/bin/env ruby
      # frozen_string_literal: true
      # encoding: ascii
      ^^^^^^^^^^^^^^^^^ The encoding magic comment should precede all other magic comments.
    RUBY
  end

  it 'does not register an offense when using `encoding` magic comment ' \
     'is first line' do
    expect_no_offenses(<<-RUBY.strip_indent)
      # encoding: ascii
      # frozen_string_literal: true
    RUBY
  end

  it 'does not register an offense when using `encoding` magic comment ' \
     'is next of shebang' do
    expect_no_offenses(<<-RUBY.strip_indent)
      #!/usr/bin/env ruby
      # encoding: ascii
      # frozen_string_literal: true
    RUBY
  end

  it 'does not register an offense when using `encoding` magic comment only' do
    expect_no_offenses(<<-RUBY.strip_indent)
      # encoding: ascii
    RUBY
  end

  it 'does not register an offense when using `frozen_string_literal` ' \
     'magic comment only' do
    expect_no_offenses(<<-RUBY.strip_indent)
      # frozen_string_literal: true
    RUBY
  end

  it 'autocorrects ordered magic comments' do
    new_source = autocorrect_source(<<-RUBY.strip_indent)
      # frozen_string_literal: true
      # encoding: ascii
    RUBY

    expect(new_source).to eq <<-RUBY.strip_indent
      # encoding: ascii
      # frozen_string_literal: true
    RUBY
  end

  it 'autocorrects ordered magic comments with shebang' do
    new_source = autocorrect_source(<<-RUBY.strip_indent)
      #!/usr/bin/env ruby
      # frozen_string_literal: true
      # encoding: ascii
    RUBY

    expect(new_source).to eq <<-RUBY.strip_indent
      #!/usr/bin/env ruby
      # encoding: ascii
      # frozen_string_literal: true
    RUBY
  end
end
