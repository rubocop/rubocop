# frozen_string_literal: true

describe RuboCop::Cop::Cop do
  subject(:cop) { described_class.new }
  let(:location) do
    source_buffer = Parser::Source::Buffer.new('test', 1)
    source_buffer.source = "a\n"
    Parser::Source::Range.new(source_buffer, 0, 1)
  end

  it 'initially has 0 offenses' do
    expect(cop.offenses).to be_empty
  end

  describe '.qualified_cop_name' do
    before do
      $stderr = StringIO.new
    end

    after do
      $stderr = STDERR
    end

    it 'adds namespace if the cop name is found in exactly one namespace' do
      expect(described_class.qualified_cop_name('LineLength', '--only'))
        .to eq('Metrics/LineLength')
    end

    it 'returns the given cop name if it is not found in any namespace' do
      expect(described_class.qualified_cop_name('UnknownCop', '--only'))
        .to eq('UnknownCop')
    end

    it 'returns the given cop name if it already has a namespace' do
      expect(described_class.qualified_cop_name('Metrics/LineLength', '--only'))
        .to eq('Metrics/LineLength')
    end

    it 'returns the cop name in a different namespace if the provided ' \
       'namespace is incorrect' do
      expect(described_class.qualified_cop_name('Style/LineLength', '--only'))
        .to eq('Metrics/LineLength')
    end

    it 'raises an error if the cop name is in more than one namespace' do
      expect { described_class.qualified_cop_name('SafeNavigation', '--only') }
        .to raise_error(RuboCop::Cop::AmbiguousCopName)
    end

    it 'returns the given cop name if it already has a namespace even when ' \
       'the cop exists in multiple namespaces' do
      qualified_cop_name =
        described_class.qualified_cop_name('Style/SafeNavigation', '--only')

      expect(qualified_cop_name).to eq('Style/SafeNavigation')
    end
  end

  it 'keeps track of offenses' do
    cop.add_offense(nil, location, 'message')

    expect(cop.offenses.size).to eq(1)
  end

  it 'will report registered offenses' do
    cop.add_offense(nil, location, 'message')

    expect(cop.offenses).not_to be_empty
  end

  it 'will set default severity' do
    cop.add_offense(nil, location, 'message')

    expect(cop.offenses.first.severity).to eq(:convention)
  end

  it 'will set custom severity if present' do
    cop.config[cop.name] = { 'Severity' => 'warning' }
    cop.add_offense(nil, location, 'message')

    expect(cop.offenses.first.severity).to eq(:warning)
  end

  it 'will warn if custom severity is invalid' do
    cop.config[cop.name] = { 'Severity' => 'superbad' }
    expect(cop).to receive(:warn)
    cop.add_offense(nil, location, 'message')
  end

  it 'registers offense with its name' do
    cop = RuboCop::Cop::Style::For.new
    cop.add_offense(nil, location, 'message')
    expect(cop.offenses.first.cop_name).to eq('Style/For')
  end

  describe 'setting of Offense#corrected attribute' do
    context 'when cop does not support autocorrection' do
      before do
        allow(cop).to receive(:support_autocorrect?).and_return(false)
      end

      it 'is not specified (set to nil)' do
        cop.add_offense(nil, location, 'message')
        expect(cop.offenses.first.corrected?).to be(false)
      end

      context 'when autocorrect is requested' do
        before do
          allow(cop).to receive(:autocorrect_requested?).and_return(true)
        end

        it 'is not specified (set to nil)' do
          cop.add_offense(nil, location, 'message')
          expect(cop.offenses.first.corrected?).to be(false)
        end

        context 'when disable_uncorrectable is enabled' do
          before do
            allow(cop).to receive(:disable_uncorrectable?).and_return(true)
          end

          let(:node) { double(location: double(expression: location)) }

          it 'is set to true' do
            cop.add_offense(node, location, 'message')
            expect(cop.offenses.first.corrected?).to be(true)
          end
        end
      end
    end

    context 'when cop supports autocorrection' do
      let(:cop) { RuboCop::Cop::Style::Alias.new }

      context 'when offense was corrected' do
        before do
          allow(cop).to receive(:autocorrect?).and_return(true)
          allow(cop).to receive(:autocorrect).and_return(->(_corrector) {})
        end

        it 'is set to true' do
          cop.add_offense(nil, location, 'message')
          expect(cop.offenses.first.corrected?).to eq(true)
        end
      end

      context 'when autocorrection is not needed' do
        before do
          allow(cop).to receive(:autocorrect?).and_return(false)
        end

        it 'is set to false' do
          cop.add_offense(nil, location, 'message')
          expect(cop.offenses.first.corrected?).to eq(false)
        end
      end

      context 'when offense was not corrected because of an error' do
        before do
          allow(cop).to receive(:autocorrect?).and_return(true)
          allow(cop).to receive(:autocorrect).and_return(false)
        end

        it 'is set to false' do
          cop.add_offense(nil, location, 'message')
          expect(cop.offenses.first.corrected?).to eq(false)
        end
      end
    end
  end

  context 'with no submodule' do
    subject(:cop) { described_class }
    it('has right name') { expect(cop.cop_name).to eq('Cop/Cop') }
    it('has right department') { expect(cop.department).to eq(:Cop) }
  end

  context 'with style cops' do
    subject(:cop) { RuboCop::Cop::Style::For }
    it('has right name') { expect(cop.cop_name).to eq('Style/For') }
    it('has right department') { expect(cop.department).to eq(:Style) }
  end

  context 'with lint cops' do
    subject(:cop) { RuboCop::Cop::Lint::Loop }
    it('has right name') { expect(cop.cop_name).to eq('Lint/Loop') }
    it('has right department') { expect(cop.department).to eq(:Lint) }
  end

  context 'with rails cops' do
    subject(:cop) { RuboCop::Cop::Rails::Validation }
    it('has right name') { expect(cop.cop_name).to eq('Rails/Validation') }
    it('has right department') { expect(cop.department).to eq(:Rails) }
  end

  describe 'Registry' do
    context '#departments' do
      subject(:departments) { described_class.registry.departments }
      it('has departments') { expect(departments.length).not_to eq(0) }
      it { is_expected.to include(:Lint) }
      it { is_expected.to include(:Rails) }
      it { is_expected.to include(:Style) }

      it 'contains every value only once' do
        expect(departments.length).to eq(departments.uniq.length)
      end
    end

    context '#with_department' do
      let(:departments) { described_class.registry.departments }

      it 'has at least one cop per department' do
        departments.each do |c|
          expect(described_class.registry.with_department(c).length).to be > 0
        end
      end

      it 'has each cop in exactly one type' do
        sum = 0
        departments.each do |c|
          sum += described_class.registry.with_department(c).length
        end
        expect(sum).to be described_class.registry.length
      end

      it 'returns 0 for an invalid type' do
        expect(described_class.registry.with_department('x').length).to be 0
      end
    end
  end

  describe '#autocorrect?' do
    # dummy config for a generic cop instance
    let(:config) { RuboCop::Config.new({}) }
    let(:cop) { described_class.new(config, options) }
    let(:support_autocorrect) { true }
    let(:disable_uncorrectable) { false }
    subject { cop.autocorrect? }

    before do
      allow(cop).to receive(:support_autocorrect?) { support_autocorrect }
      allow(cop).to receive(:disable_uncorrectable?) { disable_uncorrectable }
    end

    context 'when the option is not given' do
      let(:options) { {} }
      it { is_expected.to be(false) }
    end

    context 'when the option is given' do
      let(:options) { { auto_correct: true } }
      it { is_expected.to be(true) }

      context 'when cop does not support autocorrection' do
        let(:support_autocorrect) { false }
        it { is_expected.to be(false) }

        context 'when disable_uncorrectable is enabled' do
          let(:disable_uncorrectable) { true }
          it { is_expected.to be(true) }
        end
      end

      context 'when the cop is set to not autocorrect' do
        let(:config) do
          RuboCop::Config.new('Cop/Cop' => { 'AutoCorrect' => false })
        end
        it { is_expected.to be(false) }
      end
    end
  end
end
