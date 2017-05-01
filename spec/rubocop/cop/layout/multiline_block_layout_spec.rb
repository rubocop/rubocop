# frozen_string_literal: true

describe RuboCop::Cop::Layout::MultilineBlockLayout do
  subject(:cop) { described_class.new }

  it 'registers an offense for missing newline in do/end block w/o params' do
    inspect_source(cop, <<-END.strip_indent)
      test do foo
      end
    END
    expect(cop.messages)
      .to eq(['Block body expression is on the same line as the block start.'])
  end

  it 'registers an offense for missing newline in {} block w/o params' do
    inspect_source(cop, <<-END.strip_indent)
      test { foo
      }
    END
    expect(cop.messages)
      .to eq(['Block body expression is on the same line as the block start.'])
  end

  it 'registers an offense for missing newline in do/end block with params' do
    inspect_source(cop, <<-END.strip_indent)
      test do |x| foo
      end
    END
    expect(cop.messages)
      .to eq(['Block body expression is on the same line as the block start.'])
  end

  it 'registers an offense for missing newline in {} block with params' do
    inspect_source(cop, <<-END.strip_indent)
      test { |x| foo
      }
    END
    expect(cop.messages)
      .to eq(['Block body expression is on the same line as the block start.'])
  end

  it 'does not register an offense for one-line do/end blocks' do
    expect_no_offenses('test do foo end')
  end

  it 'does not register an offense for one-line {} blocks' do
    expect_no_offenses('test { foo }')
  end

  it 'does not register offenses when there is a newline for do/end block' do
    inspect_source(cop, <<-END.strip_indent)
      test do
        foo
      end
    END
    expect(cop.offenses).to be_empty
  end

  it 'does not error out when the block is empty' do
    inspect_source(cop, <<-END.strip_indent)
      test do |x|
      end
    END
    expect(cop.offenses).to be_empty
  end

  it 'does not register offenses when there is a newline for {} block' do
    inspect_source(cop, <<-END.strip_indent)
      test {
        foo
      }
    END
    expect(cop.offenses).to be_empty
  end

  it 'registers offenses for lambdas as expected' do
    inspect_source(cop, <<-END.strip_indent)
      -> (x) do foo
        bar
      end
    END
    expect(cop.messages)
      .to eq(['Block body expression is on the same line as the block start.'])
  end

  it 'registers offenses for new lambda literal syntax as expected' do
    inspect_source(cop, <<-END.strip_indent)
      -> x do foo
        bar
      end
    END
    expect(cop.messages)
      .to eq(['Block body expression is on the same line as the block start.'])
  end

  it 'registers an offense for line-break before arguments' do
    inspect_source(cop, <<-END.strip_indent)
      test do
        |x| play_with(x)
      end
    END
    expect(cop.messages)
      .to eq(['Block argument expression is not on the same line as the ' \
              'block start.'])
  end

  it 'registers an offense for line-break before arguments with empty block' do
    inspect_source(cop, <<-END.strip_indent)
      test do
        |x|
      end
    END
    expect(cop.messages)
      .to eq(['Block argument expression is not on the same line as the ' \
              'block start.'])
  end

  it 'registers an offense for line-break within arguments' do
    inspect_source(cop, <<-END.strip_indent)
      test do |x,
        y|
      end
    END
    expect(cop.messages)
      .to eq(['Block argument expression is not on the same line as the ' \
              'block start.'])
  end

  it 'auto-corrects a do/end block with params that is missing newlines' do
    src = <<-END.strip_indent
      test do |foo| bar
      end
    END

    new_source = autocorrect_source(cop, src)

    expect(new_source).to eq(['test do |foo| ',
                              '  bar',
                              'end',
                              ''].join("\n"))
  end

  it 'auto-corrects a do/end block with a mult-line body' do
    src = <<-END.strip_indent
      test do |foo| bar
        test
      end
    END

    new_source = autocorrect_source(cop, src)

    expect(new_source).to eq(['test do |foo| ',
                              '  bar',
                              '  test',
                              'end',
                              ''].join("\n"))
  end

  it 'auto-corrects a {} block with params that is missing newlines' do
    src = <<-END.strip_indent
      test { |foo| bar
      }
    END

    new_source = autocorrect_source(cop, src)

    expect(new_source).to eq(['test { |foo| ',
                              '  bar',
                              '}',
                              ''].join("\n"))
  end

  it 'autocorrects in more complex case with lambda and assignment, and '\
     'aligns the next line two spaces out from the start of the block' do
    src = <<-END.strip_indent
      x = -> (y) { foo
        bar
      }
    END

    new_source = autocorrect_source(cop, src)

    expect(new_source).to eq(['x = -> (y) { ',
                              '      foo',
                              '  bar',
                              '}',
                              ''].join("\n"))
  end

  it 'auto-corrects a line-break before arguments' do
    new_source = autocorrect_source(cop, <<-END.strip_indent)
      test do
        |x| play_with(x)
      end
    END

    expect(new_source).to eq(<<-END.strip_indent)
      test do |x|
        play_with(x)
      end
    END
  end

  it 'auto-corrects a line-break before arguments with empty block' do
    new_source = autocorrect_source(cop, <<-END.strip_indent)
      test do
        |x|
      end
    END

    expect(new_source).to eq(<<-END.strip_indent)
      test do |x|
      end
    END
  end

  it 'auto-corrects a line-break within arguments' do
    new_source = autocorrect_source(cop, <<-END.strip_indent)
      test do |x,
        y| play_with(x, y)
      end
    END
    expect(new_source).to eq(<<-END.strip_indent)
      test do |x, y|
        play_with(x, y)
      end
    END
  end

  it 'auto-corrects a line break within destructured arguments' do
    new_source = autocorrect_source(cop, <<-END.strip_indent)
      test do |(x,
        y)| play_with(x, y)
      end
    END
    expect(new_source).to eq(<<-END.strip_indent)
      test do |(x, y)|
        play_with(x, y)
      end
    END
  end

  it "doesn't move end keyword in a way which causes infinite loop " \
     'in combination with Style/BlockEndNewLine' do
    new_source = autocorrect_source(cop, <<-END.strip_indent)
      def f
        X.map do |(a,
        b)|
        end
      end
    END
    expect(new_source).to eq(<<-END.strip_indent)
      def f
        X.map do |(a, b)|
        end
      end
    END
  end
end
