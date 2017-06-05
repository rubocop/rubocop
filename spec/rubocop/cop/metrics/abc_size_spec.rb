# frozen_string_literal: true

describe RuboCop::Cop::Metrics::AbcSize, :config do
  subject(:cop) { described_class.new(config) }

  context 'when Max is 0' do
    let(:cop_config) { { 'Max' => 0 } }

    it 'accepts an empty method' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def method_name
        end
      RUBY
    end

    it 'registers an offense for an if modifier' do
      inspect_source(cop, <<-RUBY.strip_indent)
        def method_name
          call_foo if some_condition # 0 + 2*2 + 1*1
        end
      RUBY
      expect(cop.messages)
        .to eq(['Assignment Branch Condition size for method_name is too ' \
                'high. [2.24/0]'])
      expect(cop.highlights).to eq(['def'])
      expect(cop.config_to_allow_offenses).to eq('Max' => 3)
    end

    it 'registers an offense for an assignment of a local variable' do
      inspect_source(cop, <<-RUBY.strip_indent)
        def method_name
          x = 1
        end
      RUBY
      expect(cop.messages)
        .to eq(['Assignment Branch Condition size for method_name is too ' \
                'high. [1/0]'])
      expect(cop.config_to_allow_offenses).to eq('Max' => 1)
    end

    it 'registers an offense for an assignment of an element' do
      inspect_source(cop, <<-RUBY.strip_indent)
        def method_name
          x[0] = 1
        end
      RUBY
      expect(cop.messages)
        .to eq(['Assignment Branch Condition size for method_name is too ' \
                'high. [1.41/0]'])
      expect(cop.config_to_allow_offenses).to eq('Max' => 2)
    end

    it 'registers an offense for complex content including A, B, and C ' \
       'scores' do
      inspect_source(cop, <<-RUBY.strip_indent)
        def method_name
          my_options = Hash.new if 1 == 1 || 2 == 2 # 1, 3, 2
          my_options.each do |key, value|           # 0, 1, 0
            p key                                   # 0, 1, 0
            p value                                 # 0, 1, 0
          end
        end
      RUBY
      expect(cop.messages)
        .to eq(['Assignment Branch Condition size for method_name is too ' \
                'high. [6.4/0]']) # sqrt(1*1 + 6*6 + 2*2) => 6.4
    end

    context 'target_ruby_version >= 2.3', :ruby23 do
      it 'treats safe navigation method calls like regular method calls' do
        expect_offense(<<-RUBY.strip_indent) # sqrt(0 + 2*2 + 0) => 2
          def method_name
          ^^^ Assignment Branch Condition size for method_name is too high. [2/0]
            object&.do_something
          end
        RUBY
      end
    end
  end

  context 'when Max is 2' do
    let(:cop_config) { { 'Max' => 2 } }

    it 'accepts two assignments' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def method_name
          x = 1
          y = 2
        end
      RUBY
    end
  end

  context 'when Max is 1.8' do
    let(:cop_config) { { 'Max' => 1.8 } }

    it 'accepts a total score of 1.7' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def method_name
          y = 1 if y == 1
        end
      RUBY
    end
  end

  {
    1.3     => '3.74/1.3',    # no more than 2 decimals reported
    10.3    => '37.42/10.3',
    100.321 => '374.2/100.3', # 4 significant digits, so only 1 decimal here
    1000.3  => '3742/1000'
  }.each do |max, presentation|
    context "when Max is #{max}" do
      let(:cop_config) { { 'Max' => max } }

      it "reports size and max as #{presentation}" do
        # Build an amount of code large enough to register an offense.
        code = ['  x = Hash.new if 1 == 1 || 2 == 2'] * max

        inspect_source(cop, ['def method_name',
                             *code,
                             'end'])
        expect(cop.messages)
          .to eq(['Assignment Branch Condition size for method_name is too ' \
                  "high. [#{presentation}]"])
      end
    end
  end
end
