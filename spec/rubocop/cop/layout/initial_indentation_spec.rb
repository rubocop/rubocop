# frozen_string_literal: true

describe RuboCop::Cop::Layout::InitialIndentation do
  subject(:cop) { described_class.new }

  it 'registers an offense for indented method definition ' do
    expect_offense(<<-RUBY.strip_margin('|'))
      |  def f
      |  ^^^ Indentation of first line in file detected.
      |  end
    RUBY
  end

  it 'accepts unindented method definition' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def f
      end
    RUBY
  end

  context 'for a file with byte order mark' do
    it 'accepts unindented method call' do
      expect_no_offenses('﻿puts 1')
    end

    it 'registers an offense for indented method call' do
      expect_offense(<<-RUBY.strip_indent)
        ﻿  puts 1
           ^^^^ Indentation of first line in file detected.
      RUBY
    end

    it 'registers an offense for indented method call after comment' do
      expect_offense(<<-RUBY.strip_indent)
        ﻿# comment
          puts 1
          ^^^^ Indentation of first line in file detected.
      RUBY
    end
  end

  it 'accepts empty file' do
    expect_no_offenses('')
  end

  it 'registers an offense for indented assignment disregarding comment' do
    expect_offense(<<-RUBY.strip_margin('|'))
      |   # comment
      |   x = 1
      |   ^ Indentation of first line in file detected.
    RUBY
  end

  it 'accepts unindented comment + assignment' do
    expect_no_offenses(<<-RUBY.strip_indent)
      # comment
      x = 1
    RUBY
  end

  it 'auto-corrects indented method definition' do
    corrected = autocorrect_source(<<-RUBY.strip_margin('|'))
      |  def f
      |  end
    RUBY
    expect(corrected).to eq <<-RUBY.strip_indent
      def f
        end
    RUBY
  end

  it 'auto-corrects indented assignment but not comment' do
    corrected = autocorrect_source(<<-RUBY.strip_margin('|'))
      |  # comment
      |  x = 1
    RUBY
    expect(corrected).to eq <<-RUBY.strip_indent
        # comment
      x = 1
    RUBY
  end
end
