# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::EmptyLinesAroundArguments, :config do
  subject(:cop) { described_class.new(config) }

  context 'when extra lines' do
    it 'registers offense for empty line before arg' do
      inspect_source(<<-RUBY.strip_indent)
        foo(

          bar
        )
      RUBY
      expect(cop.messages)
        .to eq(['Empty line detected around arguments.'])
    end

    it 'registers offense for empty line after arg' do
      inspect_source(<<-RUBY.strip_indent)
        bar(
          [baz, qux]

        )
      RUBY
      expect(cop.messages)
        .to eq(['Empty line detected around arguments.'])
    end

    it 'registers offense for empty line between args' do
      inspect_source(<<-RUBY.strip_indent)
        foo.do_something(
          baz,

          qux: 0
        )
      RUBY
      expect(cop.messages)
        .to eq(['Empty line detected around arguments.'])
    end

    it 'registers offense for empty line in-between one arg' do
      inspect_source(<<-RUBY.strip_indent)
        do_stuff([
          "some text",

          "some more text"
        ])
      RUBY
      expect(cop.messages)
        .to eq(['Empty line detected around arguments.'])
    end

    it 'registers offenses when multiple empty lines are detected' do
      inspect_source(<<-RUBY.strip_indent)
        foo(
          baz,

          qux,

          biz,

        )
      RUBY
      expect(cop.offenses.size).to eq 3
      expect(cop.messages.uniq)
        .to eq(['Empty line detected around arguments.'])
    end

    it 'registers offense when args start on definition line' do
      inspect_source(<<-RUBY.strip_indent)
        foo(biz,

            baz: 0)
      RUBY
      expect(cop.messages)
        .to eq(['Empty line detected around arguments.'])
    end

    it 'registers offense when empty line between normal arg & block arg' do
      inspect_source(<<-RUBY.strip_indent)
        Foo.prepend(
          a,

          Module.new do
            def something; end

            def anything; end
          end
        )
      RUBY
      expect(cop.offenses.size).to eq 1
      expect(cop.messages)
        .to eq(['Empty line detected around arguments.'])
    end

    it 'registers offense on correct line for single offense example' do
      inspect_source(<<-RUBY.strip_indent)
        class Foo

          include Bar

          def baz(qux)
            fizz(
              qux,

              10
            )
          end
        end
      RUBY
      expect(cop.offenses.size).to eq 1
      expect(cop.offenses.first.location.line).to eq 8
      expect(cop.messages.uniq)
        .to eq(['Empty line detected around arguments.'])
    end

    it 'registers offense on correct lines for multi-offense example' do
      inspect_source(<<-RUBY.strip_indent)
        something(1, 5)
        something_else

        foo(biz,

            qux)

        quux.map do

        end.another.thing(

          [baz]
        )
      RUBY
      expect(cop.offenses.size).to eq 2
      expect(cop.offenses[0].location.line).to eq 5
      expect(cop.offenses[1].location.line).to eq 11
      expect(cop.messages.uniq)
        .to eq(['Empty line detected around arguments.'])
    end

    it 'autocorrects empty line detected at top' do
      corrected = autocorrect_source(['foo(',
                                      '',
                                      '  bar',
                                      ')'].join("\n"))
      expect(corrected).to eq ['foo(',
                               '  bar',
                               ')'].join("\n")
    end

    it 'autocorrects empty line detected at bottom' do
      corrected = autocorrect_source(['foo(',
                                      '  baz: 1',
                                      '',
                                      ')'].join("\n"))
      expect(corrected).to eq ['foo(',
                               '  baz: 1',
                               ')'].join("\n")
    end

    it 'autocorrects empty line detected in the middle' do
      corrected = autocorrect_source(['do_something(',
                                      '  [baz],',
                                      '',
                                      '  qux: 0',
                                      ')'].join("\n"))
      expect(corrected).to eq ['do_something(',
                               '  [baz],',
                               '  qux: 0',
                               ')'].join("\n")
    end

    it 'autocorrects empty line in-between one arg' do
      corrected = autocorrect_source(['do_stuff([',
                                      "  'some text',",
                                      '',
                                      "  'some more text'",
                                      '])'].join("\n"))
      expect(corrected).to eq ['do_stuff([',
                               "  'some text',",
                               "  'some more text'",
                               '])'].join("\n")
    end

    it 'autocorrects multiple empty lines' do
      corrected = autocorrect_source(['do_stuff(',
                                      '  baz,',
                                      '',
                                      '  qux,',
                                      '',
                                      '  bar: 0,',
                                      '',
                                      ')'].join("\n"))
      expect(corrected).to eq ['do_stuff(',
                               '  baz,',
                               '  qux,',
                               '  bar: 0,',
                               ')'].join("\n")
    end

    it 'autocorrects args that start on definition line' do
      corrected = autocorrect_source(['bar(qux,',
                                      '',
                                      '    78)'].join("\n"))
      expect(corrected).to eq ['bar(qux,',
                               '    78)'].join("\n")
    end
  end

  context 'when no extra lines' do
    it 'accpets one line methods' do
      inspect_source(<<-RUBY.strip_indent)
        foo(bar)
      RUBY
      expect(cop.offenses.empty?).to be(true)
    end

    it 'accepts multiple listed mixed args' do
      inspect_source(<<-RUBY.strip_indent)
        foo(
          bar,
          [],
          baz = nil,
          qux: 2
        )
      RUBY
      expect(cop.offenses.empty?).to be(true)
    end

    it 'accepts listed args starting on defintion line' do
      inspect_source(<<-RUBY.strip_indent)
        foo(bar,
            [],
            qux: 2)
      RUBY
      expect(cop.offenses.empty?).to be(true)
    end

    it 'accepts block argument with empty line' do
      inspect_source(<<-RUBY.strip_indent)
        Foo.prepend(Module.new do
          def something; end

          def anything; end
        end)
      RUBY
      expect(cop.offenses.empty?).to be(true)
    end

    it 'accepts method with argument that trails off block' do
      inspect_source(<<-RUBY.strip_indent)
        fred.map do
          <<-EOT
            bar

            foo
          EOT
        end.join("\n")
      RUBY
      expect(cop.offenses.empty?).to be(true)
    end

    it 'accepts method with no arguments that trails off block' do
      inspect_source(<<-RUBY.strip_indent)
        foo.baz do

          bar
        end.compact
      RUBY
      expect(cop.offenses.empty?).to be(true)
    end
  end
end
