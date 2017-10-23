# frozen_string_literal: true

module RuboCop
  module Formatter
    describe ClangStyleFormatter do
      subject(:formatter) { described_class.new(output) }

      let(:output) { StringIO.new }

      describe '#report_file' do
        let(:file) { '/path/to/file' }

        let(:offense) do
          Cop::Offense.new(:convention, location,
                           'This is a message.', 'CopName', status)
        end

        let(:location) do
          source_buffer = Parser::Source::Buffer.new('test', 1)
          source_buffer.source = "a\n"
          Parser::Source::Range.new(source_buffer, 0, 1)
        end

        it 'displays text containing the offending source line' do
          cop = Cop::Cop.new
          source_buffer = Parser::Source::Buffer.new('test', 1)
          source_buffer.source = ('aa'..'az').to_a.join($RS)
          cop.add_offense(
            nil,
            location: Parser::Source::Range.new(source_buffer, 0, 2),
            message: 'message 1'
          )
          cop.add_offense(
            nil,
            location: Parser::Source::Range.new(source_buffer, 30, 32),
            message: 'message 2'
          )

          formatter.report_file('test', cop.offenses)
          expect(output.string).to eq <<-OUTPUT.strip_indent
            test:1:1: C: message 1
            aa
            ^^
            test:11:1: C: message 2
            ak
            ^^
          OUTPUT
        end

        context 'when the source line is blank' do
          it 'does not display offending source line' do
            cop = Cop::Cop.new
            source_buffer = Parser::Source::Buffer.new('test', 1)
            source_buffer.source = ['     ', 'yaba'].join($RS)
            cop.add_offense(
              nil,
              location: Parser::Source::Range.new(source_buffer, 0, 2),
              message: 'message 1'
            )
            cop.add_offense(
              nil,
              location: Parser::Source::Range.new(source_buffer, 6, 10),
              message: 'message 2'
            )

            formatter.report_file('test', cop.offenses)
            expect(output.string).to eq <<-OUTPUT.strip_indent
              test:1:1: C: message 1
              test:2:1: C: message 2
              yaba
              ^^^^
            OUTPUT
          end
        end

        context 'when the offending source spans multiple lines' do
          it 'displays the first line with ellipses' do
            source = <<-RUBY.strip_indent
              do_something([this,
                            is,
                            target])
            RUBY

            source_buffer = Parser::Source::Buffer.new('test', 1)
            source_buffer.source = source

            location = Parser::Source::Range.new(source_buffer,
                                                 source.index('['),
                                                 source.index(']') + 1)

            cop = Cop::Cop.new
            cop.add_offense(nil, location: location, message: 'message 1')

            formatter.report_file('test', cop.offenses)
            expect(output.string)
              .to eq <<-OUTPUT.strip_indent
                test:1:14: C: message 1
                do_something([this, #{described_class::ELLIPSES}
                             ^^^^^^
            OUTPUT
          end
        end

        context 'when the offense is not corrected' do
          let(:status) { :uncorrected }

          it 'prints message as-is' do
            formatter.report_file(file, [offense])
            expect(output.string)
              .to include(': This is a message.')
          end
        end

        context 'when the offense is automatically corrected' do
          let(:status) { :corrected }

          it 'prints [Corrected] along with message' do
            formatter.report_file(file, [offense])
            expect(output.string)
              .to include(': [Corrected] This is a message.')
          end
        end
      end
    end
  end
end
