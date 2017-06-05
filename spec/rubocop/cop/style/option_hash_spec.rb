# frozen_string_literal: true

describe RuboCop::Cop::Style::OptionHash, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { { 'SuspiciousParamNames' => ['options'] } }

  let(:source) do
    <<-RUBY.strip_indent
      def some_method(options = {})
        puts some_arg
      end
    RUBY
  end

  it 'registers an offense' do
    inspect_source(cop, source)
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages.first)
      .to eq('Prefer keyword arguments to options hashes.')
    expect(cop.highlights).to eq ['options = {}']
  end

  context 'when the last argument is an options hash named something else' do
    let(:source) do
      <<-RUBY.strip_indent
        def steep(flavor, duration, config={})
          mug = config.fetch(:mug)
          prep(flavor, duration, mug)
        end
      RUBY
    end

    it 'does not register an offense' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def steep(flavor, duration, config={})
          mug = config.fetch(:mug)
          prep(flavor, duration, mug)
        end
      RUBY
    end

    it 'registers an offense when in SuspiciousParamNames list' do
      cop_config['SuspiciousParamNames'] = ['config']

      inspect_source(cop, source)

      expect(cop.offenses.size).to eq(1)
      expect(cop.messages.first)
        .to eq('Prefer keyword arguments to options hashes.')
      expect(cop.highlights).to eq ['config={}']
    end
  end

  context 'when there are no arguments' do
    it 'does not register an offense' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def meditate
          puts true
          puts true
        end
      RUBY
    end
  end

  context 'when the last argument is a non-options-hash optional hash' do
    it 'does not register an offense' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def cook(instructions, ingredients = { hot: [], cold: [] })
          prep(ingredients)
        end
      RUBY
    end
  end
end
