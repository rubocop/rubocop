# frozen_string_literal: true

describe RuboCop::Cop::Metrics::CyclomaticComplexity, :config do
  subject(:cop) { described_class.new(config) }

  context 'when Max is 1' do
    let(:cop_config) { { 'Max' => 1 } }

    it 'accepts a method with no decision points' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def method_name
          call_foo
        end
      RUBY
    end

    it 'accepts complex code outside of methods' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def method_name
          call_foo
        end

        if first_condition then
          call_foo if second_condition && third_condition
          call_bar if fourth_condition || fifth_condition
        end
      RUBY
    end

    it 'registers an offense for an if modifier' do
      inspect_source(cop, <<-RUBY.strip_indent)
        def self.method_name
          call_foo if some_condition
        end
      RUBY
      expect(cop.messages)
        .to eq(['Cyclomatic complexity for method_name is too high. [2/1]'])
      expect(cop.highlights).to eq(['def'])
      expect(cop.config_to_allow_offenses).to eq('Max' => 2)
    end

    it 'registers an offense for an unless modifier' do
      expect_offense(<<-RUBY.strip_indent)
        def method_name
        ^^^ Cyclomatic complexity for method_name is too high. [2/1]
          call_foo unless some_condition
        end
      RUBY
    end

    it 'registers an offense for an elsif block' do
      expect_offense(<<-RUBY.strip_indent)
        def method_name
        ^^^ Cyclomatic complexity for method_name is too high. [3/1]
          if first_condition then
            call_foo
          elsif second_condition then
            call_bar
          else
            call_bam
          end
        end
      RUBY
    end

    it 'registers an offense for a ternary operator' do
      expect_offense(<<-RUBY.strip_indent)
        def method_name
        ^^^ Cyclomatic complexity for method_name is too high. [2/1]
          value = some_condition ? 1 : 2
        end
      RUBY
    end

    it 'registers an offense for a while block' do
      expect_offense(<<-RUBY.strip_indent)
        def method_name
        ^^^ Cyclomatic complexity for method_name is too high. [2/1]
          while some_condition do
            call_foo
          end
        end
      RUBY
    end

    it 'registers an offense for an until block' do
      expect_offense(<<-RUBY.strip_indent)
        def method_name
        ^^^ Cyclomatic complexity for method_name is too high. [2/1]
          until some_condition do
            call_foo
          end
        end
      RUBY
    end

    it 'registers an offense for a for block' do
      expect_offense(<<-RUBY.strip_indent)
        def method_name
        ^^^ Cyclomatic complexity for method_name is too high. [2/1]
          for i in 1..2 do
            call_method
          end
        end
      RUBY
    end

    it 'registers an offense for a rescue block' do
      expect_offense(<<-RUBY.strip_indent)
        def method_name
        ^^^ Cyclomatic complexity for method_name is too high. [2/1]
          begin
            call_foo
          rescue Exception
            call_bar
          end
        end
      RUBY
    end

    it 'registers an offense for a case/when block' do
      expect_offense(<<-RUBY.strip_indent)
        def method_name
        ^^^ Cyclomatic complexity for method_name is too high. [3/1]
          case value
          when 1
            call_foo
          when 2
            call_bar
          end
        end
      RUBY
    end

    it 'registers an offense for &&' do
      expect_offense(<<-RUBY.strip_indent)
        def method_name
        ^^^ Cyclomatic complexity for method_name is too high. [2/1]
          call_foo && call_bar
        end
      RUBY
    end

    it 'registers an offense for and' do
      expect_offense(<<-RUBY.strip_indent)
        def method_name
        ^^^ Cyclomatic complexity for method_name is too high. [2/1]
          call_foo and call_bar
        end
      RUBY
    end

    it 'registers an offense for ||' do
      expect_offense(<<-RUBY.strip_indent)
        def method_name
        ^^^ Cyclomatic complexity for method_name is too high. [2/1]
          call_foo || call_bar
        end
      RUBY
    end

    it 'registers an offense for or' do
      expect_offense(<<-RUBY.strip_indent)
        def method_name
        ^^^ Cyclomatic complexity for method_name is too high. [2/1]
          call_foo or call_bar
        end
      RUBY
    end

    it 'deals with nested if blocks containing && and ||' do
      expect_offense(<<-RUBY.strip_indent)
        def method_name
        ^^^ Cyclomatic complexity for method_name is too high. [6/1]
          if first_condition then
            call_foo if second_condition && third_condition
            call_bar if fourth_condition || fifth_condition
          end
        end
      RUBY
    end

    it 'counts only a single method' do
      expect_offense(<<-RUBY.strip_indent)
        def method_name_1
        ^^^ Cyclomatic complexity for method_name_1 is too high. [2/1]
          call_foo if some_condition
        end

        def method_name_2
        ^^^ Cyclomatic complexity for method_name_2 is too high. [2/1]
          call_foo if some_condition
        end
      RUBY
    end
  end

  context 'when Max is 2' do
    let(:cop_config) { { 'Max' => 2 } }

    it 'counts stupid nested if and else blocks' do
      expect_offense(<<-RUBY.strip_indent)
        def method_name
        ^^^ Cyclomatic complexity for method_name is too high. [5/2]
          if first_condition then
            call_foo
          else
            if second_condition then
              call_bar
            else
              call_bam if third_condition
            end
            call_baz if fourth_condition
          end
        end
      RUBY
    end
  end
end
