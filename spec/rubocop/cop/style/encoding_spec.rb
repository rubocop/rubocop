# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::Encoding, :config do
  subject(:cop) { described_class.new(config) }

  it 'registers no offense when no encoding present' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def foo() end
    RUBY
  end

  it 'registers no offense when encoding present but not UTF-8' do
    expect_no_offenses(<<-RUBY.strip_indent)
      # encoding: us-ascii
      def foo() end
    RUBY
  end

  it 'registers an offense when encoding present and UTF-8' do
    expect_offense(<<-RUBY.strip_indent)
      # encoding: utf-8
      ^^^^^^^^^^^^^^^^^ Unnecessary utf-8 encoding comment.
      def foo() end
    RUBY
  end

  it 'registers an offense when encoding present on 2nd line after shebang' do
    expect_offense(<<-RUBY.strip_indent)
      #!/usr/bin/env ruby
      # encoding: utf-8
      ^^^^^^^^^^^^^^^^^ Unnecessary utf-8 encoding comment.
      def foo() end
    RUBY
  end

  it 'registers an offense for vim-style encoding comments' do
    expect_offense(<<-RUBY.strip_indent)
      # vim:filetype=ruby, fileencoding=utf-8
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unnecessary utf-8 encoding comment.
      def foo() end
    RUBY
  end

  it 'registers no offense when encoding is in the wrong place' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def foo() end
      # encoding: utf-8
    RUBY
  end

  it 'registers an offense for encoding inserted by magic_encoding gem' do
    expect_offense(<<-RUBY.strip_indent)
      # -*- encoding : utf-8 -*-
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Unnecessary utf-8 encoding comment.
      def foo() 'ä' end
    RUBY
  end

  context 'auto-correct' do
    it 'removes encoding comment on first line' do
      new_source = autocorrect_source("# encoding: utf-8\nblah")

      expect(new_source).to eq('blah')
    end
  end
end
