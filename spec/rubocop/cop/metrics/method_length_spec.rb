# frozen_string_literal: true

describe RuboCop::Cop::Metrics::MethodLength, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { { 'Max' => 5, 'CountComments' => false } }

  it 'rejects a method with more than 5 lines' do
    inspect_source(cop, <<-END.strip_indent)
      def m()
        a = 1
        a = 2
        a = 3
        a = 4
        a = 5
        a = 6
      end
    END
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.map(&:line).sort).to eq([1])
    expect(cop.config_to_allow_offenses).to eq('Max' => 6)
    expect(cop.messages.first).to eq('Method has too many lines. [6/5]')
  end

  it 'reports the correct beginning and end lines' do
    inspect_source(cop, <<-END.strip_indent)
      def m()
        a = 1
        a = 2
        a = 3
        a = 4
        a = 5
        a = 6
      end
    END
    offense = cop.offenses.first
    expect(offense.location.first_line).to eq(1)
    expect(offense.location.last_line).to eq(8)
  end

  it 'accepts a method with less than 5 lines' do
    inspect_source(cop, <<-END.strip_indent)
      def m()
        a = 1
        a = 2
        a = 3
        a = 4
      end
    END
    expect(cop.offenses).to be_empty
  end

  it 'accepts a method with multiline arguments ' \
     'and less than 5 lines of body' do
    inspect_source(cop, <<-END.strip_indent)
      def m(x,
            y,
            z)
        a = 1
        a = 2
        a = 3
        a = 4
      end
    END
    expect(cop.offenses).to be_empty
  end

  it 'does not count blank lines' do
    inspect_source(cop, <<-END.strip_indent)
      def m()
        a = 1
        a = 2
        a = 3
        a = 4


        a = 7
      end
    END
    expect(cop.offenses).to be_empty
  end

  it 'accepts empty methods' do
    inspect_source(cop, <<-END.strip_indent)
      def m()
      end
    END
    expect(cop.offenses).to be_empty
  end

  it 'is not fooled by one-liner methods, syntax #1' do
    inspect_source(cop, <<-END.strip_indent)
      def one_line; 10 end
      def self.m()
        a = 1
        a = 2
        a = 4
        a = 5
        a = 6
      end
    END
    expect(cop.offenses).to be_empty
  end

  it 'is not fooled by one-liner methods, syntax #2' do
    inspect_source(cop, <<-END.strip_indent)
      def one_line(test) 10 end
      def self.m()
        a = 1
        a = 2
        a = 4
        a = 5
        a = 6
      end
    END
    expect(cop.offenses).to be_empty
  end

  it 'checks class methods, syntax #1' do
    inspect_source(cop, <<-END.strip_indent)
      def self.m()
        a = 1
        a = 2
        a = 3
        a = 4
        a = 5
        a = 6
      end
    END
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.map(&:line).sort).to eq([1])
  end

  it 'checks class methods, syntax #2' do
    inspect_source(cop, <<-END.strip_indent)
      class K
        class << self
          def m()
            a = 1
            a = 2
            a = 3
            a = 4
            a = 5
            a = 6
          end
        end
      end
    END
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.map(&:line).sort).to eq([3])
  end

  it 'properly counts lines when method ends with block' do
    inspect_source(cop, <<-END.strip_indent)
      def m()
        something do
          a = 2
          a = 3
          a = 4
          a = 5
        end
      end
    END
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.map(&:line).sort).to eq([1])
  end

  it 'does not count commented lines by default' do
    inspect_source(cop, <<-END.strip_indent)
      def m()
        a = 1
        #a = 2
        a = 3
        #a = 4
        a = 5
        a = 6
      end
    END
    expect(cop.offenses).to be_empty
  end

  context 'when CountComments is enabled' do
    before { cop_config['CountComments'] = true }

    it 'also counts commented lines' do
      inspect_source(cop, <<-END.strip_indent)
        def m()
          a = 1
          #a = 2
          a = 3
          #a = 4
          a = 5
          a = 6
        end
      END
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.map(&:line).sort).to eq([1])
    end
  end
end
