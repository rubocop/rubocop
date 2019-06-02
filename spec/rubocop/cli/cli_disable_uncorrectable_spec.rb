# frozen_string_literal: true

RSpec.describe RuboCop::CLI, :isolated_environment do
  include_context 'cli spec behavior'

  subject(:cli) { described_class.new }

  describe '--disable-uncorrectable' do
    let(:exit_code) do
      cli.run(%w[--auto-correct --format simple --disable-uncorrectable])
    end

    it 'does not disable anything for cops that support autocorrect' do
      create_file('example.rb', 'puts 1==2')
      expect(exit_code).to eq(0)
      expect($stderr.string).to eq('')
      expect($stdout.string).to eq(<<-OUTPUT.strip_indent)
        == example.rb ==
        C:  1:  1: [Corrected] Style/FrozenStringLiteralComment: Missing magic comment # frozen_string_literal: true.
        C:  1:  7: [Corrected] Layout/SpaceAroundOperators: Surrounding space missing for operator ==.
        
        1 file inspected, 2 offenses detected, 2 offenses corrected
      OUTPUT
      expect(IO.read('example.rb')).to eq(<<-RUBY.strip_indent)
        # frozen_string_literal: true

        puts 1 == 2
      RUBY
    end

    it 'adds one-line disable statement for one-line offenses' do
      create_file('example.rb', <<-RUBY.strip_indent)
        def is_example
          true
        end
      RUBY
      expect(exit_code).to eq(0)
      expect($stderr.string).to eq('')
      expect($stdout.string).to eq(<<-OUTPUT.strip_indent)
        == example.rb ==
        C:  1:  1: [Corrected] Style/FrozenStringLiteralComment: Missing magic comment # frozen_string_literal: true.
        C:  1:  5: [Corrected] Naming/PredicateName: Rename is_example to example?.
        
        1 file inspected, 2 offenses detected, 2 offenses corrected
      OUTPUT
      expect(IO.read('example.rb')).to eq(<<-RUBY.strip_indent)
        # rubocop:disable Naming/PredicateName
        # frozen_string_literal: true

        def is_example
          true
        end
        # rubocop:enable Naming/PredicateName
      RUBY
    end

    it 'adds before-and-after disable statement for multiline offenses' do
      create_file('.rubocop.yml', <<-YAML.strip_indent)
        Metrics/MethodLength:
          Max: 1
      YAML
      create_file('example.rb', <<-RUBY.strip_indent)
        def example
          puts 'line 1'
          puts 'line 2'
        end
      RUBY
      expect(exit_code).to eq(0)
      expect($stderr.string).to eq('')
      expect($stdout.string).to eq(<<-OUTPUT.strip_indent)
        == example.rb ==
        C:  1:  1: [Corrected] Metrics/MethodLength: Method has too many lines. [2/1]
        C:  1:  1: [Corrected] Style/FrozenStringLiteralComment: Missing magic comment # frozen_string_literal: true.
        
        1 file inspected, 2 offenses detected, 2 offenses corrected
      OUTPUT
      expect(IO.read('example.rb')).to eq(<<-RUBY.strip_indent)
        # rubocop:disable Metrics/MethodLength
        # frozen_string_literal: true

        def example
          puts 'line 1'
          puts 'line 2'
        end
        # rubocop:enable Metrics/MethodLength
      RUBY
    end
  end
end
