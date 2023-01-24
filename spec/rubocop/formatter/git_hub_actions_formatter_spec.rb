# frozen_string_literal: true

RSpec.describe RuboCop::Formatter::GitHubActionsFormatter, :config do
  subject(:formatter) { described_class.new(output, formatter_options) }

  let(:formatter_options) { {} }
  let(:cop_class) { RuboCop::Cop::Cop }
  let(:output) { StringIO.new }

  describe '#finished' do
    let(:file) { '/path/to/file' }
    let(:message) { 'This is a message.' }
    let(:status) { :uncorrected }

    let(:offense) do
      RuboCop::Cop::Offense.new(:convention, location, message, 'CopName', status)
    end

    let(:offenses) { [offense] }

    let(:source) { ('aa'..'az').to_a.join($RS) }

    let(:location) { source_range(0...1) }

    before do
      formatter.started([file])
      formatter.file_finished(file, offenses)
      formatter.finished([file])
    end

    context 'when offenses are detected' do
      it 'reports offenses as errors' do
        expect(output.string.include?("::error file=#{file},line=1,col=1::This is a message."))
          .to be(true)
      end
    end

    context 'when file is relative to the current directory' do
      let(:file) { "#{Dir.pwd}/path/to/file" }

      it 'reports offenses as error with the relative path' do
        expect(output.string.include?('::error file=path/to/file,line=1,col=1::This is a message.'))
          .to be(true)
      end
    end

    context 'when no offenses are detected' do
      let(:offenses) { [] }

      it 'does not print anything' do
        expect(output.string).to eq "\n"
      end
    end

    context 'when message contains %' do
      let(:message) { "All occurrences of %, \r and \n must be escaped" }

      it 'escapes message' do
        expect(output.string.include?('::All occurrences of %25, %0D and %0A must be escaped'))
          .to be(true)
      end
    end

    context 'when fail level is defined' do
      let(:formatter_options) { { fail_level: 'convention' } }
      let(:offenses) do
        [
          offense,
          RuboCop::Cop::Offense.new(
            :refactor,
            source_range(2...4),
            'This is a warning.',
            'CopName',
            status
          )
        ]
      end

      it 'reports offenses above or at fail level as errors' do
        expect(output.string.include?("::error file=#{file},line=1,col=1::This is a message."))
          .to be(true)
      end

      it 'reports offenses below fail level as warnings' do
        expect(output.string.include?("::warning file=#{file},line=1,col=3::This is a warning."))
          .to be(true)
      end
    end
  end
end
