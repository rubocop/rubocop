# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::InitialIndentation, :config do
  it 'registers an offense for indented method definition' do
    expect_offense(<<-RUBY.strip_margin('|'))
    |  def f
    |  ^^^ Indentation of first line in file detected.
    |  end
    RUBY

    expect_correction(<<-RUBY.strip_margin('|'))
    |def f
    |  end
    RUBY
  end

  it 'accepts unindented method definition' do
    expect_no_offenses(<<~RUBY)
      def f
      end
    RUBY
  end

  context 'for a file with byte order mark' do
    it 'accepts unindented method call' do
      expect_no_offenses('﻿puts 1')
    end

    it 'registers an offense and corrects indented method call' do
      expect_offense(<<~RUBY)
        ﻿  puts 1
           ^^^^ Indentation of first line in file detected.
      RUBY

      expect_correction(<<~RUBY)
        ﻿puts 1
      RUBY
    end

    it 'registers an offense and corrects indented method call after comment' do
      expect_offense(<<~RUBY)
        ﻿# comment
          puts 1
          ^^^^ Indentation of first line in file detected.
      RUBY

      expect_correction(<<~RUBY)
        ﻿# comment
        puts 1
      RUBY
    end
  end

  it 'accepts empty file' do
    expect_no_offenses('')
  end

  it 'registers an offense and corrects indented assignment disregarding comment' do
    expect_offense(<<-RUBY.strip_margin('|'))
    |   # comment
    |   x = 1
    |   ^ Indentation of first line in file detected.
    RUBY

    expect_correction(<<-RUBY.strip_margin('|'))
    |   # comment
    |x = 1
    RUBY
  end

  it 'accepts unindented comment + assignment' do
    expect_no_offenses(<<~RUBY)
      # comment
      x = 1
    RUBY
  end
end
