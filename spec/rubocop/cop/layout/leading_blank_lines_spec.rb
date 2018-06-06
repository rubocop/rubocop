# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::LeadingBlankLines, :config do
  subject(:cop) { described_class.new(config) }

  it 'allows an empty input' do
    expect_no_offenses('')
  end

  it 'allows blank lines without any comments or code' do
    expect_no_offenses("\n")
  end

  it 'accepts not having a blank line before a class' do
    expect_no_offenses(<<-RUBY.strip_indent)
      class Foo
      end
    RUBY
  end

  it 'accepts not having a blank line before code' do
    expect_no_offenses(<<-RUBY.strip_indent)
      puts 1
    RUBY
  end

  it 'accepts not having a blank line before a comment' do
    expect_no_offenses(<<-RUBY.strip_indent)
      # something
    RUBY
  end

  it 'registers an offense when there is a new line before a class' do
    expect_offense(<<-RUBY.strip_indent)

      class Foo
      ^^^^^ Unnecessary blank line at the beginning of the source.
      end
    RUBY
  end

  it 'registers an offense when there is a new line before code' do
    expect_offense(<<-RUBY.strip_indent)

      puts 1
      ^^^^ Unnecessary blank line at the beginning of the source.
    RUBY
  end

  it 'registers an offense when there is a new line before a comment' do
    expect_offense(<<-RUBY.strip_indent)

      # something
      ^^^^^^^^^^^ Unnecessary blank line at the beginning of the source.
    RUBY
  end

  context 'auto-correct' do
    it 'removes new lines before a class' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)

        class Foo
        end
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        class Foo
        end
      RUBY
    end

    it 'removes new lines before code' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)

        puts 1
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        puts 1
      RUBY
    end

    it 'removes new lines before a comment' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)

      # something
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
      # something
      RUBY
    end

    it 'removes multiple new lines' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)


        class Foo
        end
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        class Foo
        end
      RUBY
    end
  end
end
