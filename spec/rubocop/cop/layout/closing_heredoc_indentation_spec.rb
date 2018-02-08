# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::ClosingHeredocIndentation do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    RuboCop::Config.new('Layout/ClosingHeredocIndentation' => cop_config)
  end
  let(:cop_config) { { 'Enabled' => true } }

  it 'accepts correctly indented closing heredoc' do
    expect_no_offenses(<<-RUBY.strip_indent)
      class Test
        def foo
          <<-SQL
            bar
          SQL
        end
      end
    RUBY
  end

  it 'registers an offence for bad indentation of a closing heredoc' do
    expect_offense(<<-RUBY.strip_indent)
      class Test
        def foo
          <<-SQL
            bar
        SQL
      ^^^^^ `SQL` is not aligned with `<<-SQL`.
        end
      end
    RUBY
  end

  describe '#autocorrect' do
    it 'corrects bad indentation' do
      corrected = autocorrect_source(<<-RUBY.strip_indent)
        class Test
          def foo
            <<-SQL
              bar
          SQL
          end
        end
      RUBY
      expect(corrected).to eq <<-RUBY.strip_indent
        class Test
          def foo
            <<-SQL
              bar
            SQL
          end
        end
      RUBY
    end
  end
end
