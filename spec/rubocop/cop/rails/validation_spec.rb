# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::Validation do
  subject(:cop) { described_class.new }

  it 'accepts new style validations' do
    expect_no_offenses('validates :name')
  end

  described_class::DENYLIST.each_with_index do |validation, number|
    it "registers an offense for #{validation}" do
      inspect_source("#{validation} :name")
      expect(cop.offenses.size).to eq(1)
    end

    it "outputs the correct message for #{validation}" do
      inspect_source("#{validation} :name")
      expect(cop.offenses.first.message)
        .to include(described_class::ALLOWLIST[number])
    end
  end

  describe '#autocorrect' do
    shared_examples 'auto-corrects' do
      it 'auto-corrects' do
        expect(autocorrect_source(source)).to eq(auto_corrected_source)
      end
    end

    shared_examples 'does not auto-correct' do
      it 'does not auto-correct' do
        expect(autocorrect_source(source)).to eq(source)
      end
    end

    described_class::TYPES.each do |type|
      context "with validates_#{type}_of" do
        let(:auto_corrected_source) do
          "validates :full_name, :birth_date, #{type}: true"
        end

        let(:source) do
          "validates_#{type}_of :full_name, :birth_date"
        end

        include_examples 'auto-corrects'
      end

      context "with validates_#{type}_of " \
              'when method arguments are enclosed in parentheses' do
        let(:auto_corrected_source) do
          "validates(:full_name, :birth_date, #{type}: true)"
        end

        let(:source) do
          "validates_#{type}_of(:full_name, :birth_date)"
        end

        include_examples 'auto-corrects'
      end
    end

    context 'with single attribute name' do
      let(:auto_corrected_source) do
        'validates :a, numericality: true'
      end

      let(:source) do
        'validates_numericality_of :a'
      end

      include_examples 'auto-corrects'
    end

    context 'with multi attribute names' do
      let(:auto_corrected_source) do
        'validates :a, :b, numericality: true'
      end

      let(:source) do
        'validates_numericality_of :a, :b'
      end

      include_examples 'auto-corrects'
    end

    context 'with non-braced hash literal' do
      let(:auto_corrected_source) do
        'validates :a, :b, numericality: { minimum: 1 }'
      end

      let(:source) do
        'validates_numericality_of :a, :b, minimum: 1'
      end

      include_examples 'auto-corrects'
    end

    context 'with braced hash literal' do
      let(:auto_corrected_source) do
        'validates :a, :b, numericality: { minimum: 1 }'
      end

      let(:source) do
        'validates_numericality_of :a, :b, { minimum: 1 }'
      end

      include_examples 'auto-corrects'
    end

    context 'with splat' do
      let(:auto_corrected_source) do
        'validates :a, *b, numericality: true'
      end

      let(:source) do
        'validates_numericality_of :a, *b'
      end

      include_examples 'auto-corrects'
    end

    context 'with splat and options' do
      let(:auto_corrected_source) do
        'validates :a, *b, :c, numericality: { minimum: 1 }'
      end

      let(:source) do
        'validates_numericality_of :a, *b, :c, minimum: 1'
      end

      include_examples 'auto-corrects'
    end

    context 'with trailing send node' do
      let(:source) do
        'validates_numericality_of :a, b'
      end

      include_examples 'does not auto-correct'
    end

    context 'with trailing constant' do
      let(:source) do
        'validates_numericality_of :a, B'
      end

      include_examples 'does not auto-correct'
    end

    context 'with trailing local variable' do
      let(:source) do
        <<-RUBY.strip_indent
          b = { minimum: 1 }
          validates_numericality_of :a, b
        RUBY
      end

      include_examples 'does not auto-correct'
    end
  end
end
