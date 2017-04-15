# frozen_string_literal: true

describe RuboCop::Cop::Offense do
  let(:location) do
    source_buffer = Parser::Source::Buffer.new('test', 1)
    source_buffer.source = "a\n"
    Parser::Source::Range.new(source_buffer, 0, 1)
  end

  subject(:offense) do
    described_class.new(:convention, location, 'message', 'CopName', :corrected)
  end

  it 'has a few required attributes' do
    expect(offense.severity).to eq(:convention)
    expect(offense.line).to eq(1)
    expect(offense.message).to eq('message')
    expect(offense.cop_name).to eq('CopName')
    expect(offense.corrected?).to be_truthy
    expect(offense.highlighted_area.source).to eq('a')
  end

  it 'overrides #to_s' do
    expect(offense.to_s).to eq('C:  1:  1: message')
  end

  it 'does not blow up if a message contains %' do
    offense = described_class.new(:convention, location, 'message % test',
                                  'CopName')

    expect(offense.to_s).to eq('C:  1:  1: message % test')
  end

  it 'redefines == to compare offenses based on their contents' do
    o1 = described_class.new(:convention, location, 'message', 'CopName')
    o2 = described_class.new(:convention, location, 'message', 'CopName')

    expect(o1 == o2).to be_truthy
  end

  it 'is frozen' do
    expect(offense).to be_frozen
  end

  %i[severity location message cop_name].each do |a|
    describe "##{a}" do
      it 'is frozen' do
        expect(offense.send(a)).to be_frozen
      end
    end
  end

  context 'when unknown severity is passed' do
    it 'raises error' do
      expect do
        described_class.new(:foobar, location, 'message', 'CopName')
      end.to raise_error(ArgumentError)
    end
  end

  describe '#severity_level' do
    subject(:severity_level) do
      described_class.new(severity, location, 'message', 'CopName')
                     .severity
                     .level
    end

    context 'when severity is :refactor' do
      let(:severity) { :refactor }
      it 'is 1' do
        expect(severity_level).to eq(1)
      end
    end

    context 'when severity is :fatal' do
      let(:severity) { :fatal }
      it 'is 5' do
        expect(severity_level).to eq(5)
      end
    end
  end

  describe '#<=>' do
    def offense(hash = {})
      attrs = {
        sev:  :convention,
        line: 5,
        col:  5,
        mes:  'message',
        cop:  'CopName'
      }.merge(hash)

      described_class.new(
        attrs[:sev],
        location(attrs[:line], attrs[:col],
                 %w[aaaaaa bbbbbb cccccc dddddd eeeeee ffffff]),
        attrs[:mes],
        attrs[:cop]
      )
    end

    def location(line, column, source)
      source_buffer = Parser::Source::Buffer.new('test', 1)
      source_buffer.source = source.join("\n")
      begin_pos = source[0...(line - 1)].reduce(0) do |a, e|
        a + e.length + 1
      end + column
      Parser::Source::Range.new(source_buffer, begin_pos, begin_pos + 1)
    end

    # We want a nice table layout, so we allow space inside empty hashes.
    # rubocop:disable Layout/SpaceInsideHashLiteralBraces, Layout/ExtraSpacing
    [
      [{                           }, {                           }, 0],

      [{ line: 6                   }, { line: 5                   }, 1],

      [{ line: 5, col: 6           }, { line: 5, col: 5           }, 1],
      [{ line: 6, col: 4           }, { line: 5, col: 5           }, 1],

      [{                  cop: 'B' }, {                  cop: 'A' }, 1],
      [{ line: 6,         cop: 'A' }, { line: 5,         cop: 'B' }, 1],
      [{          col: 6, cop: 'A' }, {          col: 5, cop: 'B' }, 1]
    ].each do |one, other, expectation|
      context "when receiver has #{one} and other has #{other}" do
        it "returns #{expectation}" do
          an_offense = offense(one)
          other_offense = offense(other)
          expect(an_offense <=> other_offense).to eq(expectation)
        end
      end
    end
  end

  context 'offenses that span multiple lines' do
    let(:location) do
      source_buffer = Parser::Source::Buffer.new('test', 1)
      source_buffer.source = <<-END.strip_indent
        def foo
          something
          something_else
        end
      END
      Parser::Source::Range.new(source_buffer, 0, source_buffer.source.length)
    end

    subject(:offense) do
      described_class
        .new(:convention, location, 'message', 'CopName', :corrected)
    end

    it 'highlights the first line' do
      expect(offense.location.source).to eq(location.source_buffer.source)
      expect(offense.highlighted_area.source).to eq('def foo')
    end
  end

  context 'offenses that span part of a line' do
    let(:location) do
      source_buffer = Parser::Source::Buffer.new('test', 1)
      source_buffer.source = <<-END.strip_indent
        def Foo
          something
          something_else
        end
      END
      Parser::Source::Range.new(source_buffer, 4, 7)
    end

    subject(:offense) do
      described_class
        .new(:convention, location, 'message', 'CopName', :corrected)
    end

    it 'highlights the first line' do
      expect(offense.highlighted_area.source).to eq('Foo')
    end
  end
end
