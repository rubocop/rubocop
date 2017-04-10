# frozen_string_literal: true

describe RuboCop::CLI, :isolated_environment do
  include_context 'cli spec behavior'

  subject(:cli) { described_class.new }

  describe '--disable-uncorrectable' do
    subject do
      cli.run(%w[--auto-correct --format emacs --disable-uncorrectable])
    end

    it 'does not disable anything for cops that support autocorrect' do
      create_file('example.rb', 'puts 1==2')
      expect(subject).to eq(0)
      expect($stderr.string).to eq('')
      expect($stdout.string)
        .to eq("#{abs('example.rb')}:1:7: C: [Corrected] Surrounding " \
               "space missing for operator `==`.\n")
      expect(IO.read('example.rb')).to eq("puts 1 == 2\n")
    end

    it 'adds one-line disable statement for one-line offenses' do
      create_file('example.rb', ['def is_example',
                                 '  true',
                                 'end'])
      expect(subject).to eq(0)
      expect($stderr.string).to eq('')
      expect($stdout.string)
        .to eq("#{abs('example.rb')}:1:5: C: [Corrected] Rename `is_example` " \
               "to `example?`.\n")
      expect(IO.readlines('example.rb').map(&:chomp))
        .to eq(['def is_example # rubocop:disable Style/PredicateName',
                '  true',
                'end'])
    end

    it 'adds before-and-after disable statement for multiline offenses' do
      create_file('.rubocop.yml', ['Metrics/MethodLength:',
                                   '  Max: 1'])
      create_file('example.rb', ['def example',
                                 "  puts 'line 1'",
                                 "  puts 'line 2'",
                                 'end'])
      expect(subject).to eq(0)
      expect($stderr.string).to eq('')
      expect($stdout.string)
        .to eq("#{abs('example.rb')}:1:1: C: [Corrected] Method " \
               "has too many lines. [2/1]\n")
      expect(IO.readlines('example.rb').map(&:chomp))
        .to eq(['# rubocop:disable Metrics/MethodLength',
                'def example',
                "  puts 'line 1'",
                "  puts 'line 2'",
                'end',
                '# rubocop:enable Metrics/MethodLength'])
    end
  end
end
