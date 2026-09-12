# frozen_string_literal: true

RSpec.describe RuboCop::Cop::CopDocumentation do
  subject(:sections) { described_class.new(cop_class).sections }

  context 'with a cop that documents examples' do
    let(:cop_class) { RuboCop::Cop::Style::StringLiterals }

    it 'reads the prose above the class as the details' do
      expect(sections.first).to match(
        ['Details', include('Checks if uses of quotes match the configured preference.')]
      )
    end

    it 'gives each example its own section, keeping the example title' do
      titles = sections.map(&:first)

      expect(titles).to include('Example: EnforcedStyle: single_quotes (default)')
      expect(titles).to include('Example: EnforcedStyle: double_quotes')
    end

    it 'keeps the example body verbatim' do
      body = sections.find { |title, _| title.start_with?('Example') }.last

      expect(body).to include('  # bad')
      expect(body).to include('  "No special symbols"')
    end
  end

  context 'with a cop that documents its safety' do
    let(:cop_class) { RuboCop::Cop::Style::FrozenStringLiteralComment }

    it 'gives the safety note its own section' do
      expect(sections.map(&:first)).to include('Safety')
    end
  end

  context 'with a cop class that has no name' do
    let(:cop_class) { instance_double(Class, name: nil) }

    it 'has nothing to report rather than raising' do
      expect(sections).to eq([])
    end
  end
end
