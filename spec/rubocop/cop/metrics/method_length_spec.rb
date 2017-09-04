# frozen_string_literal: true

describe RuboCop::Cop::Metrics::MethodLength, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { { 'Max' => 5, 'CountComments' => false } }

  shared_examples 'reports violation' do |first_line, last_line|
    it 'rejects a method with more than 5 lines' do
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.map(&:line)).to contain_exactly(first_line)
      expect(cop.config_to_allow_offenses).to eq('Max' => 6)
      expect(cop.messages.first).to eq('Method has too many lines. [6/5]')
    end

    it 'reports the correct beginning and end lines' do
      offense = cop.offenses.first
      expect(offense.location.first_line).to eq(first_line)
      expect(offense.location.last_line).to eq(last_line)
    end
  end

  context 'when method is an instance method' do
    before do
      inspect_source(<<-RUBY.strip_indent)
        def m()
          a = 1
          a = 2
          a = 3
          a = 4
          a = 5
          a = 6
        end
      RUBY
    end

    include_examples 'reports violation', 1, 8
  end

  context 'when method is defined with `define_method`' do
    before do
      inspect_source(<<-RUBY.strip_indent)
        define_method(:m) do
          a = 1
          a = 2
          a = 3
          a = 4
          a = 5
          a = 6
        end
      RUBY
    end

    include_examples 'reports violation', 1, 8
  end

  context 'when method is a class method' do
    before do
      inspect_source(<<-RUBY.strip_indent)
        def self.m()
          a = 1
          a = 2
          a = 3
          a = 4
          a = 5
          a = 6
        end
      RUBY
    end

    include_examples 'reports violation', 1, 8
  end

  context 'when method is defined on a singleton class' do
    before do
      inspect_source(<<-RUBY.strip_indent)
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
      RUBY
    end

    include_examples 'reports violation', 3, 10
  end

  it 'accepts a method with less than 5 lines' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def m()
        a = 1
        a = 2
        a = 3
        a = 4
      end
    RUBY
  end

  it 'accepts a method with multiline arguments ' \
     'and less than 5 lines of body' do
    inspect_source(<<-RUBY.strip_indent)
      def m(x,
            y,
            z)
        a = 1
        a = 2
        a = 3
        a = 4
      end
    RUBY
    expect(cop.offenses).to be_empty
  end

  it 'does not count blank lines' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def m()
        a = 1
        a = 2
        a = 3
        a = 4


        a = 7
      end
    RUBY
  end

  it 'accepts empty methods' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def m()
      end
    RUBY
  end

  it 'is not fooled by one-liner methods, syntax #1' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def one_line; 10 end
      def self.m()
        a = 1
        a = 2
        a = 4
        a = 5
        a = 6
      end
    RUBY
  end

  it 'is not fooled by one-liner methods, syntax #2' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def one_line(test) 10 end
      def self.m()
        a = 1
        a = 2
        a = 4
        a = 5
        a = 6
      end
    RUBY
  end

  it 'properly counts lines when method ends with block' do
    inspect_source(<<-RUBY.strip_indent)
      def m()
        something do
          a = 2
          a = 3
          a = 4
          a = 5
        end
      end
    RUBY
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.map(&:line).sort).to eq([1])
  end

  it 'does not count commented lines by default' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def m()
        a = 1
        #a = 2
        a = 3
        #a = 4
        a = 5
        a = 6
      end
    RUBY
  end

  context 'when CountComments is enabled' do
    before { cop_config['CountComments'] = true }

    it 'also counts commented lines' do
      inspect_source(<<-RUBY.strip_indent)
        def m()
          a = 1
          #a = 2
          a = 3
          #a = 4
          a = 5
          a = 6
        end
      RUBY
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.map(&:line).sort).to eq([1])
    end
  end
end
