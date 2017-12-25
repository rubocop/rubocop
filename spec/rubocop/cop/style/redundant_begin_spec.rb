# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantBegin, :config do
  subject(:cop) { described_class.new(config) }

  it 'reports an offense for single line def with redundant begin block' do
    src = '  def func; begin; x; y; rescue; z end end'
    inspect_source(src)
    expect(cop.offenses.size).to eq(1)
  end

  it 'reports an offense for def with redundant begin block' do
    src = <<-RUBY.strip_indent
      def func
        begin
          ala
        rescue => e
          bala
        end
      end
    RUBY
    inspect_source(src)
    expect(cop.offenses.size).to eq(1)
  end

  it 'reports an offense for defs with redundant begin block' do
    src = <<-RUBY.strip_indent
      def Test.func
        begin
          ala
        rescue => e
          bala
        end
      end
    RUBY
    inspect_source(src)
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts a def with required begin block' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def func
        begin
          ala
        rescue => e
          bala
        end
        something
      end
    RUBY
  end

  it 'accepts a defs with required begin block' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def Test.func
        begin
          ala
        rescue => e
          bala
        end
        something
      end
    RUBY
  end

  it 'accepts a def with a begin block after a statement' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def Test.func
        something
        begin
          ala
        rescue => e
          bala
        end
      end
    RUBY
  end

  it 'auto-corrects source separated by newlines ' \
     'by removing redundant begin blocks' do
    src = <<-RUBY.strip_margin('|')
      |  def func
      |    begin
      |      foo
      |      bar
      |    rescue
      |      baz
      |    end
      |  end
    RUBY
    result_src = ['  def func',
                  '    ',
                  '      foo',
                  '      bar',
                  '    rescue',
                  '      baz',
                  '    ',
                  '  end',
                  ''].join("\n")
    new_source = autocorrect_source(src)
    expect(new_source).to eq(result_src)
  end

  it 'auto-corrects source separated by semicolons ' \
     'by removing redundant begin blocks' do
    src = '  def func; begin; x; y; rescue; z end end'
    result_src = '  def func; ; x; y; rescue; z  end'
    new_source = autocorrect_source(src)
    expect(new_source).to eq(result_src)
  end

  it "doesn't modify spacing when auto-correcting" do
    src = <<-RUBY.strip_indent
      def method
        begin
          BlockA do |strategy|
            foo
          end

          BlockB do |portfolio|
            foo
          end

        rescue => e # some problem
          bar
        end
      end
    RUBY

    result_src = ['def method',
                  '  ',
                  '    BlockA do |strategy|',
                  '      foo',
                  '    end',
                  '',
                  '    BlockB do |portfolio|',
                  '      foo',
                  '    end',
                  '',
                  '  rescue => e # some problem',
                  '    bar',
                  '  ',
                  'end',
                  ''].join("\n")
    new_source = autocorrect_source(src)
    expect(new_source).to eq(result_src)
  end

  it 'auto-corrects when there are trailing comments' do
    src = <<-RUBY.strip_indent
      def method
        begin # comment 1
          do_some_stuff
        rescue # comment 2
        end # comment 3
      end
    RUBY
    result_src = <<-RUBY.strip_indent
      def method
         # comment 1
          do_some_stuff
        rescue # comment 2
         # comment 3
      end
    RUBY
    new_source = autocorrect_source(src)
    expect(new_source).to eq(result_src)
  end

  context '< Ruby 2.5', :ruby24 do
    it 'accepts a do-end block with a begin-end' do
      expect_no_offenses(<<-RUBY.strip_indent)
        do_something do
          begin
            foo
          rescue => e
            bar
          end
        end
      RUBY
    end
  end

  context '>= ruby 2.5', :ruby25 do
    it 'registers an offense for a do-end block with redundant begin-end' do
      expect_offense(<<-RUBY.strip_indent)
        do_something do
          begin
          ^^^^^ Redundant `begin` block detected.
            foo
          rescue => e
            bar
          end
        end
      RUBY
    end

    it 'accepts a {} block with a begin-end' do
      expect_no_offenses(<<-RUBY.strip_indent)
        do_something {
          begin
            foo
          rescue => e
            bar
          end
        }
      RUBY
    end

    it 'accepts a block with a begin block after a statement' do
      expect_no_offenses(<<-RUBY.strip_indent)
        do_something do
          something
          begin
            ala
          rescue => e
            bala
          end
        end
      RUBY
    end
  end
end
