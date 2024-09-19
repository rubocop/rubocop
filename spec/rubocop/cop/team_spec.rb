# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Team do
  subject(:team) { described_class.mobilize(cop_classes, config, options) }

  let(:cop_classes) { RuboCop::Cop::Registry.global }
  let(:config) { RuboCop::ConfigLoader.default_configuration }
  let(:options) { {} }
  let(:ruby_version) { RuboCop::TargetRuby.supported_versions.last }

  before { RuboCop::ConfigLoader.default_configuration = nil }

  context 'when incompatible cops are correcting together' do
    include FileHelper

    let(:options) { { formatters: [], autocorrect: true } }
    let(:runner) { RuboCop::Runner.new(options, RuboCop::ConfigStore.new) }
    let(:file_path) { 'example.rb' }

    it 'autocorrects without SyntaxError', :isolated_environment do
      source = <<~'RUBY'
        foo.map{ |a| a.nil? }

        puts 'foo' +
             'bar' +
             "#{baz}"

        i+1

        def a
          self::b
        end
      RUBY
      corrected = <<~'RUBY'
        # frozen_string_literal: true

        foo.map(&:nil?)

        puts 'foo' \
             'bar' \
             "#{baz}"

        i

        def a
          b
        end
      RUBY

      create_file(file_path, source)
      runner.run([])
      expect(File.read(file_path)).to eq(corrected)
    end
  end

  describe '#autocorrect?' do
    subject { team.autocorrect? }

    context 'when the option argument of .mobilize is omitted' do
      subject { described_class.mobilize(cop_classes, config).autocorrect? }

      it { is_expected.to be_falsey }
    end

    context 'when { autocorrect: true } is passed to .mobilize' do
      let(:options) { { autocorrect: true } }

      it { is_expected.to be_truthy }
    end
  end

  describe '#debug?' do
    subject { team.debug? }

    context 'when the option argument of .mobilize is omitted' do
      subject { described_class.mobilize(cop_classes, config).debug? }

      it { is_expected.to be_falsey }
    end

    context 'when { debug: true } is passed to .mobilize' do
      let(:options) { { debug: true } }

      it { is_expected.to be_truthy }
    end
  end

  describe '#inspect_file', :isolated_environment do
    include FileHelper

    let(:file_path) { 'example.rb' }
    let(:source) do
      source = RuboCop::ProcessedSource.from_file(
        file_path, ruby_version, parser_engine: parser_engine
      )
      source.config = config
      source.registry = RuboCop::Cop::Registry.new(cop_classes.cops)
      source
    end
    let(:offenses) { team.inspect_file(source) }

    before { create_file(file_path, ['#' * 90, 'puts test;']) }

    it 'returns offenses' do
      expect(offenses).not_to be_empty
      expect(offenses).to all(be_a(RuboCop::Cop::Offense))
    end

    context 'when Parser reports non-fatal warning for the file' do
      before { create_file(file_path, ['#' * 130, 'puts *test']) }

      let(:cop_names) { offenses.map(&:cop_name) }

      it 'returns Parser warning offenses' do
        expect(cop_names).to include('Lint/AmbiguousOperator')
      end

      it 'returns offenses from cops' do
        expect(cop_names).to include('Layout/LineLength')
      end

      context 'when a cop has no interest in the file' do
        it 'returns all offenses except the ones of the cop' do
          allow_any_instance_of(RuboCop::Cop::Layout::LineLength)
            .to receive(:excluded_file?).and_return(true)

          expect(cop_names).to include('Lint/AmbiguousOperator')
          expect(cop_names).not_to include('Layout/LineLength')
        end
      end
    end

    context 'when autocorrection is enabled' do
      let(:options) { { autocorrect: true } }

      before { create_file(file_path, 'puts "string"') }

      it 'does autocorrection' do
        team.inspect_file(source)
        corrected_source = File.read(file_path)
        expect(corrected_source).to eq(<<~RUBY)
          # frozen_string_literal: true
          puts 'string'
        RUBY
      end

      it 'still returns offenses' do
        expect(offenses[1].cop_name).to eq('Style/StringLiterals')
      end
    end

    context 'when autocorrection is enabled and file encoding is mismatch' do
      let(:options) { { autocorrect: true } }

      before do
        create_file(file_path, <<~RUBY)
          # encoding: Shift_JIS
          puts 'Ｔｈｉｓ ｆｉｌｅ ｅｎｃｏｄｉｎｇ ｉｓ ＵＴＦ－８．'
        RUBY
      end

      it 'no error occurs' do
        team.inspect_file(source)

        expect(team.errors).to be_empty
      end
    end

    context 'when Cop#on_* raises an error' do
      include_context 'mock console output'
      before do
        allow_any_instance_of(RuboCop::Cop::Style::NumericLiterals)
          .to receive(:on_int).and_raise(StandardError)

        create_file(file_path, '10_00_000')
      end

      let(:error_message) do
        'An error occurred while Style/NumericLiterals cop was inspecting ' \
          'example.rb:1:0.'
      end

      it 'records Team#errors' do
        team.inspect_file(source)

        expect(team.errors).to eq([error_message])
        expect($stderr.string).to include(error_message)
      end
    end

    context 'when a cops joining forces callback raises an error' do
      include_context 'mock console output'
      before do
        allow_any_instance_of(RuboCop::Cop::Lint::ShadowedArgument)
          .to receive(:after_leaving_scope).and_raise(exception_message)

        create_file(file_path, 'foo { |bar| bar = 42 }')
      end

      let(:options) { { debug: true } }
      let(:exception_message) { 'my message' }
      let(:error_message) do
        'An error occurred while Lint/ShadowedArgument cop was inspecting example.rb.'
      end

      it 'records Team#errors' do
        team.inspect_file(source)

        expect(team.errors).to eq([error_message])
        expect($stderr.string).to include(error_message)
        expect($stdout.string).to include(exception_message)
      end
    end

    context 'when a correction raises an error' do
      include_context 'mock console output'

      before do
        allow(RuboCop::Cop::OrderedGemCorrector).to receive(:correct).and_return(buggy_correction)

        create_file(file_path, <<~RUBY)
          gem 'rubocop'
          gem 'rspec'
        RUBY
      end

      let(:file_path) { 'Gemfile' }

      let(:buggy_correction) { ->(_corrector) { raise cause } }
      let(:options) { { autocorrect: true } }

      let(:cause) { StandardError.new('cause') }

      let(:error_message) do
        'An error occurred while Bundler/OrderedGems cop was inspecting ' \
          'Gemfile.'
      end

      it 'records Team#errors' do
        team.inspect_file(source)
        expect($stderr.string).to include(error_message)
      end
    end

    context 'when done twice', :restore_registry do
      let(:persisting_cop_class) do
        stub_cop_class('Test::Persisting') do
          def self.support_multiple_source?
            true
          end
        end
      end
      let(:cop_classes) { RuboCop::Cop::Registry.new([persisting_cop_class, RuboCop::Cop::Base]) }

      it 'allows cops to get ready' do
        before = team.cops.dup
        team.inspect_file(source)
        team.inspect_file(source)
        expect(team.cops).to contain_exactly(be(before.first), be_a(RuboCop::Cop::Base))
        expect(team.cops.last).not_to be(before.last)
      end
    end
  end

  describe '#cops' do
    subject(:cops) { team.cops }

    it 'returns cop instances' do
      expect(cops).not_to be_empty
      expect(cops).to be_all(RuboCop::Cop::Base)
    end

    context 'when only some cop classes are passed to .new' do
      let(:cop_classes) do
        RuboCop::Cop::Registry.new([RuboCop::Cop::Lint::Void, RuboCop::Cop::Layout::LineLength])
      end

      it 'returns only instances of the classes' do
        expect(cops.size).to eq(2)
        cops.sort_by!(&:name)
        expect(cops[0].name).to eq('Layout/LineLength')
        expect(cops[1].name).to eq('Lint/Void')
      end
    end
  end

  describe '#forces' do
    subject(:forces) { team.forces }

    let(:cop_classes) { RuboCop::Cop::Registry.global }

    it 'returns force instances' do
      expect(forces).not_to be_empty

      expect(forces).to all(be_a(RuboCop::Cop::Force))
    end

    context 'when a cop joined a force' do
      let(:cop_classes) { RuboCop::Cop::Registry.new([RuboCop::Cop::Lint::UselessAssignment]) }

      it 'returns the force' do
        expect(forces.size).to eq(1)
        expect(forces.first).to be_a(RuboCop::Cop::VariableForce)
      end
    end

    context 'when multiple cops joined a same force' do
      let(:cop_classes) do
        RuboCop::Cop::Registry.new(
          [
            RuboCop::Cop::Lint::UselessAssignment,
            RuboCop::Cop::Lint::ShadowingOuterLocalVariable
          ]
        )
      end

      it 'returns only one force instance' do
        expect(forces.size).to eq(1)
      end
    end

    context 'when no cops joined force' do
      let(:cop_classes) { RuboCop::Cop::Registry.new([RuboCop::Cop::Style::For]) }

      it 'returns nothing' do
        expect(forces).to be_empty
      end
    end
  end

  describe '#external_dependency_checksum' do
    let(:cop_classes) { RuboCop::Cop::Registry.new }

    it 'does not error with no cops' do
      expect(team.external_dependency_checksum).to be_a(String)
    end

    context 'when a cop joins' do
      let(:cop_classes) { RuboCop::Cop::Registry.new([RuboCop::Cop::Lint::UselessAssignment]) }

      it 'returns string' do
        expect(team.external_dependency_checksum).to be_a(String)
      end
    end

    context 'when multiple cops join' do
      let(:cop_classes) do
        RuboCop::Cop::Registry.new(
          [
            RuboCop::Cop::Lint::UselessAssignment,
            RuboCop::Cop::Lint::ShadowingOuterLocalVariable
          ]
        )
      end

      it 'returns string' do
        expect(team.external_dependency_checksum).to be_a(String)
      end
    end

    context 'when cop with different checksum joins', :restore_registry do
      before do
        stub_cop_class('Test::CopWithExternalDeps') do
          def external_dependency_checksum
            'something other than nil'
          end
        end
      end

      let(:new_cop_classes) do
        RuboCop::Cop::Registry.new(
          [
            Test::CopWithExternalDeps,
            RuboCop::Cop::Lint::UselessAssignment,
            RuboCop::Cop::Lint::ShadowingOuterLocalVariable
          ]
        )
      end

      it 'has a different checksum for the whole team' do
        original_checksum = team.external_dependency_checksum
        new_team = described_class.mobilize(new_cop_classes, config, options)
        new_checksum = new_team.external_dependency_checksum
        expect(original_checksum).not_to eq(new_checksum)
      end
    end
  end

  describe '.new' do
    it 'calls mobilize when passed classes' do
      expect(described_class).to receive(:mobilize).with(cop_classes, config, options)
      expect do
        described_class.new(cop_classes, config, options)
      end.to output(/Use `Team.mobilize` instead/).to_stderr
    end

    it 'accepts cops directly classes' do
      cop = RuboCop::Cop::Metrics::AbcSize.new
      team = described_class.new([cop], config, options)
      expect(team.cops.first).to equal(cop)
    end
  end
end
