# frozen_string_literal: true

RSpec.describe RuboCop::Formatter::ClangStyleFormatter, :config do
  subject(:formatter) { described_class.new(output) }

  let(:cop_class) { RuboCop::Cop::Base }
  let(:output) { StringIO.new }

  before { cop.send(:begin_investigation, processed_source) }

  describe '#report_file' do
    let(:file) { '/path/to/file' }

    let(:offense) do
      RuboCop::Cop::Offense.new(:convention, range, 'This is a message.', 'CopName', status)
    end

    let(:source) { ('aa'..'az').to_a.join($RS) }

    let(:range) { source_range(0...1) }

    it 'displays text containing the offending source line' do
      cop.add_offense(Parser::Source::Range.new(source_buffer, 0, 2), message: 'message 1')
      offenses = cop.add_offense(
        Parser::Source::Range.new(source_buffer, 30, 32), message: 'message 2'
      )

      formatter.report_file('test', offenses)
      expect(output.string).to eq <<~OUTPUT
        test:1:1: C: message 1
        aa
        ^^
        test:11:1: C: message 2
        ak
        ^^
      OUTPUT
    end

    context 'when the source line is blank' do
      let(:source) { ['     ', 'yaba'].join($RS) }

      it 'does not display offending source line' do
        cop.add_offense(Parser::Source::Range.new(source_buffer, 0, 2), message: 'message 1')
        offenses = cop.add_offense(
          Parser::Source::Range.new(source_buffer, 6, 10), message: 'message 2'
        )

        formatter.report_file('test', offenses)
        expect(output.string).to eq <<~OUTPUT
          test:1:1: C: message 1
          test:2:1: C: message 2
          yaba
          ^^^^
        OUTPUT
      end
    end

    context 'when the offending source spans multiple lines' do
      let(:source) do
        <<~RUBY
          do_something([this,
                        is,
                        target])
        RUBY
      end

      it 'displays the first line with ellipses' do
        range = source_range(source.index('[')..source.index(']'))

        offenses = cop.add_offense(range, message: 'message 1')

        formatter.report_file('test', offenses)
        expect(output.string)
          .to eq <<~OUTPUT
            test:1:14: C: message 1
            do_something([this, #{described_class::ELLIPSES}
                         ^^^^^^
        OUTPUT
      end
    end

    context 'when the offense is not corrected' do
      let(:status) { :unsupported }

      it 'prints message as-is' do
        formatter.report_file(file, [offense])
        expect(output.string).to include(': This is a message.')
      end
    end

    context 'when the offense is correctable' do
      let(:status) { :uncorrected }

      it 'prints message as-is' do
        formatter.report_file(file, [offense])
        expect(output.string).to include(': [Correctable] This is a message.')
      end
    end

    context 'when the offense is automatically corrected' do
      let(:status) { :corrected }

      it 'prints [Corrected] along with message' do
        formatter.report_file(file, [offense])
        expect(output.string).to include(': [Corrected] This is a message.')
      end
    end

    context 'when the source contains multibyte characters' do
      let(:source) do
        <<~RUBY
          do_something("あああ", ["いいい"])
        RUBY
      end

      it 'displays text containing the offending source line' do
        range = source_range(source.index('[')..source.index(']'))

        offenses = cop.add_offense(range, message: 'message 1')
        formatter.report_file('test', offenses)

        expect(output.string)
          .to eq <<~OUTPUT
            test:1:21: C: message 1
            do_something("あああ", ["いいい"])
                                   ^^^^^^^^^^
        OUTPUT
      end
    end
  end
end
