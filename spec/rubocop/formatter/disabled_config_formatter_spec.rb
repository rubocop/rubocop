# frozen_string_literal: true

RSpec.describe RuboCop::Formatter::DisabledConfigFormatter, :isolated_environment,
               :restore_registry do
  include FileHelper

  subject(:formatter) { described_class.new(output) }

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

  around do |example|
    original_stdout = $stdout
    original_stderr = $stderr

    $stdout = StringIO.new
    $stderr = StringIO.new

    example.run

    $stdout = original_stdout
    $stderr = original_stderr
  end

  before do
    stub_cop_class('Test::Cop1')
    stub_cop_class('Test::Cop2')
    # Avoid intermittent failure when another test set ConfigLoader options
    RuboCop::ConfigLoader.clear_options

    allow(Time).to receive(:now).and_return(Time.now)
  end

  context 'when any offenses are detected' do
    before do
      formatter.started(['test_a.rb', 'test_b.rb'])
      formatter.file_started('test_a.rb', {})
      formatter.file_finished('test_a.rb', offenses)
      formatter.file_started('test_b.rb', {})
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
      formatter.file_started('test_a.rb', {})
      formatter.file_finished('test_a.rb', offenses)
      formatter.file_started('test_b.rb', {})
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
        formatter.file_started(filename, {})

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
        formatter.file_started(filename, {})

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

  context 'with autocorrect supported cop', :restore_registry do
    before do
      stub_cop_class('Test::Cop3') { extend RuboCop::Cop::AutoCorrector }

      formatter.started(['test_autocorrect.rb'])
      formatter.file_started('test_autocorrect.rb', {})
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
