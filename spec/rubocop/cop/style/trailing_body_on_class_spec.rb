# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::TrailingBodyOnClass do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    RuboCop::Config.new('Layout/IndentationWidth' => { 'Width' => 2 })
  end

  it 'registers an offense when body trails after class definition' do
    expect_offense(<<-RUBY.strip_indent)
      class Foo; body
                 ^^^^ Place the first line of class body on its own line.
      end
      class Bar; def bar; end
                 ^^^^^^^^^^^^ Place the first line of class body on its own line.
      end
    RUBY
  end

  it 'registers offense with multi-line class' do
    expect_offense(<<-RUBY.strip_indent)
      class Foo; body
                 ^^^^ Place the first line of class body on its own line.
        def bar
          qux
        end
      end
    RUBY
  end

  it 'accepts regular class' do
    expect_no_offenses(<<-RUBY.strip_indent)
      class Foo
        def no_op; end
      end
    RUBY
  end

  it 'accepts class inheritance' do
    expect_no_offenses(<<-RUBY.strip_indent)
      class Foo < Bar
      end
    RUBY
  end

  it 'auto-corrects body after class definition' do
    corrected = autocorrect_source(['class Foo; body ',
                                    'end'].join("\n"))
    expect(corrected).to eq ['class Foo ',
                             '  body ',
                             'end'].join("\n")
  end

  it 'auto-corrects with comment after body' do
    corrected = autocorrect_source(['class BarQux; foo # comment',
                                    'end'].join("\n"))
    expect(corrected).to eq ['# comment',
                             'class BarQux ',
                             '  foo ',
                             'end'].join("\n")
  end

  it 'auto-corrects when there are multiple semicolons' do
    corrected = autocorrect_source(['class Bar; def bar; end',
                                    'end'].join("\n"))
    expect(corrected).to eq ['class Bar ',
                             '  def bar; end',
                             'end'].join("\n")
  end

  context 'when class is not on first line of processed_source' do
    it 'auto-correct offense' do
      corrected = autocorrect_source(['',
                                      '  class Foo; body ',
                                      '  end'].join("\n"))
      expect(corrected).to eq ['',
                               '  class Foo ',
                               '    body ',
                               '  end'].join("\n")
    end
  end
end
