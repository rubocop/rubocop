# frozen_string_literal: true

RSpec.describe RuboCop::Formatter::SARIFFormatter do
  subject(:formatter) { described_class.new(output) }

  let(:output) { StringIO.new }
  let(:report) { JSON.parse(output.string) }
  let(:run) { report['runs'].first }
  let(:source_buffer) do
    buffer = Parser::Source::Buffer.new('/path/to/file.rb', 1)
    buffer.source = "puts 'foo'\nputs 'bar'\n"
    buffer
  end
  let(:location) { Parser::Source::Range.new(source_buffer, 5, 10) }
  let(:offense) do
    RuboCop::Cop::Offense.new(:convention, location, 'Prefer double quotes.',
                              'Style/StringLiterals')
  end

  def finish(file = '/path/to/file.rb', offenses = [offense])
    formatter.file_finished(file, offenses)
    formatter.finished([file])
  end

  it 'emits a SARIF 2.1.0 document with a single run' do
    finish

    expect(report['$schema']).to eq('https://json.schemastore.org/sarif-2.1.0.json')
    expect(report['version']).to eq('2.1.0')
    expect(report['runs'].size).to eq(1)
  end

  it 'describes RuboCop as the driver' do
    finish

    driver = run['tool']['driver']
    expect(driver['name']).to eq('RuboCop')
    expect(driver['version']).to eq(RuboCop::Version::STRING)
    expect(driver['informationUri']).to eq('https://rubocop.org')
  end

  it 'emits a valid document when there are no offenses' do
    finish('/path/to/file.rb', [])

    expect(run['results']).to be_empty
    expect(run['tool']['driver']['rules']).to be_empty
  end

  describe 'results' do
    it 'reports the offense message and cop name' do
      finish

      result = run['results'].first
      expect(result['ruleId']).to eq('Style/StringLiterals')
      expect(result['message']['text']).to eq('Prefer double quotes.')
    end

    it 'reports a 1-based region with an exclusive end column' do
      finish

      region = run['results'].first['locations'].first['physicalLocation']['region']
      expect(region).to eq(
        'startLine' => 1, 'startColumn' => 6, 'endLine' => 1, 'endColumn' => 11
      )
    end

    it 'reports the file path relative to the working directory' do
      file = File.join(Dir.pwd, 'lib', 'foo.rb')
      finish(file)

      artifact = run['results'].first['locations'].first['physicalLocation']['artifactLocation']
      expect(artifact).to eq('uri' => 'lib/foo.rb')
    end

    it 'fingerprints the offense so alerts survive a file move' do
      finish

      fingerprints = run['results'].first['partialFingerprints']
      expect(fingerprints['primaryLocationLineHash']).to eq(
        Digest::SHA256.hexdigest("Style/StringLiterals#{location.source_line}")
      )
    end

    it 'does not mark ordinary offenses as suppressed' do
      finish

      expect(run['results'].first).not_to have_key('suppressions')
    end
  end

  describe 'severity mapping' do
    { info: 'note', refactor: 'note', convention: 'note',
      warning: 'warning', error: 'error', fatal: 'error' }.each do |severity, level|
      it "reports #{severity} offenses as #{level}" do
        offense = RuboCop::Cop::Offense.new(severity, location, 'Message', 'Cop/Name')
        finish('/path/to/file.rb', [offense])

        expect(run['results'].first['level']).to eq(level)
      end
    end
  end

  describe 'rules' do
    it 'emits one rule per cop and points results at it by index' do
      other = RuboCop::Cop::Offense.new(:convention, location, 'Another message.',
                                        'Style/StringLiterals')
      third = RuboCop::Cop::Offense.new(:warning, location, 'Different cop.', 'Lint/Void')
      finish('/path/to/file.rb', [offense, other, third])

      rules = run['tool']['driver']['rules']
      expect(rules.map { |rule| rule['id'] }).to eq(%w[Style/StringLiterals Lint/Void])
      expect(run['results'].map { |result| result['ruleIndex'] }).to eq([0, 0, 1])
    end

    it 'tags each rule with its department' do
      finish

      expect(run['tool']['driver']['rules'].first['properties']['tags']).to eq(['Style'])
    end

    it 'falls back to the cop name when there is no configuration to consult' do
      finish

      rule = run['tool']['driver']['rules'].first
      expect(rule['shortDescription']['text']).to eq('Style/StringLiterals')
    end

    it 'omits the documentation URL for cops it knows nothing about' do
      offense = RuboCop::Cop::Offense.new(:convention, location, 'Message', 'Custom/Cop')
      finish('/path/to/file.rb', [offense])

      rule = run['tool']['driver']['rules'].first
      expect(rule).not_to have_key('helpUri')
      expect(rule['help']).not_to have_key('markdown')
    end

    context 'when the configuration is available' do
      let(:config_store) do
        instance_double(RuboCop::ConfigStore, for_file: RuboCop::ConfigLoader.default_configuration)
      end

      before { formatter.file_started('/path/to/file.rb', config_store: config_store) }

      it 'documents the rule with the cop description and documentation URL' do
        finish

        rule = run['tool']['driver']['rules'].first
        expect(rule['shortDescription']['text']).to eq(
          RuboCop::ConfigLoader.default_configuration
                               .for_cop('Style/StringLiterals')['Description']
        )
        expect(rule['helpUri']).to eq(
          'https://docs.rubocop.org/rubocop/cops_style.html#stylestringliterals'
        )
        expect(rule['help']['markdown']).to include('[Documentation](')
      end

      it 'reports the configured severity as the rule default' do
        finish

        rules = run['tool']['driver']['rules']
        expect(rules.first['defaultConfiguration']['level']).to eq('note')
      end
    end
  end

  describe 'suppressed offenses' do
    let(:offense) do
      RuboCop::Cop::Offense.new(:convention, location, 'Prefer double quotes.',
                                'Style/StringLiterals', :disabled,
                                justification: 'external API')
    end

    it 'marks them as suppressed in source with the directive reason' do
      finish

      expect(run['results'].first['suppressions']).to eq(
        [{ 'kind' => 'inSource', 'justification' => 'external API' }]
      )
    end
  end
end
