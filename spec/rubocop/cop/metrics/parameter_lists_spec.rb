# frozen_string_literal: true

describe RuboCop::Cop::Metrics::ParameterLists, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) do
    {
      'Max' => 4,
      'CountKeywordArgs' => true
    }
  end

  it 'registers an offense for a method def with 5 parameters' do
    inspect_source(cop, <<-RUBY.strip_indent)
      def meth(a, b, c, d, e)
      end
    RUBY
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(
      ['Avoid parameter lists longer than 4 parameters. [5/4]']
    )
    expect(cop.config_to_allow_offenses).to eq('Max' => 5)
  end

  it 'accepts a method def with 4 parameters' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def meth(a, b, c, d)
      end
    RUBY
  end

  context 'When CountKeywordArgs is true' do
    it 'counts keyword arguments as well' do
      expect_offense(<<-RUBY.strip_indent)
        def meth(a, b, c, d: 1, e: 2)
                ^^^^^^^^^^^^^^^^^^^^^ Avoid parameter lists longer than 4 parameters. [5/4]
        end
      RUBY
    end
  end

  context 'When CountKeywordArgs is false' do
    before { cop_config['CountKeywordArgs'] = false }

    it 'does not count keyword arguments' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def meth(a, b, c, d: 1, e: 2)
        end
      RUBY
    end

    it 'does not count keyword arguments without default values', ruby: 2.1 do
      inspect_source(cop, <<-RUBY.strip_indent)
        def meth(a, b, c, d:, e:)
        end
      RUBY
      expect(cop.offenses).to be_empty
    end
  end
end
