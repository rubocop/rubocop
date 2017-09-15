# frozen_string_literal: true

describe RuboCop::Cop::Style::Encoding, :config do
  subject(:cop) { described_class.new(config) }

  it 'registers no offense when no encoding present' do
    inspect_source('def foo() end')

    expect(cop.offenses.empty?).to be(true)
  end

  it 'registers no offense when encoding present but not UTF-8' do
    inspect_source(<<-RUBY.strip_indent)
      # encoding: us-ascii
      def foo() end
    RUBY

    expect(cop.offenses.empty?).to be(true)
  end

  it 'registers an offense when encoding present and UTF-8' do
    inspect_source(<<-RUBY.strip_indent)
      # encoding: utf-8
      def foo() end
    RUBY

    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(
      ['Unnecessary utf-8 encoding comment.']
    )
  end

  it 'registers an offense when encoding present on 2nd line after shebang' do
    inspect_source(<<-RUBY.strip_indent)
      #!/usr/bin/env ruby
      # encoding: utf-8
      def foo() end
    RUBY

    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(
      ['Unnecessary utf-8 encoding comment.']
    )
  end

  it 'registers an offense for vim-style encoding comments' do
    inspect_source(<<-RUBY.strip_indent)
      # vim:filetype=ruby, fileencoding=utf-8
      def foo() end
    RUBY

    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(
      ['Unnecessary utf-8 encoding comment.']
    )
  end

  it 'registers no offense when encoding is in the wrong place' do
    inspect_source(<<-RUBY.strip_indent)
      def foo() end
      # encoding: utf-8
    RUBY

    expect(cop.offenses.empty?).to be(true)
  end

  it 'registers an offense for encoding inserted by magic_encoding gem' do
    inspect_source(<<-RUBY.strip_indent)
      # -*- encoding : utf-8 -*-
      def foo() 'ä' end
    RUBY

    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(
      ['Unnecessary utf-8 encoding comment.']
    )
  end

  context 'auto-correct' do
    it 'removes encoding comment on first line' do
      new_source = autocorrect_source("# encoding: utf-8\nblah")

      expect(new_source).to eq('blah')
    end
  end
end
