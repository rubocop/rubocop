# frozen_string_literal: true

describe RuboCop::Cop::Layout::EmptyLinesAroundArguments, :config do
  subject(:cop) { described_class.new(config) }

  context 'registers offense' do
    it 'when empty line detected at top' do
      inspect_source(<<-RUBY.strip_indent)
        foo(

          bar
        )
      RUBY
      expect(cop.messages)
        .to eq(['Empty line detected around arguments.'])
    end

    it 'when empty line detected at bottom' do
      inspect_source(<<-RUBY.strip_indent)
        bar(
          [baz, qux]

        )
      RUBY
      expect(cop.messages)
        .to eq(['Empty line detected around arguments.'])
    end

    it 'when empty line detected in the middle' do
      inspect_source(<<-RUBY.strip_indent)
        do_something(
          baz,

          qux: 0
        )
      RUBY
      expect(cop.messages)
        .to eq(['Empty line detected around arguments.'])
    end

    it 'when multiple empty lines are detected' do
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

    it 'when args start on defintion line' do
      inspect_source(<<-RUBY.strip_indent)
        foo(biz,

            baz: 0)
      RUBY
      expect(cop.messages)
        .to eq(['Empty line detected around arguments.'])
    end

    it 'when empty line before a block argument' do
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
  end

  context 'does not register offense' do
    it 'for one line methods' do
      inspect_source(<<-RUBY.strip_indent)
        foo(bar)
      RUBY
      expect(cop.offenses.empty?).to be(true)
    end

    it 'for multiple correctly listed mixed args' do
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

    it 'for correctly listed args starting on defintion line' do
      inspect_source(<<-RUBY.strip_indent)
        foo(bar,
            [],
            qux: 2)
      RUBY
      expect(cop.offenses.empty?).to be(true)
    end

    it 'when passed block argument with empty line' do
      inspect_source(<<-RUBY.strip_indent)
        Foo.prepend(Module.new do
          def something; end

          def anything; end
        end)
      RUBY
      expect(cop.offenses.empty?).to be(true)
    end
  end

  context 'autocorrects' do
    it 'when empty line detected at top' do
      corrected = autocorrect_source(['foo(',
                                      '',
                                      '  bar',
                                      ')'].join("\n"))
      expect(corrected).to eq ['foo(',
                               '  bar',
                               ')'].join("\n")
    end

    it 'when empty line detected at bottom' do
      corrected = autocorrect_source(['foo(',
                                      '  baz: 1',
                                      '',
                                      ')'].join("\n"))
      expect(corrected).to eq ['foo(',
                               '  baz: 1',
                               ')'].join("\n")
    end

    it 'when empty line detected in the middle' do
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

    it 'when multiple empty lines are detected' do
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

    it 'when args start on defintion line' do
      corrected = autocorrect_source(['bar(qux,',
                                      '',
                                      '    78)'].join("\n"))
      expect(corrected).to eq ['bar(qux,',
                               '    78)'].join("\n")
    end
  end
end
