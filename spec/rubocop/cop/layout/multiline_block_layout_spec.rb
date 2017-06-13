# frozen_string_literal: true

describe RuboCop::Cop::Layout::MultilineBlockLayout do
  subject(:cop) { described_class.new }

  it 'registers an offense for missing newline in do/end block w/o params' do
    expect_offense(<<-RUBY.strip_indent)
      test do foo
              ^^^ Block body expression is on the same line as the block start.
      end
    RUBY
  end

  it 'registers an offense for missing newline in {} block w/o params' do
    expect_offense(<<-RUBY.strip_indent)
      test { foo
             ^^^ Block body expression is on the same line as the block start.
      }
    RUBY
  end

  it 'registers an offense for missing newline in do/end block with params' do
    expect_offense(<<-RUBY.strip_indent)
      test do |x| foo
                  ^^^ Block body expression is on the same line as the block start.
      end
    RUBY
  end

  it 'registers an offense for missing newline in {} block with params' do
    expect_offense(<<-RUBY.strip_indent)
      test { |x| foo
                 ^^^ Block body expression is on the same line as the block start.
      }
    RUBY
  end

  it 'does not register an offense for one-line do/end blocks' do
    expect_no_offenses('test do foo end')
  end

  it 'does not register an offense for one-line {} blocks' do
    expect_no_offenses('test { foo }')
  end

  it 'does not register offenses when there is a newline for do/end block' do
    expect_no_offenses(<<-RUBY.strip_indent)
      test do
        foo
      end
    RUBY
  end

  it 'does not error out when the block is empty' do
    expect_no_offenses(<<-RUBY.strip_indent)
      test do |x|
      end
    RUBY
  end

  it 'does not register offenses when there is a newline for {} block' do
    expect_no_offenses(<<-RUBY.strip_indent)
      test {
        foo
      }
    RUBY
  end

  it 'registers offenses for lambdas as expected' do
    expect_offense(<<-RUBY.strip_indent)
      -> (x) do foo
                ^^^ Block body expression is on the same line as the block start.
        bar
      end
    RUBY
  end

  it 'registers offenses for new lambda literal syntax as expected' do
    expect_offense(<<-RUBY.strip_indent)
      -> x do foo
              ^^^ Block body expression is on the same line as the block start.
        bar
      end
    RUBY
  end

  it 'registers an offense for line-break before arguments' do
    expect_offense(<<-RUBY.strip_indent)
      test do
        |x| play_with(x)
        ^^^ Block argument expression is not on the same line as the block start.
      end
    RUBY
  end

  it 'registers an offense for line-break before arguments with empty block' do
    expect_offense(<<-RUBY.strip_indent)
      test do
        |x|
        ^^^ Block argument expression is not on the same line as the block start.
      end
    RUBY
  end

  it 'registers an offense for line-break within arguments' do
    expect_offense(<<-RUBY.strip_indent)
      test do |x,
              ^^^ Block argument expression is not on the same line as the block start.
        y|
      end
    RUBY
  end

  it 'auto-corrects a do/end block with params that is missing newlines' do
    src = <<-RUBY.strip_indent
      test do |foo| bar
      end
    RUBY

    new_source = autocorrect_source(src)

    expect(new_source).to eq(['test do |foo| ',
                              '  bar',
                              'end',
                              ''].join("\n"))
  end

  it 'auto-corrects a do/end block with a mult-line body' do
    src = <<-RUBY.strip_indent
      test do |foo| bar
        test
      end
    RUBY

    new_source = autocorrect_source(src)

    expect(new_source).to eq(['test do |foo| ',
                              '  bar',
                              '  test',
                              'end',
                              ''].join("\n"))
  end

  it 'auto-corrects a {} block with params that is missing newlines' do
    src = <<-RUBY.strip_indent
      test { |foo| bar
      }
    RUBY

    new_source = autocorrect_source(src)

    expect(new_source).to eq(['test { |foo| ',
                              '  bar',
                              '}',
                              ''].join("\n"))
  end

  it 'autocorrects in more complex case with lambda and assignment, and '\
     'aligns the next line two spaces out from the start of the block' do
    src = <<-RUBY.strip_indent
      x = -> (y) { foo
        bar
      }
    RUBY

    new_source = autocorrect_source(src)

    expect(new_source).to eq(['x = -> (y) { ',
                              '      foo',
                              '  bar',
                              '}',
                              ''].join("\n"))
  end

  it 'auto-corrects a line-break before arguments' do
    new_source = autocorrect_source(<<-RUBY.strip_indent)
      test do
        |x| play_with(x)
      end
    RUBY

    expect(new_source).to eq(<<-RUBY.strip_indent)
      test do |x|
        play_with(x)
      end
    RUBY
  end

  it 'auto-corrects a line-break before arguments with empty block' do
    new_source = autocorrect_source(<<-RUBY.strip_indent)
      test do
        |x|
      end
    RUBY

    expect(new_source).to eq(<<-RUBY.strip_indent)
      test do |x|
      end
    RUBY
  end

  it 'auto-corrects a line-break within arguments' do
    new_source = autocorrect_source(<<-RUBY.strip_indent)
      test do |x,
        y| play_with(x, y)
      end
    RUBY
    expect(new_source).to eq(<<-RUBY.strip_indent)
      test do |x, y|
        play_with(x, y)
      end
    RUBY
  end

  it 'auto-corrects a line break within destructured arguments' do
    new_source = autocorrect_source(<<-RUBY.strip_indent)
      test do |(x,
        y)| play_with(x, y)
      end
    RUBY
    expect(new_source).to eq(<<-RUBY.strip_indent)
      test do |(x, y)|
        play_with(x, y)
      end
    RUBY
  end

  it "doesn't move end keyword in a way which causes infinite loop " \
     'in combination with Style/BlockEndNewLine' do
    new_source = autocorrect_source(<<-RUBY.strip_indent)
      def f
        X.map do |(a,
        b)|
        end
      end
    RUBY
    expect(new_source).to eq(<<-RUBY.strip_indent)
      def f
        X.map do |(a, b)|
        end
      end
    RUBY
  end
end
