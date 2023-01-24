# frozen_string_literal: true

RSpec.describe RuboCop::Formatter::TapFormatter do
  subject(:formatter) { described_class.new(output) }

  let(:output) { StringIO.new }

  let(:files) do
    %w[lib/rubocop.rb spec/spec_helper.rb exe/rubocop].map do |path|
      File.expand_path(path)
    end
  end

  describe '#file_finished' do
    before do
      formatter.started(files)
      formatter.file_started(files.first, {})
      formatter.file_finished(files.first, offenses)
    end

    context 'when no offenses are detected' do
      let(:offenses) { [] }

      it 'prints "ok"' do
        expect(output.string.include?('ok 1')).to be(true)
      end
    end

    context 'when any offenses are detected' do
      let(:offenses) do
        source_buffer = Parser::Source::Buffer.new('test', 1)
        source = Array.new(9) { |index| "This is line #{index + 1}." }
        source_buffer.source = source.join("\n")
        line_length = source[0].length + 1

        [
          RuboCop::Cop::Offense.new(
            :convention,
            Parser::Source::Range.new(source_buffer,
                                      line_length + 2,
                                      line_length + 3),
            'foo',
            'Cop'
          )
        ]
      end

      it 'prints "not ok"' do
        expect(output.string.include?('not ok 1')).to be(true)
      end
    end
  end

  describe '#finished' do
    before { formatter.started(files) }

    context 'when any offenses are detected' do
      before do
        source_buffer = Parser::Source::Buffer.new('test', 1)
        source = Array.new(9) { |index| "This is line #{index + 1}." }
        source_buffer.source = source.join("\n")
        line_length = source[0].length + 1

        formatter.file_started(files[0], {})
        formatter.file_finished(
          files[0],
          [
            RuboCop::Cop::Offense.new(
              :convention,
              Parser::Source::Range.new(source_buffer,
                                        line_length + 2,
                                        line_length + 3),
              'foo',
              'Cop'
            )
          ]
        )

        formatter.file_started(files[1], {})
        formatter.file_finished(files[1], [])

        formatter.file_started(files[2], {})
        formatter.file_finished(
          files[2],
          [
            RuboCop::Cop::Offense.new(
              :error,
              Parser::Source::Range.new(source_buffer,
                                        (line_length * 4) + 1,
                                        (line_length * 4) + 2),
              'bar',
              'Cop'
            ),
            RuboCop::Cop::Offense.new(
              :convention,
              Parser::Source::Range.new(source_buffer,
                                        line_length * 5,
                                        (line_length * 5) + 1),
              'foo',
              'Cop'
            )
          ]
        )
      end

      it 'reports all detected offenses for all failed files' do
        formatter.finished(files)
        expect(output.string.include?(<<~OUTPUT)).to be(true)
          1..3
          not ok 1 - lib/rubocop.rb
          # lib/rubocop.rb:2:3: C: [Correctable] foo
          # This is line 2.
          #   ^
          ok 2 - spec/spec_helper.rb
          not ok 3 - exe/rubocop
          # exe/rubocop:5:2: E: [Correctable] bar
          # This is line 5.
          #  ^
          # exe/rubocop:6:1: C: [Correctable] foo
          # This is line 6.
          # ^
        OUTPUT
      end
    end

    context 'when no offenses are detected' do
      before do
        files.each do |file|
          formatter.file_started(file, {})
          formatter.file_finished(file, [])
        end
      end

      it 'does not report offenses' do
        formatter.finished(files)
        expect(output.string.include?('not ok')).to be(false)
      end
    end
  end

  describe '#report_file', :config do
    let(:cop_class) { RuboCop::Cop::Cop }
    let(:output) { StringIO.new }

    before { cop.send(:begin_investigation, processed_source) }

    context 'when the source contains multibyte characters' do
      let(:source) do
        <<~RUBY
          do_something("あああ", ["いいい"])
        RUBY
      end

      it 'displays text containing the offending source line' do
        location = source_range(source.index('[')..source.index(']'))

        cop.add_offense(nil, location: location, message: 'message 1')
        formatter.report_file('test', cop.offenses)

        expect(output.string)
          .to eq <<~OUTPUT
            # test:1:21: C: message 1
            # do_something("あああ", ["いいい"])
            #                        ^^^^^^^^^^
        OUTPUT
      end
    end
  end
end
