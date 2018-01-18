# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::TrailingBodyOnModule do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    RuboCop::Config.new('Layout/IndentationWidth' => { 'Width' => 2 })
  end

  it 'registers an offense when body trails after module definition' do
    expect_offense(<<-RUBY.strip_indent)
      module Foo body
                 ^^^^ Place the first line of module body on its own line.
      end
      module Bar extend self
                 ^^^^^^^^^^^ Place the first line of module body on its own line.
      end
    RUBY
  end

  it 'registers offense with multi-line module' do
    expect_offense(<<-RUBY.strip_indent)
      module Foo body
                 ^^^^ Place the first line of module body on its own line.
        def bar
          qux
        end
      end
    RUBY
  end

  it 'registers offense when module definition uses semicolon' do
    expect_offense(<<-RUBY.strip_indent)
      module Foo; do_stuff
                  ^^^^^^^^ Place the first line of module body on its own line.
      end
    RUBY
  end

  it 'accepts regular module' do
    expect_no_offenses(<<-RUBY.strip_indent)
      module Foo
        def no_op; end
      end
    RUBY
  end

  it 'auto-corrects body after module definition' do
    corrected = autocorrect_source(['module Foo extend self ',
                                    'end'].join("\n"))
    expect(corrected).to eq ['module Foo ',
                             '  extend self ',
                             'end'].join("\n")
  end

  it 'auto-corrects with comment after body' do
    corrected = autocorrect_source(['module BarQux; foo # comment',
                                    'end'].join("\n"))
    expect(corrected).to eq ['# comment',
                             'module BarQux ',
                             '  foo ',
                             'end'].join("\n")
  end

  it 'auto-corrects when there are multiple semicolons' do
    corrected = autocorrect_source(['module Bar; def bar; end',
                                    'end'].join("\n"))
    expect(corrected).to eq ['module Bar ',
                             '  def bar; end',
                             'end'].join("\n")
  end

  context 'when module is not on first line of processed_source' do
    it 'auto-correct offense' do
      corrected = autocorrect_source(['',
                                      '  module Foo; body ',
                                      '  end'].join("\n"))
      expect(corrected).to eq ['',
                               '  module Foo ',
                               '    body ',
                               '  end'].join("\n")
    end
  end
end
