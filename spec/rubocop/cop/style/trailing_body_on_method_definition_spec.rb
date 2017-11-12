# frozen_string_literal: true

describe RuboCop::Cop::Style::TrailingBodyOnMethodDefinition do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    RuboCop::Config.new('Layout/IndentationWidth' => { 'Width' => 2 })
  end

  it 'registers an offense when body trails after method definition' do
    expect_offense(<<-RUBY.strip_indent)
      def some_method; body
      ^^^^^^^^^^^^^^^^^^^^^ Method body goes below definition.
      end
      def extra_large; { size: 15 };
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Method body goes below definition.
      end
      def seven_times(stuff) 7.times { do_this(stuff) }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Method body goes below definition.
      end
    RUBY
  end

  it 'registers when body starts on def line & continues one more line' do
    expect_offense(<<-RUBY.strip_indent)
      def some_method; foo = {}
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Method body goes below definition.
        more_body(foo)
      end
    RUBY
  end

  it 'registers when body starts on def line & continues many more lines' do
    expect_offense(<<-RUBY.strip_indent)
      def do_stuff(thing) process(thing)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Method body goes below definition.
        8.times { thing + 9 }
        even_more(thing)
      end
    RUBY
  end

  it 'accepts a method with one line of body' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def some_method
        body
      end
    RUBY
  end

  it 'accepts a method with multiple lines of body' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def stuff_method
        stuff
        9.times { process(stuff) }
        more_stuff
      end
    RUBY
  end

  it 'does not register offense with trailing body on method end' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def some_method
        body
      foo; end
    RUBY
  end

  it 'auto-corrects body after method definition' do
    corrected = autocorrect_source(['  def some_method; body',
                                    '  end'].join("\n"))
    expect(corrected).to eq ['  def some_method; ',
                             '    body',
                             '  end'].join("\n")
  end

  it 'auto-corrects with comment after body' do
    corrected = autocorrect_source(['  def some_method; body # stuff',
                                    '  end'].join("\n"))
    expect(corrected).to eq ['  # stuff',
                             '  def some_method; ',
                             '    body ',
                             '  end'].join("\n")
  end

  it 'auto-corrects body with method definition with args in parens' do
    corrected = autocorrect_source(['  def some_method(arg1, arg2) body',
                                    '  end'].join("\n"))
    expect(corrected).to eq ['  def some_method(arg1, arg2) ',
                             '    body',
                             '  end'].join("\n")
  end

  it 'auto-corrects body with method definition with args not in parens' do
    corrected = autocorrect_source(['  def some_method arg1, arg2; body',
                                    '  end'].join("\n"))
    expect(corrected).to eq ['  def some_method arg1, arg2; ',
                             '    body',
                             '  end'].join("\n")
  end

  it 'auto-corrects when body continues on one more line' do
    corrected = autocorrect_source(['  def some_method; body',
                                    '    more_body',
                                    '  end'].join("\n"))
    expect(corrected).to eq ['  def some_method; ',
                             '    body',
                             '    more_body',
                             '  end'].join("\n")
  end

  it 'auto-corrects when body continues on multiple more line' do
    corrected = autocorrect_source(['  def some_method; []',
                                    '    more_body',
                                    '    even_more',
                                    '  end'].join("\n"))
    expect(corrected).to eq ['  def some_method; ',
                             '    []',
                             '    more_body',
                             '    even_more',
                             '  end'].join("\n")
  end
end
