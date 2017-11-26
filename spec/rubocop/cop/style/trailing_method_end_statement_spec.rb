# frozen_string_literal: true

describe RuboCop::Cop::Style::TrailingMethodEndStatement do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    RuboCop::Config.new('Layout/IndentationWidth' => { 'Width' => 2 })
  end

  it 'register offense with trailing end on 2 line method' do
    expect_offense(<<-RUBY.strip_indent)
      def some_method
      foo; end
           ^^^ Place the end statement of a multi-line method on its own line.
    RUBY
  end

  it 'register offense with trailing end on 3 line method' do
    expect_offense(<<-RUBY.strip_indent)
      def a
        b
      { foo: bar }; end
                    ^^^ Place the end statement of a multi-line method on its own line.
    RUBY
  end

  it 'register offense with trailing end on method with comment' do
    expect_offense(<<-RUBY.strip_indent)
      def c
        b = calculation
        [b] end # because b
            ^^^ Place the end statement of a multi-line method on its own line.
    RUBY
  end

  it 'register offense with trailing end on method with block' do
    expect_offense(<<-RUBY.strip_indent)
      def d
        block do
          foo
        end end
            ^^^ Place the end statement of a multi-line method on its own line.
    RUBY
  end

  it 'does not register on single line no op' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def no_op; end
    RUBY
  end

  it 'does not register on single line method' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def something; do_stuff; end
    RUBY
  end

  it 'auto-corrects trailing end in 2 line method' do
    corrected = autocorrect_source(['  def some_method',
                                    '    []; end'].join("\n"))
    expect(corrected).to eq ['  def some_method',
                             '    [] ',
                             '  end'].join("\n")
  end

  it 'auto-corrects trailing end in 3 line method' do
    corrected = autocorrect_source(['  def do_this(x)',
                                    '    y = x + 5',
                                    '  y / 2; end'].join("\n"))
    expect(corrected).to eq ['  def do_this(x)',
                             '    y = x + 5',
                             '  y / 2 ',
                             '  end'].join("\n")
  end

  it 'auto-corrects trailing end with comment' do
    corrected = autocorrect_source(['  def f(x, y)',
                                    '    process(x)',
                                    '    process(y) end # comment'].join("\n"))
    expect(corrected).to eq ['  def f(x, y)',
                             '    process(x)',
                             '    process(y) ',
                             '  end # comment'].join("\n")
  end

  it 'auto-corrects trailing end on method with block' do
    corrected = autocorrect_source(['  def d',
                                    '    block do',
                                    '      foo',
                                    '    end end'].join("\n"))
    expect(corrected).to eq ['  def d',
                             '    block do',
                             '      foo',
                             '    end ',
                             '  end'].join("\n")
  end
end
