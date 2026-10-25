# frozen_string_literal: true

RSpec.describe RuboCop::AllowedOffenses do
  subject(:allowed_offenses) { described_class.new(config) }

  let(:config) do
    {
      'Style/A' => { 'AllowedOffenses' => { 'a.rb' => 2 } },
      'Style/B' => { 'AllowedOffenses' => { 'a.rb' => 1 } },
      'Style' => { 'AllowedOffenses' => { 'a.rb' => 4 } }
    }
  end

  def offenses(*cop_names)
    cop_names.map do |name|
      instance_double(RuboCop::Cop::Offense, cop_name: name, corrected?: false, disabled?: false)
    end
  end

  it 'is configured for cop-specific allowances' do
    expect(allowed_offenses).to be_configured
    expect(allowed_offenses).to be_configured_for('Style/A')
    expect(allowed_offenses).to be_configured_for('Style/C')
  end

  it 'filters offenses while each cop stays within its allowance' do
    allowed_offenses.record('a.rb', offenses('Style/A', 'Style/A', 'Style/B', 'Style/C'))

    expect(allowed_offenses.filter('a.rb', offenses('Style/A', 'Style/B', 'Metrics/C'))
                            .map(&:cop_name)).to eq(['Metrics/C'])
  end

  it 'reports all offenses for a cop once its allowance is exceeded' do
    earlier_offenses = offenses('Style/A', 'Style/A')
    later_offenses = offenses('Style/A')
    allowed_offenses.record('a.rb', earlier_offenses)
    allowed_offenses.record('a.rb', later_offenses)

    expect(allowed_offenses).to be_exceeded
    expect(allowed_offenses.filter('a.rb', earlier_offenses + later_offenses))
      .to eq(earlier_offenses + later_offenses)
  end

  it 'applies the allowance independently to each file' do
    per_file_allowances = described_class.new(
      'Style/A' => { 'AllowedOffenses' => { 'a.rb' => 1, 'b.rb' => 2 } }
    )
    a_offenses = offenses('Style/A', 'Style/A')
    b_offenses = offenses('Style/A')

    per_file_allowances.record('a.rb', a_offenses)
    per_file_allowances.record('b.rb', b_offenses)

    expect(per_file_allowances).to be_exceeded
    expect(per_file_allowances.filter('a.rb', a_offenses)).to eq(a_offenses)
    expect(per_file_allowances.filter('b.rb', b_offenses)).to be_empty
  end

  it 'treats files without an allowance entry as having a zero allowance' do
    unlisted_file = described_class.new('Style/A' => { 'AllowedOffenses' => { 'a.rb' => 1 } })
    new_file_offenses = offenses('Style/A')

    unlisted_file.record('new.rb', new_file_offenses)

    expect(unlisted_file).to be_exceeded
    expect(unlisted_file.filter('new.rb', new_file_offenses)).to eq(new_file_offenses)
  end

  it 'reports offenses when the allowance is zero' do
    zero_allowance = described_class.new(
      'Style/B' => { 'AllowedOffenses' => { 'example.rb' => 0 } }
    )
    offense = offenses('Style/B')
    zero_allowance.record('example.rb', offense)

    expect(zero_allowance.filter('example.rb', offense)).to eq(offense)
  end

  it 'does not count corrected or disabled offenses' do
    zero_allowance = described_class.new(
      'Style/A' => { 'AllowedOffenses' => { 'example.rb' => 0 } }
    )
    corrected = instance_double(
      RuboCop::Cop::Offense, cop_name: 'Style/A', corrected?: true, disabled?: false
    )
    disabled = instance_double(
      RuboCop::Cop::Offense, cop_name: 'Style/A', corrected?: false, disabled?: true
    )

    zero_allowance.record('example.rb', [corrected, disabled])

    expect(zero_allowance).not_to be_exceeded
  end

  it 'uses a department allowance for cops without their own setting' do
    department_allowance = offenses('Style/C', 'Style/C', 'Style/C', 'Style/C')
    allowed_offenses.record('a.rb', department_allowance)

    expect(allowed_offenses.filter('a.rb', department_allowance)).to be_empty

    extra_offense = offenses('Style/C')
    allowed_offenses.record('a.rb', extra_offense)

    expect(allowed_offenses.filter('a.rb', department_allowance + extra_offense))
      .to eq(department_allowance + extra_offense)
  end

  it 'replaces a department allowance with a cop-specific map' do
    cop_specific_allowance = described_class.new(
      'Style' => { 'AllowedOffenses' => { 'a.rb' => 2 } },
      'Style/A' => { 'AllowedOffenses' => { 'b.rb' => 1 } }
    )
    a_offense = offenses('Style/A')
    b_offense = offenses('Style/A')

    cop_specific_allowance.record('a.rb', a_offense)
    cop_specific_allowance.record('b.rb', b_offense)

    expect(cop_specific_allowance).to be_exceeded
    expect(cop_specific_allowance.filter('a.rb', a_offense)).to eq(a_offense)
    expect(cop_specific_allowance.filter('b.rb', b_offense)).to be_empty
  end

  describe RuboCop::Runner, :isolated_environment do
    include FileHelper

    subject(:runner) { described_class.new(options, RuboCop::ConfigStore.new) }

    let(:formatter_output_path) { 'formatter_output.txt' }
    let(:formatter_output) { File.read(formatter_output_path) }
    let(:options) do
      {
        only: ['Style/StringLiterals'],
        formatters: [['simple', formatter_output_path]]
      }
    end

    before do
      create_file('.rubocop.yml', <<~YAML)
        Style/StringLiterals:
          AllowedOffenses:
            example.rb: 1
      YAML
    end

    it 'passes and suppresses offenses while the cop stays within its allowance' do
      create_file('example.rb', "puts \"one\"\n")

      expect(runner.run([])).to be(true)
      expect(formatter_output).to include('1 file inspected, no offenses detected')
      expect(formatter_output).not_to include('Style/StringLiterals')
    end

    it 'fails and reports all offenses after the cop exceeds its allowance' do
      create_file('a.rb', "puts \"one\"\n")
      create_file('b.rb', "puts \"two\"\n")

      expect(runner.run([])).to be(false)
      expect(formatter_output.scan('Style/StringLiterals').size).to eq(2)
      expect(formatter_output).to include('2 files inspected, 2 offenses detected')
    end

    context 'with fail-fast enabled' do
      let(:options) { super().merge(fail_fast: true) }

      it 'stops after the allowance is exceeded and reports the offenses seen so far' do
        source = "puts \"one\"\nputs \"two\"\n"
        create_file('a.rb', source)
        create_file('b.rb', source)

        expect(runner.run([])).to be(false)
        expect(formatter_output.scan('Style/StringLiterals').size).to eq(2)
        expect(formatter_output).to include('1 file inspected, 2 offenses detected')
      end
    end

    context 'with autocorrect enabled' do
      let(:options) { super().merge(autocorrect: true) }

      it 'does not count corrected offenses against the allowance' do
        create_file('.rubocop.yml', <<~YAML)
          Style/StringLiterals:
            AllowedOffenses:
              example.rb: 0
        YAML
        create_file('example.rb', "puts \"one\"\n")

        expect(runner.run([])).to be(true)
        expect(File.read('example.rb')).to eq("puts 'one'\n")
        expect(formatter_output).to include('1 file inspected, no offenses detected')
      end
    end

    it 'applies the configured file allowance to a partial run' do
      create_file('.rubocop.yml', <<~YAML)
        Style/StringLiterals:
          AllowedOffenses:
            a.rb: 1
            b.rb: 2
      YAML
      create_file('a.rb', "puts \"one\"\nputs \"two\"\n")
      create_file('b.rb', "puts \"three\"\n")

      expect(runner.run(['a.rb'])).to be(false)
      expect(formatter_output.scan('Style/StringLiterals').size).to eq(2)
      expect(formatter_output).to include('1 file inspected, 2 offenses detected')
    end

    context 'with parallel inspection enabled' do
      let(:options) { super().merge(parallel: true) }

      it 'applies each file allowance independently' do
        create_file('a.rb', "puts \"one\"\n")
        create_file('b.rb', "puts \"two\"\n")

        expect(runner.run([])).to be(false)
        expect(formatter_output.scan('Style/StringLiterals').size).to eq(2)
        expect(formatter_output).to include('2 files inspected, 2 offenses detected')
      end
    end

    context 'with a per-cop offense display cap' do
      let(:options) { super().merge(max_offenses_per_cop: 1) }

      it 'still fails when the allowance is exceeded' do
        create_file('a.rb', "puts \"one\"\n")
        create_file('b.rb', "puts \"two\"\n")

        expect(runner.run([])).to be(false)
        expect(formatter_output).to include('1 offense detected')
        expect(formatter_output).not_to include('2 offenses detected')
      end
    end
  end
end
