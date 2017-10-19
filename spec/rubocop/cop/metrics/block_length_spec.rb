# frozen_string_literal: true

describe RuboCop::Cop::Metrics::BlockLength, :config do
  subject(:cop) { described_class.new(config) }

  let(:cop_config) { { 'Max' => 2, 'CountComments' => false } }

  it 'rejects a block with more than 5 lines' do
    inspect_source(<<-RUBY.strip_indent)
      something do
        a = 1
        a = 2
        a = 3
      end
    RUBY
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.map(&:line).sort).to eq([1])
    expect(cop.config_to_allow_offenses).to eq('Max' => 3)
    expect(cop.messages.first).to eq('Block has too many lines. [3/2]')
  end

  it 'reports the correct beginning and end lines' do
    inspect_source(<<-RUBY.strip_indent)
      something do
        a = 1
        a = 2
        a = 3
      end
    RUBY
    offense = cop.offenses.first
    expect(offense.location.first_line).to eq(1)
    expect(offense.location.last_line).to eq(5)
  end

  it 'accepts a block with less than 3 lines' do
    expect_no_offenses(<<-RUBY.strip_indent)
      something do
        a = 1
        a = 2
      end
    RUBY
  end

  it 'does not count blank lines' do
    expect_no_offenses(<<-RUBY.strip_indent)
      something do
        a = 1


        a = 4
      end
    RUBY
  end

  it 'accepts a block with multiline receiver and less than 3 lines of body' do
    expect_no_offenses(<<-RUBY.strip_indent)
      [
        :a,
        :b,
        :c,
      ].each do
        a = 1
        a = 2
      end
    RUBY
  end

  it 'accepts empty blocks' do
    expect_no_offenses(<<-RUBY.strip_indent)
      something do
      end
    RUBY
  end

  it 'rejects brace blocks too' do
    inspect_source(<<-RUBY.strip_indent)
      something {
        a = 1
        a = 2
        a = 3
      }
    RUBY
    expect(cop.offenses.size).to eq(1)
  end

  it 'properly counts nested blocks' do
    inspect_source(<<-RUBY.strip_indent)
      something do
        something do
          a = 2
          a = 3
          a = 4
          a = 5
        end
      end
    RUBY
    expect(cop.offenses.size).to eq(2)
    expect(cop.offenses.map(&:line).sort).to eq([1, 2])
  end

  it 'does not count commented lines by default' do
    expect_no_offenses(<<-RUBY.strip_indent)
      something do
        a = 1
        #a = 2
        #a = 3
        a = 4
      end
    RUBY
  end

  context 'when CountComments is enabled' do
    before { cop_config['CountComments'] = true }

    it 'also counts commented lines' do
      inspect_source(<<-RUBY.strip_indent)
        something do
          a = 1
          #a = 2
          a = 3
        end
      RUBY
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.map(&:line).sort).to eq([1])
    end
  end

  context 'when foo method is excluded is enabled' do
    before { cop_config['ExcludedMethods'] = ['foo'] }

    it 'still rejects other methods with long blocks' do
      inspect_source(<<-RUBY.strip_indent)
        something do
          a = 1
          a = 2
          a = 3
        end
      RUBY
      expect(cop.offenses.empty?).to be(false)
    end

    it 'accepts the foo method with a long block' do
      expect_no_offenses(<<-RUBY.strip_indent)
        foo do
          a = 1
          a = 2
          a = 3
        end
      RUBY
    end
  end
end
