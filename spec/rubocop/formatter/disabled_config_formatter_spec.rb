# frozen_string_literal: true

RSpec.describe RuboCop::Formatter::DisabledConfigFormatter, :isolated_environment,
               :restore_registry do
  include FileHelper

  subject(:formatter) { described_class.new(output) }

  include_context 'mock console output'

  let(:output) do
    io = StringIO.new

    def io.path
      '.rubocop_todo.yml'
    end

    io
  end

  let(:offenses) do
    [RuboCop::Cop::Offense.new(:convention, location, 'message', 'Test/Cop1'),
     RuboCop::Cop::Offense.new(:convention, location, 'message', 'Test/Cop2')]
  end

  let(:location) { FakeLocation.new(line: 1, column: 5) }

  let(:heading) do
    format(
      described_class::HEADING,
      command: expected_heading_command,
      timestamp: expected_heading_timestamp
    )
  end

  let(:expected_heading_command) { 'rubocop --auto-gen-config' }

  let(:expected_heading_timestamp) { "on #{Time.now} " }
  let(:config_store) { instance_double(RuboCop::ConfigStore) }
  let(:options) { { config_store: config_store } }

  before do
    stub_cop_class('Test::Cop1')
    stub_cop_class('Test::Cop2')
    # Avoid intermittent failure when another test set ConfigLoader options
    RuboCop::ConfigLoader.clear_options

    allow(Time).to receive(:now).and_return(Time.now)
    allow(config_store).to receive(:for_pwd).and_return(instance_double(RuboCop::Config))
  end

  context 'when any offenses are detected' do
    before do
      formatter.started(['test_a.rb', 'test_b.rb'])
      formatter.file_started('test_a.rb', options)
      formatter.file_finished('test_a.rb', offenses)
      formatter.file_started('test_b.rb', options)
      formatter.file_finished('test_b.rb', [offenses.first])
      formatter.finished(['test_a.rb', 'test_b.rb'])
    end

    let(:expected_rubocop_todo) do
      [heading,
       '# Offense count: 2',
       'Test/Cop1:',
       '  Exclude:',
       "    - 'test_a.rb'",
       "    - 'test_b.rb'",
       '',
       '# Offense count: 1',
       'Test/Cop2:',
       '  Exclude:',
       "    - 'test_a.rb'",
       ''].join("\n")
    end

    it 'displays YAML configuration disabling all cops with offenses' do
      expect(output.string).to eq(expected_rubocop_todo)
      expect($stdout.string).to eq("Created .rubocop_todo.yml.\n")
    end
  end

  context "when there's .rubocop.yml" do
    before do
      create_file('.rubocop.yml', <<~'YAML')
        Test/Cop1:
          Exclude:
            - Gemfile
        Test/Cop2:
          Exclude:
            - "**/*.blah"
            - !ruby/regexp /.*/bar/*/foo\.rb$/
      YAML

      formatter.started(['test_a.rb', 'test_b.rb'])
      formatter.file_started('test_a.rb', options)
      formatter.file_finished('test_a.rb', offenses)
      formatter.file_started('test_b.rb', options)
      formatter.file_finished('test_b.rb', [offenses.first])

      allow(RuboCop::ConfigLoader.default_configuration).to receive(:[]).and_return({})
      formatter.finished(['test_a.rb', 'test_b.rb'])
    end

    let(:expected_rubocop_todo) do
      [heading,
       '# Offense count: 2',
       'Test/Cop1:',
       '  Exclude:',
       "    - 'Gemfile'",
       "    - 'test_a.rb'",
       "    - 'test_b.rb'",
       '',
       '# Offense count: 1',
       'Test/Cop2:',
       '  Exclude:',
       "    - '**/*.blah'",
       '    - !ruby/regexp /.*/bar/*/foo\.rb$/',
       "    - 'test_a.rb'",
       ''].join("\n")
    end

    it 'merges in excludes from .rubocop.yml' do
      expect(output.string).to eq(expected_rubocop_todo)
    end
  end

  context 'when exclude_limit option is omitted' do
    before do
      formatter.started(filenames)

      filenames.each do |filename|
        formatter.file_started(filename, options)

        if filename == filenames.last
          formatter.file_finished(filename, [offenses.first])
        else
          formatter.file_finished(filename, offenses)
        end
      end

      formatter.finished(filenames)
    end

    let(:filenames) { Array.new(16) { |index| format('test_%02d.rb', index + 1) } }

    let(:expected_rubocop_todo) do
      [heading,
       '# Offense count: 16',
       'Test/Cop1:',
       '  Enabled: false',
       '',
       '# Offense count: 15',
       'Test/Cop2:',
       '  Exclude:',
       "    - 'test_01.rb'",
       "    - 'test_02.rb'",
       "    - 'test_03.rb'",
       "    - 'test_04.rb'",
       "    - 'test_05.rb'",
       "    - 'test_06.rb'",
       "    - 'test_07.rb'",
       "    - 'test_08.rb'",
       "    - 'test_09.rb'",
       "    - 'test_10.rb'",
       "    - 'test_11.rb'",
       "    - 'test_12.rb'",
       "    - 'test_13.rb'",
       "    - 'test_14.rb'",
       "    - 'test_15.rb'",
       ''].join("\n")
    end

    it 'disables the cop with 15 offending files' do
      expect(output.string).to eq(expected_rubocop_todo)
    end
  end

  context 'when exclude_limit option is passed' do
    before do
      formatter.started(filenames)

      filenames.each do |filename|
        formatter.file_started(filename, options)

        if filename == filenames.last
          formatter.file_finished(filename, [offenses.first])
        else
          formatter.file_finished(filename, offenses)
        end
      end

      formatter.finished(filenames)
    end

    let(:formatter) { described_class.new(output, exclude_limit: 5) }

    let(:filenames) { Array.new(6) { |index| format('test_%02d.rb', index + 1) } }

    let(:expected_heading_command) { 'rubocop --auto-gen-config --exclude-limit 5' }

    let(:expected_rubocop_todo) do
      [heading,
       '# Offense count: 6',
       'Test/Cop1:',
       '  Enabled: false',
       '',
       '# Offense count: 5',
       'Test/Cop2:',
       '  Exclude:',
       "    - 'test_01.rb'",
       "    - 'test_02.rb'",
       "    - 'test_03.rb'",
       "    - 'test_04.rb'",
       "    - 'test_05.rb'",
       ''].join("\n")
    end

    it 'respects the file exclusion list limit' do
      expect(output.string).to eq(expected_rubocop_todo)
    end
  end

  context 'when no files are inspected' do
    before do
      formatter.started([])
      formatter.finished([])
    end

    it 'creates a .rubocop_todo.yml even in such case' do
      expect(output.string).to eq(heading)
    end
  end

  context 'when a cop has a frozen array config parameter' do
    before do
      default_config = RuboCop::ConfigLoader.default_configuration
      allow(default_config).to receive(:[]).with('Test/Cop1').and_return(
        {
          'Enabled' => true,
          'AllowedOperators' => %w[* + & | ^].freeze
        }
      )
      allow(default_config).to receive(:[]).with('Test/Cop2').and_return({})

      formatter.started(['test_a.rb'])
      formatter.file_started('test_a.rb', options)
      formatter.file_finished('test_a.rb', offenses)
      formatter.finished(['test_a.rb'])
    end

    it 'does not raise a `FrozenError`' do
      expect(output.string).to include('# AllowedOperators: *, +, &, |, ^')
    end
  end

  describe '.merge_cop_config' do
    def merge(existing, incoming, detected_styles = nil)
      described_class::ConfigMerger.merge_cop_config(existing, incoming, detected_styles)
    end

    context 'when both sides have identical scalar values' do
      it 'returns the existing config' do
        result = merge({ 'EnforcedStyle' => 'space' }, { 'EnforcedStyle' => 'space' })
        expect(result).to eq({ 'EnforcedStyle' => 'space' })
      end
    end

    context 'when scalar values differ without detected_styles' do
      it 'disables the cop' do
        result = merge({ 'EnforcedStyle' => 'space' }, { 'EnforcedStyle' => 'no_space' })
        expect(result).to eq({ 'Enabled' => false })
      end
    end

    context 'when scalar values differ with non-empty detected_styles intersection' do
      it 'resolves using the detected_styles intersection' do
        result = merge({ 'EnforcedStyle' => 'space' }, { 'EnforcedStyle' => 'no_space' },
                       %w[no_space])
        expect(result).to eq({ 'EnforcedStyle' => 'no_space' })
      end
    end

    context 'when scalar values differ with empty detected_styles' do
      it 'disables the cop' do
        result = merge({ 'EnforcedStyle' => 'space' }, { 'EnforcedStyle' => 'no_space' }, [])
        expect(result).to eq({ 'Enabled' => false })
      end
    end

    context 'when one side is already disabled' do
      it 'disables the cop' do
        result = merge({ 'Enabled' => false }, { 'EnforcedStyle' => 'space' })
        expect(result).to eq({ 'Enabled' => false })
      end
    end

    context 'when one side has keys the other lacks' do
      it 'merges both sides' do
        result = merge({ 'EnforcedStyle' => 'space' }, { 'MinSize' => 5 })
        expect(result).to eq({ 'EnforcedStyle' => 'space', 'MinSize' => 5 })
      end
    end
  end

  describe '.merge_config_overrides' do
    def merge_overrides(override_a, override_b, cop_class = nil)
      described_class::ConfigMerger.merge_config_overrides(override_a, override_b, cop_class)
    end

    context 'when one side is nil' do
      it 'returns the other side' do
        expect(merge_overrides({ 'MinSize' => 4 }, nil)).to eq({ 'MinSize' => 4 })
        expect(merge_overrides(nil, { 'MinSize' => 3 })).to eq({ 'MinSize' => 3 })
      end
    end

    context 'when both sides have identical values' do
      it 'returns the values unchanged' do
        result = merge_overrides({ 'EnforcedStyle' => 'percent', 'MinSize' => 4 },
                                 { 'EnforcedStyle' => 'percent', 'MinSize' => 4 })
        expect(result).to eq({ 'EnforcedStyle' => 'percent', 'MinSize' => 4 })
      end
    end

    context 'when values differ and cop defines merge lambdas' do
      let(:cop_class) do
        Class.new do
          def self.config_to_allow_offenses_mergers
            {
              'EnforcedStyle' => ->(_a, _b) { 'percent' },
              'MinSize' => ->(a, b) { [a, b].max }
            }
          end
        end
      end

      it 'uses the lambdas to resolve conflicts' do
        result = merge_overrides({ 'EnforcedStyle' => 'percent', 'MinSize' => 4 },
                                 { 'EnforcedStyle' => 'brackets', 'MinSize' => 3 },
                                 cop_class)
        expect(result).to eq({ 'EnforcedStyle' => 'percent', 'MinSize' => 4 })
      end
    end

    context 'when values differ and cop has no merge lambdas' do
      it 'keeps the left-side value' do
        result = merge_overrides({ 'EnforcedStyle' => 'ruby19' },
                                 { 'EnforcedStyle' => 'hash_rockets' })
        expect(result).to eq({ 'EnforcedStyle' => 'ruby19' })
      end
    end
  end

  describe '.merge_config_from_tmp' do
    around do |example|
      tmp_dir = Pathname.new(Dir.mktmpdir('rubocop-auto-gen'))
      original_tmp_dir = RuboCop::ExcludeLimit.tmp_dir
      RuboCop::ExcludeLimit.tmp_dir = tmp_dir
      original_config = described_class.config_to_allow_offenses.dup
      described_class.config_to_allow_offenses = {}
      begin
        example.run
      ensure
        RuboCop::ExcludeLimit.tmp_dir = original_tmp_dir
        described_class.config_to_allow_offenses = original_config
        tmp_dir.rmtree if tmp_dir.exist?
      end
    end

    def write_worker_config(cop_name, pid, data)
      dir = RuboCop::ExcludeLimit.tmp_dir.join('config_to_allow', cop_name.tr('/', '-'))
      dir.mkpath
      dir.join("#{pid}.json").write(JSON.dump(data))
    end

    context 'when workers report overlapping detected_styles' do
      before do
        # Layout/FirstHashElementIndentation supports: consistent,
        # special_inside_parentheses, align_braces.
        #
        # A hash literal NOT inside parentheses is ambiguous between
        # consistent and special_inside_parentheses (both indent
        # relative to start-of-line). So ambiguous_style_detected
        # is called with both.
        #
        # Worker 1 only saw such hashes, so it persists
        # EnforcedStyle: consistent (.first) with both possibilities.
        write_worker_config('Layout/FirstHashElementIndentation', 1001,
                            'EnforcedStyle' => 'consistent',
                            '_detected_styles' => %w[consistent special_inside_parentheses])
        # Worker 2 saw a hash inside parentheses that uniquely matches
        # special_inside_parentheses, narrowing to a single style.
        write_worker_config('Layout/FirstHashElementIndentation', 1002,
                            'EnforcedStyle' => 'special_inside_parentheses',
                            '_detected_styles' => %w[special_inside_parentheses])

        described_class.merge_config_from_tmp
      end

      it 'uses the detected_styles intersection to resolve the conflict' do
        cfg = described_class.config_to_allow_offenses['Layout/FirstHashElementIndentation']
        expect(cfg).to eq('EnforcedStyle' => 'special_inside_parentheses')
      end
    end

    context 'when workers report non-overlapping detected_styles' do
      before do
        write_worker_config('Style/HashSyntax', 2001,
                            'EnforcedStyle' => 'ruby19',
                            '_detected_styles' => ['ruby19'])
        write_worker_config('Style/HashSyntax', 2002,
                            'EnforcedStyle' => 'hash_rockets',
                            '_detected_styles' => ['hash_rockets'])

        described_class.merge_config_from_tmp
      end

      it 'disables the cop' do
        cfg = described_class.config_to_allow_offenses['Style/HashSyntax']
        expect(cfg).to eq('Enabled' => false)
      end
    end

    context 'when three workers progressively narrow the intersection' do
      before do
        write_worker_config('Layout/SpaceInsideHashLiteralBraces', 3001,
                            'EnforcedStyle' => 'space',
                            '_detected_styles' => %w[space no_space compact])
        write_worker_config('Layout/SpaceInsideHashLiteralBraces', 3002,
                            'EnforcedStyle' => 'no_space',
                            '_detected_styles' => %w[no_space compact])
        write_worker_config('Layout/SpaceInsideHashLiteralBraces', 3003,
                            'EnforcedStyle' => 'compact',
                            '_detected_styles' => %w[compact])

        described_class.merge_config_from_tmp
      end

      it 'narrows to the common intersection' do
        cfg = described_class.config_to_allow_offenses['Layout/SpaceInsideHashLiteralBraces']
        expect(cfg).to eq('EnforcedStyle' => 'compact')
      end
    end

    context 'when workers have no detected_styles (scalar-only)' do
      before do
        write_worker_config('Style/HashSyntax', 4001, 'EnforcedStyle' => 'ruby19')
        write_worker_config('Style/HashSyntax', 4002, 'EnforcedStyle' => 'hash_rockets')

        described_class.merge_config_from_tmp
      end

      it 'falls back to disabling the cop' do
        cfg = described_class.config_to_allow_offenses['Style/HashSyntax']
        expect(cfg).to eq('Enabled' => false)
      end
    end

    context 'when workers produce conflicting MinSize with _config_overrides (ArrayMinSize cop)' do
      before do
        # Worker 1 saw brackets of size 3 → percent + MinSize 4
        write_worker_config('Style/SymbolArray', 5001,
                            'EnforcedStyle' => 'percent',
                            'MinSize' => 4,
                            '_config_overrides' => {
                              'EnforcedStyle' => 'percent',
                              'MinSize' => 4
                            })
        # Worker 2 saw brackets of size 2 → percent + MinSize 3
        write_worker_config('Style/SymbolArray', 5002,
                            'EnforcedStyle' => 'percent',
                            'MinSize' => 3,
                            '_config_overrides' => {
                              'EnforcedStyle' => 'percent',
                              'MinSize' => 3
                            })

        described_class.merge_config_from_tmp
      end

      it 'uses cop-defined merge lambdas to take the max MinSize' do
        cfg = described_class.config_to_allow_offenses['Style/SymbolArray']
        expect(cfg).to eq('EnforcedStyle' => 'percent', 'MinSize' => 4)
      end
    end

    context 'when one worker disabled and another has config, both with _config_overrides' do
      before do
        # Worker 1 disabled: smallest_percent <= largest_brackets
        write_worker_config('Style/SymbolArray', 6001,
                            'Enabled' => false,
                            '_config_overrides' => {
                              'EnforcedStyle' => 'percent',
                              'MinSize' => 4
                            })
        # Worker 2 resolved to percent+MinSize
        write_worker_config('Style/SymbolArray', 6002,
                            'EnforcedStyle' => 'percent',
                            'MinSize' => 3,
                            '_config_overrides' => {
                              'EnforcedStyle' => 'percent',
                              'MinSize' => 3
                            })

        described_class.merge_config_from_tmp
      end

      it 'uses merged overrides as fallback instead of disabling' do
        cfg = described_class.config_to_allow_offenses['Style/SymbolArray']
        expect(cfg).to eq('EnforcedStyle' => 'percent', 'MinSize' => 4)
      end
    end

    context 'when only one worker provides _config_overrides' do
      before do
        # Worker 1 saw only brackets → EnforcedStyle: brackets, with overrides
        write_worker_config('Style/WordArray', 7001,
                            'EnforcedStyle' => 'brackets',
                            '_config_overrides' => {
                              'EnforcedStyle' => 'percent',
                              'MinSize' => 5
                            })
        # Worker 2 saw only percent → EnforcedStyle: percent, no overrides
        write_worker_config('Style/WordArray', 7002, 'EnforcedStyle' => 'percent')

        described_class.merge_config_from_tmp
      end

      it 'uses the single override as fallback' do
        cfg = described_class.config_to_allow_offenses['Style/WordArray']
        expect(cfg).to eq('EnforcedStyle' => 'percent', 'MinSize' => 5)
      end
    end
  end

  context 'with autocorrect supported cop', :restore_registry do
    before do
      stub_cop_class('Test::Cop3') { extend RuboCop::Cop::AutoCorrector }

      formatter.started(['test_autocorrect.rb'])
      formatter.file_started('test_autocorrect.rb', options)
      formatter.file_finished('test_autocorrect.rb', offenses)
      formatter.finished(['test_autocorrect.rb'])
    end

    let(:expected_rubocop_todo) do
      [heading,
       '# Offense count: 1',
       '# This cop supports safe autocorrection (--autocorrect).',
       'Test/Cop3:',
       '  Exclude:',
       "    - 'test_autocorrect.rb'",
       ''].join("\n")
    end

    let(:offenses) do
      [
        RuboCop::Cop::Offense.new(:convention, location, 'message', 'Test/Cop3')
      ]
    end

    it 'adds a comment about --autocorrect option' do
      expect(output.string).to eq(expected_rubocop_todo)
    end
  end
end
