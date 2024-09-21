# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Cop, :config do
  let(:source) { 'code = {some: :ruby}' }
  let(:location) { source_range(0...1) }

  before { cop.send(:begin_investigation, processed_source) }

  it 'initially has 0 offenses' do
    expect(cop.offenses).to be_empty
  end

  it 'qualified_cop_name is deprecated' do
    expect { described_class.qualified_cop_name('Layout/LineLength', '--only') }
      .to output(/`Cop.qualified_cop_name` is deprecated/).to_stderr
  end

  describe '.documentation_url' do
    context 'without passing a config' do
      subject(:url) { cop_class.documentation_url }

      describe 'for a builtin cop class' do
        let(:cop_class) { RuboCop::Cop::Layout::BlockEndNewline }

        it { is_expected.to eq 'https://docs.rubocop.org/rubocop/cops_layout.html#layoutblockendnewline' } # rubocop:disable Layout/LineLength
      end

      describe 'for a custom cop class without DocumentationBaseURL', :restore_registry do
        let(:cop_class) { stub_cop_class('Some::Cop') { def foo; end } }

        it { is_expected.to be_nil }
      end
    end

    context 'when passing a config' do
      subject(:url) { cop_class.documentation_url(config) }

      describe 'for a builtin cop class' do
        let(:cop_class) { RuboCop::Cop::Layout::BlockEndNewline }

        it { is_expected.to eq 'https://docs.rubocop.org/rubocop/cops_layout.html#layoutblockendnewline' } # rubocop:disable Layout/LineLength
      end

      describe 'for a custom cop class without DocumentationBaseURL', :restore_registry do
        let(:cop_class) { stub_cop_class('Some::Cop') { def foo; end } }

        it { is_expected.to be_nil }
      end

      describe 'for a custom cop class with DocumentationBaseURL', :restore_registry do
        let(:cop_class) { stub_cop_class('Rails::Exit') { def foo; end } }
        let(:config) do
          RuboCop::Config.new(
            'Rails' => {
              'DocumentationBaseURL' => 'https://docs.rubocop.org/rubocop-rails'
            }
          )
        end

        it { is_expected.to eq 'https://docs.rubocop.org/rubocop-rails/cops_rails.html#railsexit' }
      end

      describe 'for a custom cop class with DocumentationExtension', :restore_registry do
        let(:cop_class) { stub_cop_class('Sorbet::FalseSigil') { def foo; end } }
        let(:config) do
          RuboCop::Config.new(
            'Sorbet' => {
              'DocumentationBaseURL' => 'https://github.com/Shopify/rubocop-sorbet/blob/main/manual',
              'DocumentationExtension' => '.md'
            }
          )
        end

        it { is_expected.to eq 'https://github.com/Shopify/rubocop-sorbet/blob/main/manual/cops_sorbet.md#sorbetfalsesigil' }
      end
    end
  end

  describe 'requires_gem', :restore_registry do
    context 'on a cop with no gem requirements' do
      let(:cop_class) do
        stub_cop_class('CopSpec::CopWithNoGemReqs') do
          # no calls to `require_gem`
        end
      end

      describe '.gem_requirements' do
        it 'returns an empty hash' do
          expect(cop_class.gem_requirements).to eq({})
        end
      end
    end

    describe 'on a cop with gem requirements' do
      let(:cop_class) do
        stub_cop_class('CopSpec::CopWithGemReqs') do
          requires_gem 'gem1', '>= 1.2.3'
          requires_gem 'gem2', '>= 4.5.6'
        end
      end

      it 'can be retrieved with .gem_requirements' do
        expected = {
          'gem1' => Gem::Requirement.new('>= 1.2.3'),
          'gem2' => Gem::Requirement.new('>= 4.5.6')
        }
        expect(cop_class.gem_requirements).to eq(expected)
      end
    end

    it 'is heritable' do
      superclass = stub_cop_class('CopSpec::SuperclassCopWithGemReqs') do
        requires_gem 'gem1', '>= 1.2.3'
      end

      subclass = stub_cop_class('CopSpec::SubclassCopWithGemReqs', inherit: superclass) do
        requires_gem 'gem2', '>= 4.5.6'
      end

      expected = {
        'gem1' => Gem::Requirement.new('>= 1.2.3'),
        'gem2' => Gem::Requirement.new('>= 4.5.6')
      }
      expect(subclass.gem_requirements).to eq(expected)

      # Ensure the superclass wasn't modified:
      expect(superclass.gem_requirements).to eq(expected.slice('gem1'))
    end
  end

  it 'keeps track of offenses' do
    cop.add_offense(nil, location: location, message: 'message')

    expect(cop.offenses.size).to eq(1)
  end

  it 'reports registered offenses' do
    cop.add_offense(nil, location: location, message: 'message')

    expect(cop.offenses).not_to be_empty
  end

  it 'sets default severity' do
    cop.add_offense(nil, location: location, message: 'message')

    expect(cop.offenses.first.severity).to eq(:convention)
  end

  it 'sets custom severity if present' do
    cop.config[cop.name] = { 'Severity' => 'warning' }
    cop.add_offense(nil, location: location, message: 'message')

    expect(cop.offenses.first.severity).to eq(:warning)
  end

  it 'warns if custom severity is invalid' do
    cop.config[cop.name] = { 'Severity' => 'superbad' }
    expect { cop.add_offense(nil, location: location, message: 'message') }
      .to output(/Warning: Invalid severity 'superbad'./).to_stderr
  end

  context 'when disabled by a comment' do
    subject(:offense_status) do
      cop.add_offense(nil, location: location, message: 'message')
      cop.offenses.first.status
    end

    before do
      allow(processed_source.comment_config).to receive(:cop_enabled_at_line?).and_return(false)
    end

    context 'ignore_disable_comments is false' do
      let(:cop_options) { { ignore_disable_comments: false } }

      it 'sets offense as disabled' do
        expect(offense_status).to eq :disabled
      end
    end

    context 'ignore_disable_comments is true' do
      let(:cop_options) { { ignore_disable_comments: true } }

      it 'does not set offense as disabled' do
        expect(offense_status).not_to eq :disabled
      end
    end
  end

  describe 'for a cop with a name' do
    let(:cop_class) { RuboCop::Cop::Style::For }

    it 'registers offense with its name' do
      offenses = cop.add_offense(location, message: 'message')
      expect(offenses.first.cop_name).to eq('Style/For')
    end
  end

  describe 'setting of Offense#corrected attribute' do
    context 'when cop does not support autocorrection' do
      before { allow(cop).to receive(:support_autocorrect?).and_return(false) }

      it 'is not specified (set to nil)' do
        cop.add_offense(nil, location: location, message: 'message')
        expect(cop.offenses.first).not_to be_corrected
      end

      context 'when autocorrect is requested' do
        before { allow(cop).to receive(:autocorrect_requested?).and_return(true) }

        it 'is not specified (set to nil)' do
          cop.add_offense(nil, location: location, message: 'message')
          expect(cop.offenses.first).not_to be_corrected
        end

        context 'when disable_uncorrectable is enabled' do
          before { allow(cop).to receive(:disable_uncorrectable?).and_return(true) }

          let(:node) do
            instance_double(RuboCop::AST::Node,
                            location: instance_double(Parser::Source::Map,
                                                      expression: location,
                                                      line: 1))
          end

          it 'is set to true' do
            cop.add_offense(node, location: location, message: 'message')
            expect(cop.offenses.first).to be_corrected
            expect(cop.offenses.first.status).to be(:corrected_with_todo)
          end
        end
      end
    end

    context 'when cop supports autocorrection', :restore_registry do
      let(:cop_class) do
        cop_class = nil
        expect do # rubocop:disable RSpec/ExpectInLet
          cop_class = stub_cop_class('RuboCop::Cop::Test::StubCop', inherit: described_class) do
            def autocorrect(node); end
          end
        end.to output(/Inheriting from `RuboCop::Cop::Cop` is deprecated/).to_stderr
        cop_class
      end

      context 'when offense was corrected' do
        before do
          allow(cop).to receive_messages(autocorrect?: true, autocorrect: lambda do |corrector|
            corrector.insert_before(location, 'hi!')
          end)
        end

        it 'is set to true' do
          cop.add_offense(nil, location: location, message: 'message')
          expect(cop.offenses.first).to be_corrected
        end
      end

      context 'when autocorrection is not needed' do
        before { allow(cop).to receive(:autocorrect?).and_return(false) }

        it 'is set to false' do
          cop.add_offense(nil, location: location, message: 'message')
          expect(cop.offenses.first).not_to be_corrected
        end
      end

      context 'when offense was not corrected because of an error' do
        before do
          allow(cop).to receive_messages(autocorrect?: true, autocorrect: false)
        end

        it 'is set to false' do
          cop.add_offense(nil, location: location, message: 'message')
          expect(cop.offenses.first).not_to be_corrected
        end
      end
    end
  end

  context 'with no submodule' do
    it('has right name') { expect(cop_class.cop_name).to eq('Cop/Cop') }
    it('has right department') { expect(cop_class.department).to eq(:Cop) }
  end

  context 'with style cops' do
    let(:cop_class) { RuboCop::Cop::Style::For }

    it('has right name') { expect(cop_class.cop_name).to eq('Style/For') }
    it('has right department') { expect(cop_class.department).to eq(:Style) }
  end

  context 'with lint cops' do
    let(:cop_class) { RuboCop::Cop::Lint::Loop }

    it('has right name') { expect(cop_class.cop_name).to eq('Lint/Loop') }
    it('has right department') { expect(cop_class.department).to eq(:Lint) }
  end

  describe 'Registry' do
    describe '#departments' do
      subject(:departments) { described_class.registry.departments }

      it('has departments') { expect(departments.length).not_to eq(0) }
      it { is_expected.to include(:Lint) }
      it { is_expected.to include(:Style) }

      it 'contains every value only once' do
        expect(departments.length).to eq(departments.uniq.length)
      end
    end

    describe '#with_department' do
      let(:departments) { described_class.registry.departments }

      it 'has at least one cop per department' do
        departments.each do |c|
          expect(described_class.registry.with_department(c).length).to be > 0
        end
      end

      it 'has each cop in exactly one type' do
        sum = 0
        departments.each { |c| sum += described_class.registry.with_department(c).length }
        expect(sum).to be described_class.registry.length
      end

      it 'returns 0 for an invalid type' do
        expect(described_class.registry.with_department('x').length).to be 0
      end
    end
  end

  describe '#autocorrect?' do
    subject { cop.autocorrect? }

    let(:support_autocorrect) { true }
    let(:disable_uncorrectable) { false }

    before do
      allow(cop.class).to receive(:support_autocorrect?) { support_autocorrect }
      allow(cop).to receive(:disable_uncorrectable?) { disable_uncorrectable }
    end

    context 'when the option is not given' do
      let(:cop_options) { {} }

      it { is_expected.to be(false) }
    end

    context 'when the option is given' do
      let(:cop_options) { { autocorrect: true } }

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
        let(:cop_options) { { 'AutoCorrect' => false } }

        it { is_expected.to be(false) }
      end
    end
  end

  describe '#relevant_file?' do
    subject { cop.relevant_file?(file) }

    let(:cop_config) { { 'Include' => ['foo.rb'] } }

    context 'when the file matches the Include configuration' do
      let(:file) { 'foo.rb' }

      it { is_expected.to be(true) }
    end

    context 'when the file doesn\'t match the Include configuration' do
      let(:file) { 'bar.rb' }

      it { is_expected.to be(false) }
    end

    context 'when the file is an anonymous source' do
      let(:file) { '(string)' }

      it { is_expected.to be(true) }
    end

    describe 'for a cop with gem version requirements', :restore_registry do
      subject { cop.relevant_file?(file) }

      let(:file) { 'foo.rb' }

      let(:cop_class) do
        stub_cop_class('CopSpec::CopWithGemReqs') do
          requires_gem 'gem1', '>= 1.2.3'
        end
      end

      before do
        allow(config).to receive(:gem_versions_in_target).and_return(gem_versions_in_target)
      end

      context 'the target doesn\'t satisfy any of the gem requirements' do
        let(:gem_versions_in_target) { {} }

        it { is_expected.to be(false) }
      end

      context 'the target has a required gem, but in a version that\'s too old' do
        let(:gem_versions_in_target) { { 'gem1' => Gem::Version.new('1.2.2') } }

        it { is_expected.to be(false) }
      end

      context 'the target has a required gem, in a supported version' do
        let(:gem_versions_in_target) { { 'gem1' => Gem::Version.new('1.2.3') } }

        it { is_expected.to be(true) }
      end

      context 'for a cop with multiple gem requirements' do
        let(:cop_class) do
          stub_cop_class('CopSpec::CopWithGemReqs') do
            requires_gem 'gem1', '>= 1.2.3'
            requires_gem 'gem2', '>= 4.5.6'
          end
        end

        context 'the target satisfies one but not all of the gem requirements' do
          let(:gem_versions_in_target) do
            {
              'gem1' => Gem::Version.new('1.2.3'),
              'gem2' => Gem::Version.new('4.5.5')
            }
          end

          it { is_expected.to be(false) }
        end

        context 'the target has all the required gems with sufficient versions' do
          let(:gem_versions_in_target) do
            {
              'gem1' => Gem::Version.new('1.2.3'),
              'gem2' => Gem::Version.new('4.5.6')
            }
          end

          it { is_expected.to be(true) }
        end
      end
    end
  end

  describe '#safe_autocorrect?' do
    subject { cop.safe_autocorrect? }

    context 'when cop is declared unsafe' do
      let(:cop_config) { { 'Safe' => false } }

      it { is_expected.to be(false) }
    end

    context 'when autocorrection of the cop is declared unsafe' do
      let(:cop_config) { { 'SafeAutoCorrect' => false } }

      it { is_expected.to be(false) }
    end

    context 'when safety is undeclared' do
      let(:cop_config) { {} }

      it { is_expected.to be(true) }
    end
  end
end
