# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Team do
  subject(:team) { described_class.new(cop_classes, config, options) }
  let(:cop_classes) { Rubocop::Cop::Cop.non_rails }
  let(:config) { Rubocop::ConfigLoader.default_configuration }
  let(:options) { nil }

  describe '#autocorrect?' do
    subject { team.autocorrect? }

    context 'when the option argument of .new is omitted' do
      subject { described_class.new(cop_classes, config).autocorrect? }
      it { should be_false }
    end

    context 'when { auto_correct: true } is passed to .new' do
      let(:options) { { auto_correct: true } }
      it { should be_true }
    end
  end

  describe '#debug?' do
    subject { team.debug? }

    context 'when the option argument of .new is omitted' do
      subject { described_class.new(cop_classes, config).debug? }
      it { should be_false }
    end

    context 'when { debug: true } is passed to .new' do
      let(:options) { { debug: true } }
      it { should be_true }
    end
  end

  describe '#inspect_file', :isolated_environment do
    include FileHelper

    let(:file_path) { 'example.rb' }
    let(:offences) { team.inspect_file(file_path) }

    before do
      create_file(file_path, [
        '#' * 90,
        'puts test;'
      ])
    end

    it 'returns offences' do
      expect(offences).not_to be_empty
      expect(offences.all? { |o| o.is_a?(Rubocop::Cop::Offence) }).to be_true
    end

    context 'when Parser cannot parse the file' do
      before do
        create_file(file_path, [
          '#' * 90,
          'class Test'
        ])
      end

      it 'returns only error offences' do
        expect(offences.size).to eq(1)
        offence = offences.first
        expect(offence.cop_name).to eq('Syntax')
        expect(offence.severity).to eq(:error)
      end
    end

    context 'when Parser reports non-fatal warning for the file' do
      before do
        create_file(file_path, [
          '# encoding: utf-8',
          '#' * 90,
          'puts *test'
        ])
      end

      let(:cop_names) { offences.map(&:cop_name) }

      it 'returns Parser warning offences' do
        expect(cop_names).to include('AmbiguousOperator')
      end

      it 'returns offences from cops' do
        expect(cop_names).to include('LineLength')
      end
    end

    context 'when autocorrection is enabled' do
      let(:options) { { auto_correct: true } }

      before do
        create_file(file_path, [
          '# encoding: utf-8',
          'puts "string"'
        ])
      end

      it 'does autocorrection' do
        team.inspect_file(file_path)
        corrected_source = File.read(file_path)
        expect(corrected_source).to eq([
          '# encoding: utf-8',
          "puts 'string'",
          ''
        ].join("\n"))
      end

      it 'still returns offences' do
        expect(offences.first.cop_name).to eq('StringLiterals')
      end
    end
  end

  describe '#cops' do
    subject(:cops) { team.cops }

    it 'returns cop instances' do
      expect(cops).not_to be_empty
      expect(cops.all? { |c| c.is_a?(Rubocop::Cop::Cop) }).to be_true
    end

    context 'when only some cop classes are passed to .new' do
      let(:cop_classes) do
        [Rubocop::Cop::Lint::Void, Rubocop::Cop::Style::LineLength]
      end

      it 'returns only intances of the classes' do
        expect(cops.size).to eq(2)
        cops.sort! { |a, b| a.name <=> b.name }
        expect(cops[0].name).to eq('LineLength')
        expect(cops[1].name).to eq('Void')
      end
    end

    context 'when some classes are disabled with config' do
      before do
        %w(Void LineLength).each do |cop_name|
          config.for_cop(cop_name)['Enabled'] = false
        end
      end

      let(:cop_names) { cops.map(&:name) }

      it 'does not return intances of the classes' do
        expect(cops).not_to be_empty
        expect(cop_names).not_to include('Void')
        expect(cop_names).not_to include('LineLength')
      end
    end
  end
end
